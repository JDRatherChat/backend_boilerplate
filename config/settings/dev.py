# config/settings/dev.py
"""
Development settings — import sensible defaults from base.
This file exists because manage.py currently points to config.settings.dev.
"""

from .base import *  # noqa: F401,F403

# Dev overrides
DEBUG = True
# Allow all hosts for local dev
ALLOWED_HOSTS = ["*"]

# Make sure logging or other dev helpers are ok
# (You can also load .env here if you want)
