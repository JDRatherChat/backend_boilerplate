"""Django's command-line utility for administrative tasks.

Usage:
    ENV=dev python manage.py runserver
    ENV=test python manage.py migrate
    ENV=prod python manage.py check --deploy

Notes:
- We use ENV (uppercase) by convention, but we also accept env (lowercase) as an alias.
- Settings module resolves to: config.settings.<ENV>
- We load env vars from environments/base.env + environments/<ENV>.env (if present).
"""

from __future__ import annotations

import os
import sys

from config.env import load_env_files


def main() -> None:
    """Run administrative tasks."""
    env_name = load_env_files()
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", f"config.settings.{env_name}")

    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc

    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
