# config/settings/dev.py
"""
Development settings — import sensible defaults from base.

Hybrid workflow note:
- Docker loads env vars from environments/base.env + environments/dev.env
- Local tooling can also load those files if present
"""

from .base import BASE_DIR, env

import os
import environ

# Optionally load dev env file.
_dev_env = os.path.join(BASE_DIR, "environments", "dev.env")
if os.path.exists(_dev_env):
    environ.Env.read_env(_dev_env)

# Dev overrides (prefer env; fall back to safe dev defaults)
DEBUG = env.bool("DEBUG", default=True)  # noqa: F405
ALLOWED_HOSTS = env.list("ALLOWED_HOSTS", default=["*"])  # noqa: F405