"""
base.py

Base Django settings shared across all environments.
"""

import os
from pathlib import Path

import environ

from .apps import DJANGO_APPS, LOCAL_APPS, THIRD_PARTY_APPS

# Directories
BASE_DIR = Path(__file__).resolve().parent.parent.parent
APPS_DIR = BASE_DIR / "apps"

# Load environment variables
env = environ.Env(
    DEBUG=(bool, False),
    SECRET_KEY=(str, "changeme"),
    ALLOWED_HOSTS=(list, []),
)
environ.Env.read_env(os.path.join(BASE_DIR, "environments", "base.env"))

# Core settings
DEBUG = env.bool("DEBUG")
SECRET_KEY = env("SECRET_KEY")
ALLOWED_HOSTS = env.list("ALLOWED_HOSTS", default=[])

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS

INSTALLED_APPS += [
    "health_check",
    "health_check.db",
    "health_check.cache",
    "health_check.storage",
    "health_check.contrib.migrations",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"

DATABASES = {"default": env.db(default="sqlite:///db.sqlite3")}

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
        "OPTIONS": {
            "min_length": 10,
        },
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]

LANGUAGE_CODE = "en-us"
TIME_ZONE = os.getenv("TIME_ZONE", "Africa/Johannesburg")
USE_I18N = True
USE_TZ = True

STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "static"
MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "media"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

AUTH_USER_MODEL = "custom_user.CustomUser"

# Security Settings
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_HSTS_SECONDS = 31536000
SECURE_SSL_REDIRECT = not DEBUG
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

# Session Security
SESSION_COOKIE_SECURE = not DEBUG
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "Lax"
CSRF_COOKIE_SECURE = not DEBUG
CSRF_COOKIE_HTTPONLY = True
CSRF_COOKIE_SAMESITE = "Lax"

# Django Axes Configuration
AXES_ENABLED = True
AXES_FAILURE_LIMIT = 5
AXES_LOCK_OUT_AT_FAILURE = True
AXES_COOLOFF_TIME = 1  # hours
AXES_USE_USER_AGENT = True
AXES_LOCKOUT_TEMPLATE = "account/locked.html"

# Add SecurityHeadersMiddleware
MIDDLEWARE += [
    "axes.middleware.AxesMiddleware",
    "apps.core.middleware.SecurityHeadersMiddleware",
]

# Rate Limiting
RATELIMIT_ENABLE = True
RATELIMIT_USE_CACHE = "default"
RATELIMIT_IP_META_KEY = "HTTP_X_FORWARDED_FOR"

# Health Check Configuration
HEALTH_CHECK = {
    "DISK_USAGE_MAX": 90,  # percent
    "MEMORY_MIN": 100,  # in MB
}

# Keep this import at the end to allow security overrides, but silence linters.
from .security import *  # noqa: E402,F403
