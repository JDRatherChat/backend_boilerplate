SHELL := /bin/bash
.DEFAULT_GOAL := help

# ==============================================================================
# Hybrid workflow (recommended):
# - Docker is the runtime (web/worker/db/redis)
# - Local venv is for IDE + fast tooling (ruff/black/pytest) when you want it
#
# You can use either:
#   Option A: .venv symlink/junction -> points at venv/.<name>
#   Option B: Set VENV=venv/.<name> when calling make
# ==============================================================================

# -----------------------------
# Virtualenv-aware tool shims
# -----------------------------
VENV ?= .venv

ifeq ($(OS),Windows_NT)
PY := $(VENV)/Scripts/python.exe
else
PY := $(VENV)/bin/python
endif

PIP          := $(PY) -m pip
PIPTOOLS     := $(PY) -m piptools
PIP_COMPILE  := $(PIPTOOLS) compile
PIP_SYNC     := $(PIPTOOLS) sync
BLACK        := $(PY) -m black
RUFF         := $(PY) -m ruff
PYTEST       := $(PY) -m pytest
DJANGO       := $(PY) manage.py

# Optional: uv helpers (uv must be installed separately)
UV := uv

# -----------------------------
# Env files (Django settings)
# -----------------------------
ENV_DIR      := environments
ENV_FILES    := $(ENV_DIR)/base.env $(ENV_DIR)/dev.env

# sed in-place that works on macOS and Linux (creates .bak we later remove)
SED_INPLACE  := sed -i.bak
RM_BACKUPS   := rm -f *.bak

# -----------------------------
# Phony targets
# -----------------------------
.PHONY: help venv requirements sync install install-dev \
        uv-venv uv-install uv-sync \
        secret secret-rotate env-check env-fix \
        makemigrations migrate runserver shell \
        format lint lint-fix test clean \
        docker-up docker-down docker-logs \
        d-shell d-manage d-makemigrations d-migrate d-test d-startapp

# -----------------------------
# Help
# -----------------------------
help: ## Show available targets
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## ' $(MAKEFILE_LIST) | sed 's/:.*##/\t-/' | sort

# ==============================================================================
# Local venv + tooling (for IDE + fast local checks)
# ==============================================================================

venv: ## Create local virtualenv if missing (defaults to VENV=.venv)
	@if [ -f "$(PY)" ]; then \
		echo "Venv already exists at $(VENV)"; \
	else \
		echo "Creating virtual environment at $(VENV)..."; \
		python -m venv $(VENV); \
		echo "Upgrading pip/setuptools/wheel..."; \
		$(PIP) install -U pip setuptools wheel; \
		echo "Installing pip-tools..."; \
		$(PIP) install -U pip-tools; \
	fi

requirements: venv ## Compile requirements with pip-tools (base.in/dev.in -> base.txt/dev.txt)
	@echo "Compiling base requirements -> requirements/base.txt ..."
	$(PIP_COMPILE) requirements/base.in -o requirements/base.txt
	@echo "Compiling dev requirements  -> requirements/dev.txt ..."
	$(PIP_COMPILE) requirements/dev.in  -o requirements/dev.txt

sync: requirements ## Install pinned deps (dev includes base)
	@echo "Syncing pinned dependencies from requirements/dev.txt ..."
	$(PIP_SYNC) requirements/dev.txt
	@echo "Dependencies installed"

install: sync ## Bootstrap local dev environment (alias)

install-dev: sync ## Same as install (explicit name)

# -----------------------------
# uv (optional)
# -----------------------------
uv-venv: ## Create venv using uv (example: make uv-venv VENV=venv/.acme_portal)
	@command -v $(UV) >/dev/null 2>&1 || (echo "uv not found. Install uv first." && exit 1)
	$(UV) venv $(VENV)

uv-install: ## Install tooling deps using uv + requirements/dev.txt (fast)
	@command -v $(UV) >/dev/null 2>&1 || (echo "uv not found. Install uv first." && exit 1)
	$(UV) pip install -r requirements/dev.txt

uv-sync: uv-venv uv-install ## Convenience: create venv + install deps via uv

# ==============================================================================
# Env utilities (Django env files used by Docker and local runs)
# ==============================================================================

