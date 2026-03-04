"""Test settings.

This template is Postgres-first, including tests.
Configure DATABASE_URL in environments/test.env (or via CI env vars).
"""

from config.env import load_env_files

load_env_files("test")

from .base import *  # noqa: F403,F401

# Database (Postgres)
DATABASES = {"default": env.db("DATABASE_URL")}  # noqa: F405

# Speed up tests: faster password hashing
PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.MD5PasswordHasher",
]

# Reduce noise in test output
LOGGING = {
    "version": 1,
    "disable_existing_loggers": True,
}

# Local memory cache for tests
CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
    }
}

# Celery (if enabled in a future profile): run tasks eagerly during tests
CELERY_TASK_ALWAYS_EAGER = True
