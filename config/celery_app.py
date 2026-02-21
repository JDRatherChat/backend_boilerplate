"""Celery application entrypoint.

Why this exists:
- Keeps Celery wiring out of settings modules.
- Allows docker-compose to run a worker with a stable import path.

Usage:
    celery -A config.celery_app worker -l INFO
"""

import os

from celery import Celery


os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.dev")

app = Celery("config")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()
