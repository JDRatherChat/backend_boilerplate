"""
WSGI config for the project.

Exposes the WSGI callable as a module-level variable named `application`.

Runtime selection:
- Uses ENV (or env) to choose config.settings.<ENV>
"""

import os

from django.core.wsgi import get_wsgi_application


def _get_env_name(default: str = "dev") -> str:
    return os.getenv("ENV") or os.getenv("env") or default


env_name = _get_env_name()
os.environ.setdefault("DJANGO_SETTINGS_MODULE", f"config.settings.{env_name}")

application = get_wsgi_application()
