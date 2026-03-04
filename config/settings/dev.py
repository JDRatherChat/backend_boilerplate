# config/settings/dev.py
"""Development settings — import sensible defaults from base.

For ENV=dev, we load:
  - environments/base.env
  - environments/dev.env
"""

from config.env import load_env_files

load_env_files("dev")

from .base import *  # noqa: F403,F401

# Dev overrides (prefer env; fall back to safe dev defaults)
DEBUG = env.bool("DEBUG", default=True)  # noqa: F405
ALLOWED_HOSTS = env.list("ALLOWED_HOSTS", default=["*"])  # noqa: F405
