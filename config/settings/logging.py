"""Logging configuration.

Default posture:
- Human-readable logs in DEBUG.
- JSON logs otherwise (works well with Docker + cloud log aggregation).

Override with DJANGO_LOG_FORMAT=human|json.
"""

import os


def _truthy(value: str | None) -> bool:
    return str(value or "").strip().lower() in {"1", "true", "yes", "y", "on"}


DEBUG = _truthy(os.getenv("DEBUG"))
LOG_FORMAT = (os.getenv("DJANGO_LOG_FORMAT") or ("human" if DEBUG else "json")).lower()

LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "verbose": {
            "format": "[{levelname}] {asctime} {name} | {message}",
            "style": "{",
        },
        "json": {
            "()": "pythonjsonlogger.jsonlogger.JsonFormatter",
            # Keep field names stable for log ingestion.
            "fmt": "%(levelname)s %(asctime)s %(name)s %(message)s",
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "json" if LOG_FORMAT == "json" else "verbose",
        },
    },
    "root": {
        "handlers": ["console"],
        "level": os.getenv("DJANGO_LOG_LEVEL", "INFO"),
    },
}