secret: venv ## Ensure each env has a SECRET_KEY (does not overwrite existing)
	@mkdir -p $(ENV_DIR)
	@for f in $(ENV_FILES); do \
		touch $$f; \
		if grep -q '^SECRET_KEY=' $$f; then \
			echo "SECRET_KEY already present in $$f (leaving as-is)"; \
		else \
			SECRET=$$($(PY) -c "import secrets; alphabet='abcdefghijklmnopqrstuvwxyz0123456789!@#$$%^&*(-_=+)'; print(''.join(secrets.choice(alphabet) for _ in range(50)))"); \
			printf 'SECRET_KEY=\"%s\"\n' "$$SECRET" >> $$f; \
			echo "Added SECRET_KEY to $$f"; \
		fi; \
	done

secret-rotate: venv ## Rotate SECRET_KEY in all env files (overwrites existing)
	@mkdir -p $(ENV_DIR)
	@for f in $(ENV_FILES); do \
		touch $$f; \
		$(SED_INPLACE) '/^SECRET_KEY=/d' $$f; \
		SECRET=$$($(PY) -c "import secrets; alphabet='abcdefghijklmnopqrstuvwxyz0123456789!@#$$%^&*(-_=+)'; print(''.join(secrets.choice(alphabet) for _ in range(50)))"); \
		printf 'SECRET_KEY=\"%s\"\n' "$$SECRET" >> $$f; \
		$(RM_BACKUPS); \
		echo "Rotated SECRET_KEY in $$f"; \
	done

env-check: ## Show which env files exist + key variables present
	@echo "Checking env files..."
	@for f in $(ENV_FILES); do \
		if [ -f $$f ]; then \
			echo "✓ $$f"; \
			head -n 20 $$f | sed 's/SECRET_KEY=.*/SECRET_KEY=\"***\"/'; \
		else \
			echo "✗ $$f (missing)"; \
		fi; \
	done

env-fix: ## Create env files from examples if missing (does not overwrite)
	@mkdir -p $(ENV_DIR)
	@[ -f $(ENV_DIR)/base.env ] || cp $(ENV_DIR)/base.env.example $(ENV_DIR)/base.env
	@[ -f $(ENV_DIR)/dev.env ]  || cp $(ENV_DIR)/dev.env.example  $(ENV_DIR)/dev.env
	@echo "Ensured $(ENV_DIR)/base.env and $(ENV_DIR)/dev.env exist (copied from examples if missing)."

# ==============================================================================
# Local Django commands (run on your machine using the local venv)
# ==============================================================================

makemigrations: venv ## Local: create migrations
	$(DJANGO) makemigrations

migrate: venv ## Local: apply migrations
	$(DJANGO) migrate

runserver: venv ## Local: run Django server
	$(DJANGO) runserver

shell: venv ## Local: Django shell
	$(DJANGO) shell

shell-plus: venv ## Local: django-extensions shell_plus
	$(DJANGO) shell_plus

# ==============================================================================
# Local quality + tests (fast feedback)
# ==============================================================================

format: venv ## Local: format with black + ruff
	$(BLACK) .
	$(RUFF) check . --fix

lint: venv ## Local: lint with ruff (no fixes)
	$(RUFF) check .

lint-fix: venv ## Local: lint with fixes
	$(RUFF) check . --fix

test: venv ## Local: run pytest
	$(PYTEST) --ds=config.settings.test

clean: ## Remove caches
	rm -rf .pytest_cache .ruff_cache __pycache__ */__pycache__ */*/__pycache__
	rm -rf .mypy_cache

# ==============================================================================
# Docker stack (runtime source of truth)
# ==============================================================================

docker-up: env-fix ## Build and start docker services
	docker compose up --build

docker-down: ## Stop docker services
	docker compose down

docker-logs: ## Follow docker logs
	docker compose logs -f

# ==============================================================================
# Docker-native Django commands (recommended for migrations/tests that touch DB)
# ==============================================================================

d-shell: ## Docker: shell into web container
	docker compose exec web bash

d-shell-plus: ## Docker: shell_plus inside container
	docker compose exec web python manage.py shell_plus

d-manage: ## Docker: run manage.py inside web container: make d-manage ARGS="migrate"
	docker compose exec web python manage.py $(ARGS)

d-makemigrations: ## Docker: create migrations
	docker compose exec web python manage.py makemigrations

d-migrate: ## Docker: apply migrations
	docker compose exec web python manage.py migrate

d-test: ## Docker: run pytest inside container
	docker compose exec web pytest --ds=config.settings.test

d-startapp: ## Docker: create app under apps/: make d-startapp APP=users
	@test -n "$(APP)" || (echo "APP is required (example: make d-startapp APP=users)" && exit 1)
	docker compose exec web python manage.py startapp $(APP) apps/$(APP)
