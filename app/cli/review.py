from __future__ import annotations

import csv
import sys
from typing import List

import typer
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models import Risk
from app.db.session import get_session

review_app = typer.Typer(help="Editorial review utilities")


@review_app.command("feed")
def review_feed() -> None:
    with get_session() as session:
        rows = _collect_rows(session)
    writer = csv.DictWriter(
        sys.stdout,
        fieldnames=["risk_id", "risk_name", "missing_fields"],
    )
    writer.writeheader()
    for row in rows:
        writer.writerow(row)


def _collect_rows(session: Session) -> List[dict]:
    results = session.execute(select(Risk)).scalars().all()
    review_rows = []
    for risk in results:
        card = dict(risk.card)
        missing = []
        if not card.get("known_mitigations"):
            missing.append("known_mitigations")
        if not card.get("source_reference"):
            missing.append("source_reference")
        if not card.get("impact_level"):
            missing.append("impact_level")
        if not card.get("probability_level"):
            missing.append("probability_level")
        if missing:
            review_rows.append(
                {
                    "risk_id": risk.risk_id,
                    "risk_name": card.get("risk_name"),
                    "missing_fields": ";".join(missing),
                }
            )
    return review_rows
