"""Production settings.

This module intentionally imports everything from base and then applies
production-safe overrides.

Production assumes environment variables are provided by the runtime
(e.g. Docker/ECS). Do not commit secrets.
"""

from config.env import load_env_files

load_env_files("prod")

from .base import *  # noqa: F401,F403


DEBUG = False

# If ALLOWED_HOSTS is not provided, default to empty to avoid accidental exposure.
ALLOWED_HOSTS = env.list("ALLOWED_HOSTS", default=[])

# Security
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_HSTS_SECONDS = env.int("SECURE_HSTS_SECONDS", default=0)
SECURE_HSTS_INCLUDE_SUBDOMAINS = env.bool("SECURE_HSTS_INCLUDE_SUBDOMAINS", default=False)
SECURE_HSTS_PRELOAD = env.bool("SECURE_HSTS_PRELOAD", default=False)
