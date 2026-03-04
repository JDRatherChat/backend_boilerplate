"""WSGI config for the project.

Runtime selection:
- Uses ENV (or env) to choose config.settings.<ENV>
- Loads env vars from environments/base.env + environments/<ENV>.env
"""

from __future__ import annotations

import os

from django.core.wsgi import get_wsgi_application

from config.env import load_env_files


env_name = load_env_files()
os.environ.setdefault("DJANGO_SETTINGS_MODULE", f"config.settings.{env_name}")

application = get_wsgi_application()
