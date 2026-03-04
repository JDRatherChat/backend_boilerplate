#!/usr/bin/env bash
set -euo pipefail

echo "[worker] Waiting for database..."
python scripts/wait_for_db.py

LOGLEVEL="${CELERY_LOGLEVEL:-INFO}"
echo "[worker] Starting Celery worker (loglevel=$LOGLEVEL)..."
celery -A config.celery_app worker -l "$LOGLEVEL"