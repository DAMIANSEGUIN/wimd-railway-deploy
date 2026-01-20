from functools import lru_cache
from pathlib import Path
from typing import Optional

from pydantic import AnyHttpUrl
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    OPENAI_API_KEY: Optional[str] = None
    CLAUDE_API_KEY: Optional[str] = None
    PUBLIC_SITE_ORIGIN: AnyHttpUrl = "https://whatismydelta.com"
    PUBLIC_API_BASE: str = ""
    APP_SCHEMA_VERSION: str = "v1"


_ENV_PATH = Path(__file__).resolve().parent.parent / ".env"


@lru_cache()
def get_settings() -> "Settings":
    env_file = _ENV_PATH if _ENV_PATH.exists() else None
    return Settings(_env_file=env_file)


def get_feature_flag(flag_name: str, default: bool = False) -> bool:
    """Get feature flag value from environment"""
    import os
    val = os.getenv(flag_name, "").lower()
    if val in ("1", "true", "yes", "on"):
        return True
    elif val in ("0", "false", "no", "off"):
        return False
    return default
