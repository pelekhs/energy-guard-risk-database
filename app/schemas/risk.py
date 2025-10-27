from datetime import datetime
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field, validator

RISK_ID_PATTERN = r"^EG-R-\d{4,}$"


class RiskCard(BaseModel):
    risk_name: str
    description: str
    ai_model_type: List[str] = Field(default_factory=list)
    probability_level: int = Field(..., ge=1, le=5)
    impact_level: int = Field(..., ge=1, le=5)
    impact_dimensions: List[str] = Field(default_factory=list)
    trigger_conditions: str
    technological_dependencies: List[str] = Field(default_factory=list)
    known_mitigations: List[str] = Field(default_factory=list)
    regulatory_requirements: List[str] = Field(default_factory=list)
    operational_priority: int = Field(..., ge=1, le=5)
    source_reference: List[str] = Field(default_factory=list)
    provenance: List[str] = Field(default_factory=list)
    related_risks: List[str] = Field(default_factory=list)
    categories: List[str] = Field(default_factory=list)
    energy_context: List[str] = Field(default_factory=list)
    version: str
    stable_id: Optional[str] = None
    merge_hash: Optional[str] = None

    @validator("stable_id", always=True)
    def set_stable_id(cls, v: Optional[str], values: Dict[str, Any]) -> str:
        return v or values.get("risk_name", "").strip()


class RiskBase(BaseModel):
    risk_id: str = Field(..., regex=RISK_ID_PATTERN)
    status: Optional[str] = None
    version: Optional[str] = None
    card: RiskCard

    @validator("card")
    def align_stable_id(cls, value: RiskCard, values: Dict[str, Any]) -> RiskCard:
        risk_id = values.get("risk_id")
        if risk_id:
            value.stable_id = risk_id
        return value


class RiskCreate(RiskBase):
    pass


class RiskUpdate(BaseModel):
    status: Optional[str] = None
    version: Optional[str] = None
    card: Optional[RiskCard] = None


class RiskPatch(BaseModel):
    status: Optional[str]
    version: Optional[str]
    card_updates: Optional[Dict[str, Any]]

    @validator("card_updates")
    def ensure_updates(cls, v: Optional[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        return v


class RiskResponse(BaseModel):
    risk_id: str
    status: Optional[str]
    version: Optional[str]
    card: RiskCard
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True


class RiskBrief(BaseModel):
    risk_id: str
    risk_name: str
    impact_level: int
    impact_dimensions: List[str]
