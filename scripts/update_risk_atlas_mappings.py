"""
Refresh IBM Risk Atlas Nexus mappings and write JSON caches under data/.

Usage:
    python scripts/update_risk_atlas_mappings.py
"""

from __future__ import annotations

import json
import sys
import urllib.request
from pathlib import Path
from typing import Any, Dict, Set

import yaml

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"
DATA_DIR.mkdir(parents=True, exist_ok=True)

SOURCES = {
    "nexus": "https://raw.githubusercontent.com/IBM/risk-atlas-nexus/main/src/risk_atlas_nexus/data/knowledge_graph/mappings/mit-ai-risk-repository_ibm-risk-atlas_from_tsv_data.yaml",
    "nist": "https://raw.githubusercontent.com/IBM/risk-atlas-nexus/main/src/risk_atlas_nexus/data/knowledge_graph/mappings/ibm2nistgenai_from_tsv_data.yaml",
}

DEST = DATA_DIR / "risk_atlas_nexus_mappings.json"


def download_yaml(url: str) -> Dict[str, Any]:
    with urllib.request.urlopen(url, timeout=30) as resp:
        raw = resp.read().decode("utf-8")
    return yaml.safe_load(raw) or {}


def build_mapping() -> Dict[str, Dict[str, list[str]]]:
    combined: Dict[str, Dict[str, Set[str]]] = {}

    def ensure_entry(atlas_id: str) -> Dict[str, Set[str]]:
        return combined.setdefault(atlas_id, {"relatedMatch": set(), "nist": set(), "mit_ai": set(), "mitre": set()})

    # Base nexus mappings
    base = download_yaml(SOURCES["nexus"])
    for entry in base.get("risks", []):
        atlas_id = entry.get("id")
        if not atlas_id:
            continue
        target = ensure_entry(atlas_id)
        if entry.get("relatedMatch"):
            target["relatedMatch"].update(entry["relatedMatch"])

    # NIST crosswalk
    nist = download_yaml(SOURCES["nist"])
    for entry in nist.get("risks", []):
        atlas_id = entry.get("id")
        if not atlas_id:
            continue
        target = ensure_entry(atlas_id)
        if entry.get("relatedMatch"):
            target["nist"].update(entry["relatedMatch"])

    normalized: Dict[str, Dict[str, list[str]]] = {}
    for atlas_id, buckets in combined.items():
        normalized[atlas_id] = {key: sorted(values) for key, values in buckets.items()}
    return normalized


def main() -> int:
    mapping = build_mapping()
    DEST.write_text(json.dumps(mapping, indent=2), encoding="utf-8")
    print(f"Wrote {len(mapping)} entries to {DEST}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
