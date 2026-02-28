#!/usr/bin/env bash
set -euo pipefail

echo "[web] Waiting for database..."
python scripts/wait_for_db.py

# Optional auto-migrate (default: enabled)
AUTO_MIGRATE="${AUTO_MIGRATE:-1}"
if [[ "$AUTO_MIGRATE" == "1" ]]; then
  echo "[web] Applying migrations..."
  python manage.py migrate
else
  echo "[web] AUTO_MIGRATE=0 -> skipping migrations"
fi

echo "[web] Starting Django dev server..."
python manage.py runserver 0.0.0.0:8000
