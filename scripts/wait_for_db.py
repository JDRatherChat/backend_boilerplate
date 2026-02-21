"""Wait for the database to become available.

This avoids race conditions in Docker where the app starts before Postgres is ready.

Behaviour:
- If DATABASE_URL points to sqlite, this script exits immediately.
- For Postgres, it retries with backoff and exits non-zero after the timeout.
"""

from __future__ import annotations

import os
import sys
import time
from urllib.parse import urlparse

import psycopg


def _is_sqlite(database_url: str) -> bool:
    return database_url.startswith("sqlite")


def wait_for_postgres(database_url: str, timeout_s: int = 60) -> None:
    """Block until Postgres accepts connections or timeout.

    Args:
        database_url: Connection URL in the form postgres://user:pass@host:port/db
        timeout_s: Total wait time before raising.

    Raises:
        SystemExit: If the DB is not reachable within the timeout.
    """

    parsed = urlparse(database_url)
    host = parsed.hostname or "localhost"
    port = parsed.port or 5432

    deadline = time.time() + timeout_s
    attempt = 0

    while time.time() < deadline:
        attempt += 1
        try:
            # psycopg can consume the full URL directly.
            with psycopg.connect(database_url, connect_timeout=3) as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT 1;")
                return
        except Exception as exc:  # noqa: BLE001
            sleep_s = min(1 + attempt * 0.5, 5)
            print(
                f"[wait_for_db] Postgres not ready at {host}:{port} (attempt {attempt}) -> {exc}. "
                f"Retrying in {sleep_s:.1f}s",
                file=sys.stderr,
            )
            time.sleep(sleep_s)

    raise SystemExit(f"Postgres not reachable after {timeout_s}s")


def main() -> None:
    database_url = os.getenv("DATABASE_URL", "sqlite:///db.sqlite3")
    if _is_sqlite(database_url):
        return
    wait_for_postgres(database_url)


if __name__ == "__main__":
    main()
