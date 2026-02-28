# Hybrid Setup Guide (Docker runtime + local venv tooling)

This template supports a **hybrid** development workflow:

- **Docker** runs your services (Django + Postgres + Redis + Celery)
- A **local venv** (optional) is used for:
  - PyCharm interpreter / autocomplete
  - lint/format
  - fast unit tests (when you don't need DB services)

If you prefer, you can run tests/migrations inside Docker using `make d-*` targets.

---

## 1) Prereqs

- Docker Desktop installed & running
- Python 3.12+ installed locally (only needed for optional local venv tooling)
- `make` (recommended)

Verify:
```bash
docker --version
docker compose version
```
---
## 2) Create env files (required)
```bash
make env-fix
make secret
make env-check
```
---
## 3) Start the runtime stack (Docker)
```bash
make docker-up
```

This starts:
- db (Postgres)
- redis (Redis)
- web (Django)
- worker (Celery)

Open:
- http://localhost:8000

---
### 4) Run Django commands in Docker (recommended)

#### Migrations:
```bash
make d-migrate
```

Create a superuser:
```bash
make d-manage ARGS="createsuperuser"
```

Shell:
```bash
make d-shell
```

---
## 5) Optional: local venv for PyCharm + tooling
### A) Use .venv (recommended)
```bash
make install
```

### B) Use a named venv directory
```bash
make install VENV=venv/.acme_portal
make test VENV=venv/.acme_portal
```

If you want a stable .venv for your IDE, create a symlink/junction:
- `.venv` -> `venv/.acme_portal`

---
### 6) Add your first app

Create an app under `apps/` (recommended layout):
```bash
make d-startapp APP=users
```

Register it in `config.settings.apps` (example):
```bash
INSTALLED_APPS += ["apps.users"]
```

Create migrations and migrate:
```bash
make d-makemigrations
make d-migrate
```

---
## 7) Common workflows

### Fast checks (local)
```bash
make lint
make test
```

### DB-backed checks (Docker)
```bash
make d-test
```

---
## 8) Resetting the dev database
<strong>⚠️ This deletes local dev data:</strong>
```bash
docker compose down -v
docker compose up --build
```

---
# One final “settings” note (important)
Because the project uses `scripts/run_web.sh`, make sure the script files are executable in git on Linux/macOS:

```bash
git update-index --chmod=+x scripts/run_web.sh scripts/run_worker.sh
```

(Windows will still run them fine inside the container because Docker uses Linux file semantics, but it’s nice to keep permissions correct.)
