"""Django's command-line utility for administrative tasks.

Usage:
    ENV=dev python manage.py runserver
    ENV=test pytest
Notes:
- We use ENV (uppercase) by convention, but we also accept env (lowercase) as an alias.
- Settings module resolves to: config.settings.<ENV>
"""

import os
import sys


def _get_env_name(default: str = "dev") -> str:
    return os.getenv("ENV") or os.getenv("env") or default


def main() -> None:
    """Run administrative tasks."""
    env_name = _get_env_name()
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
