from __future__ import annotations

from typing import Dict


def _titleize(identifier: str) -> str:
    if "." in identifier:
        parts = identifier.split(".")
    else:
        parts = identifier.split("_")
    return " ".join(part.capitalize() for part in parts)


CATEGORY_DEFINITIONS: Dict[str, Dict[str, str]] = {
    "technical.attack": {
        "name": "Technical Attack",
        "description": "Adversarial or malicious technical actions against AI systems.",
    },
    "governance.oversight": {
        "name": "Governance Oversight",
        "description": "Oversight and accountability gaps in AI operations.",
    },
    "governance.fairness": {
        "name": "Governance Fairness",
        "description": "Equity, bias, or fairness risks within AI governance.",
    },
    "governance.monitoring": {
        "name": "Governance Monitoring",
        "description": "Monitoring and performance management risks for AI systems.",
    },
    "governance.transparency": {
        "name": "Governance Transparency",
        "description": "Transparency, explainability, or stakeholder communication risks.",
    },
    "governance.compliance": {
        "name": "Governance Compliance",
        "description": "Regulatory reporting, documentation, or compliance gaps.",
    },
    "governance.legal": {
        "name": "Governance Legal",
        "description": "Legal exposure and contractual obligations tied to AI usage.",
    },
    "privacy.governance": {
        "name": "Privacy Governance",
        "description": "Privacy and data protection issues in AI governance.",
    },
    "safety.incidents": {
        "name": "Safety Incidents",
        "description": "Documented AI-related safety or operational incidents.",
    },
}

ALLOWED_CATEGORIES = set(CATEGORY_DEFINITIONS.keys())

ENERGY_CONTEXT_DEFINITIONS: Dict[str, Dict[str, str]] = {
    "generation_renewables": {
        "name": "Renewable Generation",
        "description": "Solar, wind, hydro, or other renewable generation assets.",
        "criticality": 3,
    },
    "generation_conventional": {
        "name": "Conventional Generation",
        "description": "Thermal, nuclear, or fossil-based power plants.",
        "criticality": 3,
    },
    "transmission_control": {
        "name": "Transmission Control",
        "description": "Transmission network operations, substations, relay protection.",
        "criticality": 4,
    },
    "distribution_operations": {
        "name": "Distribution Operations",
        "description": "Distribution management systems, outage restoration, voltage regulation.",
        "criticality": 3,
    },
    "market_operations": {
        "name": "Market Operations",
        "description": "Trading, dispatch optimisation, balancing markets, price forecasting.",
        "criticality": 3,
    },
    "demand_response": {
        "name": "Demand Response",
        "description": "Flexibility management, demand response aggregators, prosumer programmes.",
        "criticality": 3,
    },
    "retail_energy": {
        "name": "Retail Energy",
        "description": "Customer-facing services, billing, personalisation, demand prediction.",
        "criticality": 2,
    },
    "enterprise_it": {
        "name": "Enterprise IT",
        "description": "Back-office AI (HR, cybersecurity, procurement, document processing).",
        "criticality": 2,
    },
    "asset_management": {
        "name": "Asset Management",
        "description": "Predictive maintenance, inspection drones, fault detection.",
        "criticality": 3,
    },
    "public_affairs": {
        "name": "Public Affairs",
        "description": "External communications, regulatory transparency, explainability obligations.",
        "criticality": 2,
    },
    "legal_affairs": {
        "name": "Legal Affairs",
        "description": "Compliance tracking, documentation, regulatory submissions.",
        "criticality": 2,
    },
    "supply_chain": {
        "name": "Supply Chain",
        "description": "Vendor data, model sourcing, and third-party dependencies.",
        "criticality": 3,
    },
    "control_rooms": {
        "name": "Control Rooms",
        "description": "Real-time supervision, operator decision support, human-AI teaming.",
        "criticality": 4,
    },
    "transmission_planning": {
        "name": "Transmission Planning",
        "description": "Grid expansion, capacity planning, load flow simulations.",
        "criticality": 3,
    },
    "distributed_generation": {
        "name": "Distributed Generation",
        "description": "DER forecasting, microgrids, and virtual power plants.",
        "criticality": 3,
    },
    "substation_security": {
        "name": "Substation Security",
        "description": "Physical and digital security, surveillance analytics.",
        "criticality": 4,
    },
}

ALLOWED_CONTEXTS = set(ENERGY_CONTEXT_DEFINITIONS.keys())


def get_category_display_name(category_id: str) -> str:
    meta = CATEGORY_DEFINITIONS.get(category_id)
    if meta and meta.get("name"):
        return meta["name"]
    return _titleize(category_id)


def get_context_display_name(context_id: str) -> str:
    meta = ENERGY_CONTEXT_DEFINITIONS.get(context_id)
    if meta and meta.get("name"):
        return meta["name"]
    return _titleize(context_id)
