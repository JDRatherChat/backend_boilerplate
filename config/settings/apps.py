"""Installed app groups.

We keep apps grouped so settings remain readable.
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
    "rest_framework_simplejwt",
    "drf_spectacular",
    "djoser",
    "corsheaders",
]

LOCAL_APPS = [
    "apps.custom_user",  # your app package
]

