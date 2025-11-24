from __future__ import annotations

import hashlib
import json
from datetime import datetime
from typing import Any, Dict, Iterable, List, Optional, Sequence

from sqlalchemy import Text, cast, func, select
from sqlalchemy.exc import NoResultFound
from sqlalchemy.orm import Session

from app.schemas.risk import RiskBrief, RiskCard, RiskCreate, RiskPatch, RiskResponse, RiskUpdate
from app.core.config import settings
from app.db.models import Risk, RiskCategory, RiskContext


def _ensure_stable_id(card: Dict[str, Any], risk_id: str) -> Dict[str, Any]:
    card["stable_id"] = risk_id
    return card


def _append_provenance(card: Dict[str, Any], action: str, editor: Optional[str] = None) -> None:
    provenance = card.setdefault("provenance", [])
    if provenance and isinstance(provenance[0], str):
        card["provenance"] = [{"note": entry} for entry in provenance if entry]
        provenance = card["provenance"]
    provenance_entry = {
        "action": action,
        "editor": editor or settings.provenance_editor,
        "timestamp": datetime.utcnow().isoformat(),
    }
    provenance.append(provenance_entry)


def get_risks(
    session: Session,
    *,
    q: Optional[str] = None,
    min_impact: Optional[int] = None,
    limit: int = 50,
    ids: Optional[Sequence[str]] = None,
    category: Optional[str] = None,
    lifecycle_stage: Optional[str] = None,
) -> List[RiskResponse]:
    stmt = select(Risk)
    if ids:
        stmt = stmt.where(Risk.risk_id.in_(ids))
    if q:
        stmt = stmt.where(func.lower(cast(Risk.card, Text)).like(f"%{q.lower()}%"))
    if min_impact is not None:
        stmt = stmt.where(Risk.card["impact_level"].as_integer() >= min_impact)
    risks = session.execute(stmt).scalars().all()
    if category:
        category_lower = category.lower()
        risks = [
            risk
            for risk in risks
            if category_lower in {item.lower() for item in risk.card.get("categories", [])}
        ]
    if lifecycle_stage:
        risks = [
            risk
            for risk in risks
            if risk.card.get("lifecycle_stage") == lifecycle_stage
        ]
    if limit:
        risks = risks[:limit]
    return [_to_response(risk) for risk in risks]


def get_risk(session: Session, risk_id: str) -> RiskResponse:
    risk = session.get(Risk, risk_id)
    if not risk:
        raise NoResultFound(f"Risk {risk_id} not found")
    return _to_response(risk)


def create_risk(session: Session, payload: RiskCreate, editor: Optional[str] = None) -> RiskResponse:
    card_dict = payload.card.dict()
    card_dict = _ensure_stable_id(card_dict, payload.risk_id)
    _append_provenance(card_dict, "create", editor)
    risk = Risk(
        risk_id=payload.risk_id,
        status=payload.status,
        version=payload.version or payload.card.version,
        card=card_dict,
    )
    session.add(risk)
    session.flush()
    return _to_response(risk)


def update_risk(session: Session, risk_id: str, payload: RiskUpdate, editor: Optional[str] = None) -> RiskResponse:
    risk = session.get(Risk, risk_id)
    if not risk:
        raise NoResultFound(f"Risk {risk_id} not found")
    if payload.status is not None:
        risk.status = payload.status
    if payload.version is not None:
        risk.version = payload.version
    if payload.card is not None:
        card_dict = payload.card.dict()
        card_dict = _ensure_stable_id(card_dict, risk_id)
        _append_provenance(card_dict, "replace", editor)
        risk.card = card_dict
    else:
        card_dict = dict(risk.card)
        _append_provenance(card_dict, "replace", editor)
        risk.card = card_dict
    session.flush()
    return _to_response(risk)


def patch_risk(session: Session, risk_id: str, payload: RiskPatch, editor: Optional[str] = None) -> RiskResponse:
    risk = session.get(Risk, risk_id)
    if not risk:
        raise NoResultFound(f"Risk {risk_id} not found")
    if payload.status is not None:
        risk.status = payload.status
    if payload.version is not None:
        risk.version = payload.version
    card_dict = dict(risk.card)
    updates = payload.card_updates or {}
    for key, value in updates.items():
        card_dict[key] = value
    card_dict = _ensure_stable_id(card_dict, risk_id)
    _append_provenance(card_dict, "patch", editor)
    risk.card = card_dict
    session.flush()
    return _to_response(risk)


def delete_risk(session: Session, risk_id: str) -> None:
    risk = session.get(Risk, risk_id)
    if not risk:
        raise NoResultFound(f"Risk {risk_id} not found")
    session.delete(risk)
    session.flush()


def set_categories(session: Session, risk_id: str, category_ids: Iterable[str]) -> None:
    session.query(RiskCategory).filter(RiskCategory.risk_id == risk_id).delete()
    for category_id in category_ids:
        session.merge(
            RiskCategory(risk_id=risk_id, category_id=category_id, assignment_type="canonical")
        )


def set_contexts(session: Session, risk_id: str, context_refs: Iterable[Dict[str, Any]]) -> None:
    session.query(RiskContext).filter(RiskContext.risk_id == risk_id).delete()
    for context_ref in context_refs:
        session.merge(
            RiskContext(
                risk_id=risk_id,
                context_id=context_ref["context_id"],
                exposure_level=context_ref.get("exposure_level", 3),
            )
        )


def compute_risk_hash(title: str, description: str) -> str:
    normalized = "".join(ch for ch in title.lower() if ch.isalnum() or ch.isspace()).strip()
    snippet = description[:200].lower()
    digest = hashlib.sha256(f"{normalized}|{snippet}".encode()).hexdigest()
    return digest


def _to_response(risk: Risk) -> RiskResponse:
    card = dict(risk.card)
    card.setdefault("stable_id", risk.risk_id)
    return RiskResponse(
        risk_id=risk.risk_id,
        status=risk.status,
        version=risk.version,
        card=RiskCard(**card),
        created_at=risk.created_at,
        updated_at=risk.updated_at,
    )


def get_brief(session: Session, ids: Optional[Sequence[str]] = None) -> List[RiskBrief]:
    stmt = select(
        Risk.risk_id,
        Risk.card["risk_name"].astext,
        Risk.card["impact_level"].as_integer(),
        Risk.card["impact_dimensions"].astext,
    )
    if ids:
        stmt = stmt.where(Risk.risk_id.in_(ids))
    results = session.execute(stmt).all()
    briefs: List[RiskBrief] = []
    for risk_id, name, impact_level, impact_dimensions in results:
        dimensions = []
        if impact_dimensions:
            try:
                dimensions = json.loads(impact_dimensions)
            except json.JSONDecodeError:
                dimensions = [part.strip() for part in impact_dimensions.split(",") if part.strip()]
        briefs.append(
            RiskBrief(
                risk_id=risk_id,
                risk_name=name,
                impact_level=impact_level or 0,
                impact_dimensions=dimensions,
            )
        )
    return briefs
