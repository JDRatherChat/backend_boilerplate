"""Production settings.

This module intentionally imports everything from base and then applies
production-safe overrides.

Production assumes environment variables are provided by the runtime
(e.g. Docker/ECS). Do not commit secrets.
"""

import os

from .base import *  # noqa: F401,F403


DEBUG = False

# If ALLOWED_HOSTS is not provided, default to empty to avoid accidental exposure.
ALLOWED_HOSTS = env.list("ALLOWED_HOSTS", default=[])

# Security
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_HSTS_SECONDS = int(os.getenv("SECURE_HSTS_SECONDS", "0"))
SECURE_HSTS_INCLUDE_SUBDOMAINS = bool(int(os.getenv("SECURE_HSTS_INCLUDE_SUBDOMAINS", "0")))
SECURE_HSTS_PRELOAD = bool(int(os.getenv("SECURE_HSTS_PRELOAD", "0")))
