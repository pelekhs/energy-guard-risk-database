from __future__ import annotations

from pathlib import Path

import pytest
from typer.testing import CliRunner

from app.cli import cli as cli_app
from app.db.models import Risk
from app.db.session import get_session
from app.services.export_service import export_json_bytes


INVALID_CARD = {
    "risk_id": "EG-R-9000",
    "status": "draft",
    "version": "1.0",
    "card": {
        "risk_name": "Invalid Risk",
        "description": "Example invalid risk for testing.",
        "ai_model_type": ["forecasting"],
        "probability_level": 3,
        "impact_level": 6,
        "impact_dimensions": ["reliability"],
        "trigger_conditions": "Testing",
        "technological_dependencies": ["pipeline"],
        "known_mitigations": ["mitigation"],
        "regulatory_requirements": ["NERC"],
        "operational_priority": 3,
        "source_reference": ["TEST:001"],
        "provenance": ["unit-test"],
        "related_risks": [],
        "categories": [],
        "energy_context": [],
        "version": "1.0",
    },
}


VALID_CARD = {
    "risk_id": "EG-R-9001",
    "status": "active",
    "version": "1.0",
    "card": {
        "risk_name": "Forecast Bias",
        "description": "Forecast bias leading to operational issues.",
        "ai_model_type": ["forecasting"],
        "probability_level": 3,
        "impact_level": 4,
        "impact_dimensions": ["forecast"],
        "trigger_conditions": "Unexpected weather shift",
        "technological_dependencies": ["data lake"],
        "known_mitigations": ["retraining"],
        "regulatory_requirements": ["NERC"],
        "operational_priority": 4,
        "source_reference": ["TEST:002"],
        "provenance": ["unit-test"],
        "related_risks": [],
        "categories": ["governance.monitoring"],
        "energy_context": ["transmission_planning"],
        "version": "1.0",
    },
}


def test_validation_rejects_invalid_levels(client):
    response = client.post("/risks", json=INVALID_CARD)
    assert response.status_code == 422


def test_search_and_filters(client):
    create = client.post("/risks", json=VALID_CARD)
    assert create.status_code == 201
    response = client.get("/risks", params={"q": "forecast", "min_impact": 4})
    assert response.status_code == 200
    items = response.json()
    assert any(item["risk_id"] == VALID_CARD["risk_id"] for item in items)
    brief = client.get("/risks/brief", params={"ids": VALID_CARD["risk_id"]})
    assert brief.status_code == 200
    brief_items = brief.json()
    assert brief_items[0]["risk_id"] == VALID_CARD["risk_id"]


@pytest.mark.parametrize("ingest_runs", [1, 2])
def test_import_idempotency(tmp_path, ingest_runs):
    seed_file = tmp_path / "seed.csv"
    seed_file.write_text(
        """risk_id,risk_name,description,ai_model_type,probability_level,impact_level,impact_dimensions,trigger_conditions,technological_dependencies,known_mitigations,regulatory_requirements,operational_priority,source_reference,provenance,related_risks,categories,energy_context,version\n"
        "EG-R-9100,Test Risk,Description,forecasting,3,4,reliability,Trigger,Dependency,Mitigation,NERC,3,TEST:003,merged: TEST | editor:ICCS | date:2024-03-20,,governance.test,lab,1.0\n"
    )
    runner = CliRunner()
    for _ in range(ingest_runs):
        result = runner.invoke(cli_app, ["ingest", "canonical-seed", "--file", str(seed_file)])
        assert result.exit_code == 0
    with get_session() as session:
        count = session.query(Risk).count()
    assert count == 1


def test_export_parity(tmp_path):
    runner = CliRunner()
    runner.invoke(cli_app, ["ingest", "canonical-seed", "--file", str(Path("seed_canonical_risks.csv"))])
    with get_session() as session:
        db_count = session.query(Risk).count()
        export_payload = export_json_bytes(session)
    assert db_count >= 20
    assert len(export_payload) > 0
