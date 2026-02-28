from pathlib import Path
from typing import List


DJANGO_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]

THIRD_PARTY_APPS = [
    "django_extensions",
    "rest_framework",
    "rest_framework_simplejwt",
    "drf_spectacular",
    "djoser",
    "corsheaders",
]


def discover_local_apps(base_dir: Path) -> List[str]:
    apps_dir = base_dir / "apps"

    if not apps_dir.exists():
        return []

    discovered: List[str] = []

    for entry in apps_dir.iterdir():
        if not entry.is_dir():
            continue

        if (entry / "__init__.py").exists() and (entry / "apps.py").exists():
            discovered.append(f"apps.{entry.name}")

    return sorted(discovered)


BASE_DIR = Path(__file__).resolve().parents[2]
LOCAL_APPS = discover_local_apps(BASE_DIR)
