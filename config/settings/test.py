from .base import *  # noqa: F403

# Use SQLite for testing
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    },
}

# Disable password hashing to speed up tests
PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.MD5PasswordHasher",
]

# Disable logging during tests
LOGGING = {
    "version": 1,
    "disable_existing_loggers": True,
}

# Use test cache backend
CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
    },
}

# Celery settings for testing
CELERY_TASK_ALWAYS_EAGER = True
