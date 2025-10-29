import os
from functools import lru_cache
from typing import Optional

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "EnergyGuard Risk DB"
    database_url: str = Field(
        default="postgresql+psycopg2://postgres:postgres@localhost:5432/energy_guard"
    )
    api_prefix: str = "/"
    default_limit: int = 50
    max_limit: int = 200
    export_dir: str = Field(default=os.path.join(os.getcwd(), "exports"))
    export_retention_days: int = 14
    api_token: Optional[str] = Field(default=None)
    provenance_editor: str = Field(default="unknown")
    provenance_domain: Optional[str] = None

    model_config = SettingsConfigDict(env_file=".env", case_sensitive=False)

    @field_validator("export_dir")
    def ensure_export_dir(cls, value: str) -> str:
        os.makedirs(value, exist_ok=True)
        return value


@lru_cache()
def get_settings() -> Settings:
    return Settings()


def reload_settings(**overrides: str) -> Settings:
    for key, value in overrides.items():
        if value is not None:
            os.environ[key.upper()] = value
    get_settings.cache_clear()  # type: ignore[attr-defined]
    global settings
    settings = get_settings()
    return settings


settings = get_settings()
