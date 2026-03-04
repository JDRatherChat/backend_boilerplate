SHELL := /bin/bash
.DEFAULT_GOAL := help

# ============================================================================== 
# API-first hybrid workflow
# - Local venv: IDE + tooling (ruff/black/pytest/pre-commit)
# - Docker: optional runtime (web + postgres)
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
PRECOMMIT    := $(PY) -m pre_commit

# Active Django environment (maps to config.settings.<ENV>)
ENV ?= dev

# Env files (used by both local runs and Docker)
ENV_DIR := environments

.PHONY: help \
	venv requirements sync install \
	env-fix secret secret-rotate \
	makemigrations migrate runserver shell shell-plus \
	format lint lint-fix test clean \
	pre-commit-install pre-commit-run \
	docker-up docker-down docker-logs \
	d-shell d-manage d-makemigrations d-migrate d-test d-startapp

help: ## Show available targets
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## ' $(MAKEFILE_LIST) | sed 's/:.*##/\t-/' | sort

# ==============================================================================
# Local venv + deps
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

sync: venv ## Install pinned deps (dev includes base)
	@echo "Syncing pinned dependencies from requirements/dev.txt ..."
	$(PIP_SYNC) requirements/dev.txt
	@echo "Dependencies installed"

install: sync ## Bootstrap local dev environment (alias)

# ==============================================================================
# Env utilities
# ==============================================================================

env-fix: ## Create env files from examples if missing (does not overwrite)
	@mkdir -p $(ENV_DIR)
	@[ -f $(ENV_DIR)/base.env ]       || cp $(ENV_DIR)/base.env.example       $(ENV_DIR)/base.env
	@[ -f $(ENV_DIR)/dev.env ]        || cp $(ENV_DIR)/dev.env.example        $(ENV_DIR)/dev.env
	@[ -f $(ENV_DIR)/dev_docker.env ] || cp $(ENV_DIR)/dev_docker.env.example $(ENV_DIR)/dev_docker.env
	@[ -f $(ENV_DIR)/test.env ]       || cp $(ENV_DIR)/test.env.example       $(ENV_DIR)/test.env
	@echo "Ensured env files exist (copied from examples if missing)."

secret: venv ## Ensure SECRET_KEY exists in base.env (does not overwrite)
	@mkdir -p $(ENV_DIR)
	@touch $(ENV_DIR)/base.env
	@if grep -q '^SECRET_KEY=' $(ENV_DIR)/base.env; then \
		echo "SECRET_KEY already present in $(ENV_DIR)/base.env (leaving as-is)"; \
	else \
		SECRET=$$($(PY) -c "import secrets; alphabet='abcdefghijklmnopqrstuvwxyz0123456789!@#$$%^&*(-_=+)'; print(''.join(secrets.choice(alphabet) for _ in range(50)))"); \
		printf 'SECRET_KEY="%s"\n' "$$SECRET" >> $(ENV_DIR)/base.env; \
		echo "Added SECRET_KEY to $(ENV_DIR)/base.env"; \
	fi

secret-rotate: venv ## Rotate SECRET_KEY in base.env (overwrites existing)
	@mkdir -p $(ENV_DIR)
	@touch $(ENV_DIR)/base.env
	@sed -i.bak '/^SECRET_KEY=/d' $(ENV_DIR)/base.env || true
	@SECRET=$$($(PY) -c "import secrets; alphabet='abcdefghijklmnopqrstuvwxyz0123456789!@#$$%^&*(-_=+)'; print(''.join(secrets.choice(alphabet) for _ in range(50)))"); \
	printf 'SECRET_KEY="%s"\n' "$$SECRET" >> $(ENV_DIR)/base.env
	@rm -f $(ENV_DIR)/base.env.bak
	@echo "Rotated SECRET_KEY in $(ENV_DIR)/base.env"

# ==============================================================================
# Local Django commands (uses your machine + local Postgres)
# ==============================================================================

makemigrations: venv env-fix ## Local: create migrations
	ENV=$(ENV) $(PY) manage.py makemigrations

migrate: venv env-fix ## Local: apply migrations
	ENV=$(ENV) $(PY) manage.py migrate

runserver: venv env-fix ## Local: run Django server
	ENV=$(ENV) $(PY) manage.py runserver

shell: venv env-fix ## Local: Django shell
	ENV=$(ENV) $(PY) manage.py shell

shell-plus: venv env-fix ## Local: django-extensions shell_plus
	ENV=$(ENV) $(PY) manage.py shell_plus

# ==============================================================================
# Quality + tests
# ==============================================================================

format: venv ## Local: format with black + ruff
	$(BLACK) .
	$(RUFF) check . --fix

lint: venv ## Local: lint with ruff + black check
	$(RUFF) check .
	$(BLACK) --check .

lint-fix: venv ## Local: lint with fixes
	$(RUFF) check . --fix

pre-commit-install: venv ## Local: install git hooks
	$(PRECOMMIT) install

pre-commit-run: venv ## Local: run all hooks
	$(PRECOMMIT) run --all-files

test: venv env-fix ## Local: run pytest (Postgres; uses environments/test.env if present)
	ENV=test $(PYTEST)

clean: ## Remove caches
	rm -rf .pytest_cache .ruff_cache __pycache__ */__pycache__ */*/__pycache__
	rm -rf .mypy_cache

# ==============================================================================
# Docker stack (optional)
# ==============================================================================

docker-up: env-fix ## Build and start docker services
	docker compose up --build

docker-down: ## Stop docker services
	docker compose down

docker-logs: ## Follow docker logs
	docker compose logs -f

# ==============================================================================
# Docker-native Django commands
# ==============================================================================

d-shell: ## Docker: shell into web container
	docker compose exec web bash

d-manage: ## Docker: run manage.py inside web container: make d-manage ARGS="migrate"
	docker compose exec -e ENV=$(ENV) web python manage.py $(ARGS)

d-makemigrations: ## Docker: create migrations
	docker compose exec -e ENV=$(ENV) web python manage.py makemigrations

d-migrate: ## Docker: apply migrations
	docker compose exec -e ENV=$(ENV) web python manage.py migrate

d-test: ## Docker: run pytest inside container
	docker compose exec -e ENV=test web pytest

d-startapp: ## Docker: create app under apps/: make d-startapp APP=users
	@test -n "$(APP)" || (echo "APP is required (example: make d-startapp APP=users)" && exit 1)
	docker compose exec web python manage.py startapp $(APP) apps/$(APP)
