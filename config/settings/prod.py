"""
prod.py

Production-specific settings.
"""

from .base import *
from .logging import *
from .restframework import *

DEBUG = False

ALLOWED_HOSTS = env.list("ALLOWED_HOSTS", default=["yourdomain.com"])

# Security settings
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_SSL_REDIRECT = True

# HSTS
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
