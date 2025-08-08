"""
apps.py

Define and organize Django apps into groups:
- DJANGO_APPS
- THIRD_PARTY_APPS
- LOCAL_APPS
"""

DJANGO_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]

# Keep environment-agnostic third-party apps here only.
# Environment-specific apps (like debug_toolbar) should be added in per-env settings (e.g., dev.py).
THIRD_PARTY_APPS = []

LOCAL_APPS = [
    "apps.custom_user",
    # "dashboard",
]
