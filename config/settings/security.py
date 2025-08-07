"""
Security settings for the project.

This module contains all security-related Django settings and middleware configurations.
These settings follow security best practices and should be included in all environments,
with certain settings enabled only in production.

References:
    - Django Security Documentation: https://docs.djangoproject.com/en/4.2/topics/security/
    - OWASP Top 10: https://owasp.org/www-project-top-ten/
    - Mozilla Web Security Guidelines: https://infosec.mozilla.org/guidelines/web_security
"""

from .base import DEBUG

# Security Middleware Settings
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = "DENY"  # Prevents clickjacking via iframes

# SSL/HTTPS Settings - Enable in production only
if not DEBUG:
    SECURE_SSL_REDIRECT = True
    SECURE_HSTS_SECONDS = 31536000  # 1 year
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

# Content Security Policy (CSP) Settings
CSP_DEFAULT_SRC = ("'self'",)
CSP_STYLE_SRC = ("'self'", "'unsafe-inline'")  # Adjust based on your needs
CSP_SCRIPT_SRC = ("'self'",)
CSP_IMG_SRC = ("'self'", "data:")
CSP_FONT_SRC = ("'self'",)
CSP_CONNECT_SRC = ("'self'",)

# Django-Axes Configuration (Login Attempt Tracking)
AXES_FAILURE_LIMIT = 5  # Number of login attempts before lockout
AXES_COOLOFF_TIME = 1  # Lockout time in hours
AXES_LOCKOUT_TEMPLATE = "security/lockout.html"
AXES_LOCKOUT_URL = "/accounts/locked/"
AXES_ENABLE_ADMIN = True

# Django-Ratelimit Configuration
RATELIMIT_ENABLE = True
RATELIMIT_USE_CACHE = "default"
RATELIMIT_VIEW = "apps.core.views.ratelimited_error"

# Password Validation Settings
AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
        "OPTIONS": {"min_length": 10},
    },
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

# Session Security Settings
SESSION_COOKIE_HTTPONLY = True
CSRF_COOKIE_HTTPONLY = True
SESSION_EXPIRE_AT_BROWSER_CLOSE = True
SESSION_COOKIE_AGE = 3600  # 1 hour (in seconds)
