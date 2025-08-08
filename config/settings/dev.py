from importlib import import_module

from .base import INSTALLED_APPS, MIDDLEWARE

# Optional dynamic app/middleware injection (you had this logic before)
# Add apps dynamically in dev without modifying base settings
DJANGO_APPS = getattr(import_module("apps.core"), "INSTALLED_APPS", [])
for app_path, middleware_path in DJANGO_APPS:
    *_, app_label = app_path.rsplit(".", 1)
    if app_label not in INSTALLED_APPS:
        INSTALLED_APPS.append(app_label)

    if middleware_path and middleware_path not in MIDDLEWARE:
        MIDDLEWARE.append(middleware_path)
