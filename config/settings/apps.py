"""
unit.py

Define and organize Django unit into groups:
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
    "custom_user.unit.ConfigConfig",
]

THIRD_PARTY_APPS = []

LOCAL_APPS = [
    "apps.custom_user",
]


# INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS
