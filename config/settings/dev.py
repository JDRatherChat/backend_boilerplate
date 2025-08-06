"""
dev.py

Development-specific settings.
"""

from .base import *
from .logging import *
from .restframework import *

DEBUG = True

INSTALLED_APPS += [
    "django_extensions",
    "debug_toolbar",
]

MIDDLEWARE += [
    "debug_toolbar.middleware.DebugToolbarMiddleware",
]

INTERNAL_IPS = [
    "127.0.0.1",
]

# Debug Toolbar Config
DEBUG_TOOLBAR_CONFIG = {
    "SHOW_TOOLBAR_CALLBACK": lambda request: True,
    "RESULTS_CACHE_SIZE": 3,
    "SHOW_COLLAPSED": True,
}
