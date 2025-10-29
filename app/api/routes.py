from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Response
from fastapi.responses import StreamingResponse
from sqlalchemy.exc import NoResultFound
from sqlalchemy.orm import Session

from app.api.deps import enforce_api_token, get_db
from app.core.config import settings
from app.schemas.risk import RiskBrief, RiskCreate, RiskPatch, RiskResponse, RiskUpdate
from app.services import risk_service
from app.services.export_service import export_csv_stream, export_json_bytes

router = APIRouter()


@router.get("/risks", response_model=List[RiskResponse])
def list_risks(
    q: Optional[str] = None,
    min_impact: Optional[int] = Query(default=None, ge=1, le=5),
    limit: int = Query(default=None, gt=0),
    ids: Optional[str] = Query(default=None),
    db: Session = Depends(get_db),
) -> List[RiskResponse]:
    limit = limit or settings.default_limit
    limit = min(limit, settings.max_limit)
    id_list: Optional[List[str]] = ids.split(",") if ids else None
    return risk_service.get_risks(db, q=q, min_impact=min_impact, limit=limit, ids=id_list)


@router.get("/risks/{risk_id}", response_model=RiskResponse)
def fetch_risk(risk_id: str, db: Session = Depends(get_db)) -> RiskResponse:
    try:
        return risk_service.get_risk(db, risk_id)
    except NoResultFound as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.post("/risks", response_model=RiskResponse, status_code=201, dependencies=[Depends(enforce_api_token)])
def create_risk(
    payload: RiskCreate,
    db: Session = Depends(get_db),
) -> RiskResponse:
    return risk_service.create_risk(db, payload, editor=settings.provenance_editor)


@router.put("/risks/{risk_id}", response_model=RiskResponse, dependencies=[Depends(enforce_api_token)])
def replace_risk(
    risk_id: str,
    payload: RiskUpdate,
    db: Session = Depends(get_db),
) -> RiskResponse:
    try:
        return risk_service.update_risk(db, risk_id, payload, editor=settings.provenance_editor)
    except NoResultFound as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.patch("/risks/{risk_id}", response_model=RiskResponse, dependencies=[Depends(enforce_api_token)])
def partial_update_risk(
    risk_id: str,
    payload: RiskPatch,
    db: Session = Depends(get_db),
) -> RiskResponse:
    try:
        return risk_service.patch_risk(db, risk_id, payload, editor=settings.provenance_editor)
    except NoResultFound as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.get("/risks/brief", response_model=List[RiskBrief])
def brief_risks(
    ids: Optional[str] = Query(default=None),
    db: Session = Depends(get_db),
) -> List[RiskBrief]:
    id_list = ids.split(",") if ids else None
    return risk_service.get_brief(db, id_list)


@router.get("/export/json")
def export_json(db: Session = Depends(get_db)) -> Response:
    payload = export_json_bytes(db)
    return Response(content=payload, media_type="application/json")


@router.get("/export/csv")
def export_csv(db: Session = Depends(get_db)) -> StreamingResponse:
    stream = export_csv_stream(db)
    return StreamingResponse(stream, media_type="text/csv")
