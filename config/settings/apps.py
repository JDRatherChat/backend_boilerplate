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
]

THIRD_PARTY_APPS = [
    # e.g. "rest_framework",
]

LOCAL_APPS = [
    "apps.custom_user",  # your app package
]


# INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS./manage.py check
