
"""Django project package.

Exposes the Celery app as `config.celery_app`.
"""

from .celery_app import app as celery_app  # noqa: F401

