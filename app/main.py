from __future__ import annotations

from apscheduler.schedulers.background import BackgroundScheduler
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import routes
from app.core.config import settings
from app.db.init_db import init_db
from app.db.session import get_session
from app.services.export_service import export_to_files

scheduler: BackgroundScheduler | None = None


def create_app() -> FastAPI:
    application = FastAPI(title=settings.app_name)

    application.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    application.include_router(routes.router)

    @application.on_event("startup")
    def startup() -> None:  # pragma: no cover - side effects
        init_db()
        global scheduler
        scheduler = BackgroundScheduler()
        scheduler.add_job(_daily_export_job, "cron", hour=0, minute=0, id="daily_export", replace_existing=True)
        scheduler.start()

    @application.on_event("shutdown")
    def shutdown() -> None:  # pragma: no cover - side effects
        if scheduler:
            scheduler.shutdown(wait=False)

    return application


def _daily_export_job() -> None:
    with get_session() as session:
        export_to_files(session)


app = create_app()
