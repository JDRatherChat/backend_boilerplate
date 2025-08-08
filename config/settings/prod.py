"""
Production settings.
"""

import environ

env = environ.Env()

DEBUG = False
ALLOWED_HOSTS = env.list("ALLOWED_HOSTS", default=["yourdomain.com"])
