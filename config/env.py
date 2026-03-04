"""Environment loading helpers.

This project follows a simple convention:

- ENV (or env) selects the settings module: config.settings.<ENV>
- We load environment variables from:
    - environments/base.env
    - environments/<ENV>.env

This keeps local, Docker, and CI behavior consistent.
"""

from __future__ import annotations

import os
from pathlib import Path

import environ


def get_env_name(default: str = "dev") -> str:
    """Return the active environment name.

    We use ENV by convention, but accept env (lowercase) as an alias.
    """
    return os.getenv("ENV") or os.getenv("env") or default


def load_env_files(env_name: str | None = None, *, base_dir: Path | None = None) -> str:
    """Load base.env + <ENV>.env (if they exist).

    Returns the resolved env name.
    """
    resolved = env_name or get_env_name()
    project_root = base_dir or Path(__file__).resolve().parent.parent  # .../config -> project root
    env_dir = project_root / "environments"

    for filename in ("base.env", f"{resolved}.env"):
        path = env_dir / filename
        if path.exists():
            environ.Env.read_env(str(path))

    return resolved
