from __future__ import annotations

import csv
from pathlib import Path
from typing import Dict, Iterable, List, Optional

import typer
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.models import Category, EnergyContext, Risk
from app.db.session import get_session
from app.schemas.risk import RiskCard, RiskCreate, RiskUpdate
from app.services import risk_service

seed_app = typer.Typer(help="Seed and ingestion commands")

REQUIRED_FIELDS = {
    "risk_id",
    "risk_name",
    "description",
    "ai_model_type",
    "probability_level",
    "impact_level",
    "impact_dimensions",
    "trigger_conditions",
    "technological_dependencies",
    "known_mitigations",
    "regulatory_requirements",
    "operational_priority",
    "source_reference",
    "provenance",
    "categories",
    "energy_context",
    "version",
}


def _split_multi(value: str) -> List[str]:
    if not value:
        return []
    return [item.strip() for item in value.split(";") if item.strip()]


def _ensure_bounds(value: str) -> int:
    number = int(value)
    if number < 1 or number > 5:
        raise typer.BadParameter("Levels must be between 1 and 5")
    return number


@seed_app.command("canonical-seed")
def canonical_seed(
    file: Path = typer.Option(..., exists=True, readable=True),
    provenance_editor: Optional[str] = typer.Option(None, help="Override provenance editor name"),
) -> None:
    editor = provenance_editor or settings.provenance_editor
    with get_session() as session:
        _ingest_file(session, file, editor)
        typer.echo("Canonical seed ingestion completed")


def _ingest_file(session: Session, file_path: Path, editor: str) -> None:
    with file_path.open("r", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        missing = REQUIRED_FIELDS - set(reader.fieldnames or [])
        if missing:
            raise typer.BadParameter(f"Missing required columns: {', '.join(sorted(missing))}")
        for row in reader:
            _process_row(session, row, editor)


def _process_row(session: Session, row: Dict[str, str], editor: str) -> None:
    risk_id = row["risk_id"].strip()
    card_dict = {
        "risk_name": row["risk_name"].strip(),
        "description": row["description"].strip(),
        "ai_model_type": _split_multi(row.get("ai_model_type", "")),
        "probability_level": _ensure_bounds(row["probability_level"]),
        "impact_level": _ensure_bounds(row["impact_level"]),
        "impact_dimensions": _split_multi(row.get("impact_dimensions", "")),
        "trigger_conditions": row["trigger_conditions"].strip(),
        "technological_dependencies": _split_multi(row.get("technological_dependencies", "")),
        "known_mitigations": _split_multi(row.get("known_mitigations", "")),
        "regulatory_requirements": _split_multi(row.get("regulatory_requirements", "")),
        "operational_priority": _ensure_bounds(row["operational_priority"]),
        "source_reference": _split_multi(row.get("source_reference", "")),
        "provenance": _split_multi(row.get("provenance", "")),
        "related_risks": _split_multi(row.get("related_risks", "")),
        "categories": _split_multi(row.get("categories", "")),
        "energy_context": _split_multi(row.get("energy_context", "")),
        "version": row["version"].strip(),
    }
    merge_hash = risk_service.compute_risk_hash(card_dict["risk_name"], card_dict["description"])
    card_dict["merge_hash"] = merge_hash

    category_links = card_dict["categories"]
    context_links = card_dict["energy_context"]

    target_risk = session.get(Risk, risk_id)
    if not target_risk:
        target_risk = session.execute(
            select(Risk).where(Risk.card["merge_hash"].astext == merge_hash)
        ).scalars().first()

    if target_risk:
        existing_card = dict(target_risk.card)
        for key, value in card_dict.items():
            if isinstance(value, list):
                existing_values = existing_card.get(key, [])
                deduped = list(dict.fromkeys(existing_values + value))
                existing_card[key] = deduped
            else:
                existing_card[key] = value
        existing_card["stable_id"] = target_risk.risk_id
        updated = RiskUpdate(
            status=row.get("status") or target_risk.status,
            version=row.get("version") or target_risk.version,
            card=RiskCard(**existing_card),
        )
        risk_service.update_risk(session, target_risk.risk_id, updated, editor=editor)
        target_id = target_risk.risk_id
    else:
        risk_create = RiskCreate(
            risk_id=risk_id,
            status=row.get("status") or "seeded",
            version=row.get("version") or card_dict["version"],
            card=RiskCard(**card_dict),
        )
        risk_service.create_risk(session, risk_create, editor=editor)
        target_id = risk_id

    _link_categories(session, target_id, category_links)
    _link_contexts(session, target_id, context_links)


def _link_categories(session: Session, risk_id: str, categories: Iterable[str]) -> None:
    available = {
        cat.category_id
        for cat in session.execute(select(Category).where(Category.category_id.in_(list(categories)))).scalars()
    }
    risk_service.set_categories(session, risk_id=risk_id, category_ids=available)


def _link_contexts(session: Session, risk_id: str, contexts: Iterable[str]) -> None:
    context_models = (
        session.execute(select(EnergyContext).where(EnergyContext.context_id.in_(list(contexts)))).scalars().all()
    )
    context_refs = [
        {"context_id": context.context_id, "exposure_level": context.criticality_level}
        for context in context_models
    ]
    risk_service.set_contexts(session, risk_id=risk_id, context_refs=context_refs)
