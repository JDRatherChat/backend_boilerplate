# Django Backend Boilerplate (Hybrid Dev Workflow)

A production-focused Django template with modular settings, Docker runtime, and a **hybrid** local workflow:

- **Docker is the source of truth** for running the app + services (Postgres/Redis/Celery)
- A **local virtualenv** is used for IDE features and fast tooling (lint/format/unit tests) when you want it

This keeps your environment reproducible **without slowing down daily coding**.

---

## What’s included

- Modular settings: `config.settings.{base,dev,test,prod}`
- Postgres + Redis docker stack
- Celery worker container
- `scripts/wait_for_db.py` for reliable DB readiness
- Ruff + Black + Pytest
- Pip-tools workflow (requirements `*.in` -> pinned `*.txt`)
- Example env files (`environments/*.env.example`)

---

## Quick start (new machine)

### 1) Create env files
````bash
make env-fix
make secret
make env-check
````

Edit:
- `environments/base.env` (DB name, secrets, redis, etc.)
- `environments/dev.env` (dev overrides)


### 2) Start runtime stack (Docker)
````bash 
make docker-up
````

App runs at:
- http://localhost:8000

### 3) Run DB/migrations inside Docker (recommended)
````bash
make d-migrate
make d-manage ARGS="createsuperuser"
`````

### 4) Optional: local venv for PyCharm + fast tooling
If you want PyCharm indexing + fast lint/tests locally:
````bash
# Default venv path: .venv (recommended)
make install
make lint
make test
`````

To use your preferred per-project naming:
- create `venv/.<project_name>` and point `.venv` at it, OR
- run make with `VENV=venv/.<project_name>`

Example:
````bash
make install VENV=venv/.acme_portal
make test VENV=venv/.acme_portal
````

---
## Day-to-day commands
### Docker runtime

- Start: ```make docker-up```
- Stop: ```make docker-down```
- Logs: ```make docker-logs```
- Shell into container: ```make d-shell```

### Django (inside Docker)
- Migrate: ```make d-migrate```
- Makemigrations: ```make d-makemigrations```
- Start app: ```make d-startapp APP=users```
- Manage command: ```make d-manage ARGS="createsuperuser"```

### Tooling (local venv)
- Format: ```make format```
- Lint: ```make lint```
- Tests: ```make test```

---
## PyCharm Pro recommended setup (hybrid)
### 1. Interpreter: point PyCharm to your local venv (```.venv``` or ```venv/.<name>```)

### 2. Django support:
   - Settings → Languages & Frameworks → Django
   - Settings module: ```config.settings.dev```
   - Manage.py: ```manage.py```

### 3. Database tool window:
   - Connect to Postgres at ```localhost:${POSTGRES_PORT:-5432}```

Runtime continues to run in Docker; you use local env for editor comfort + quick checks.

---
## Docs
- Setup guide: ```docs/setup_hybrid.md```
- Git cheat sheet: ```docs/git.md```

---
## License

Internal / template use.
