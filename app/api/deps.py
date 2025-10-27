from typing import Generator, Optional

from fastapi import Depends, Header, HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.session import get_session


def get_db() -> Generator[Session, None, None]:
    with get_session() as session:
        yield session


def enforce_api_token(x_api_key: Optional[str] = Header(default=None)) -> None:
    if settings.api_token and settings.api_token != x_api_key:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or missing API token")
