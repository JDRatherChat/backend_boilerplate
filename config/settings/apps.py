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

THIRD_PARTY_APPS = [
    "rest_framework",
]

LOCAL_APPS = [
    "apps.custom_user",
    # "dashboard",
]
