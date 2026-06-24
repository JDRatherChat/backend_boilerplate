SHELL := /bin/bash
.DEFAULT_GOAL := help

# ==============================================================================
# API-first hybrid workflow
# - Local venv: IDE + tooling (ruff/pytest/pre-commit)
# - Docker: optional runtime (web + postgres)
# ==============================================================================

UV := uv
ENV ?= dev
ENV_DIR := environments

.PHONY: help \
	install lock upgrade \
	env-fix secret secret-rotate \
	makemigrations migrate runserver shell shell-plus \
	format lint \
	pre-commit-install pre-commit-run \
	test clean \
	docker-up docker-down docker-logs \
	d-shell d-manage d-makemigrations d-migrate d-test d-startapp

help: ## Show available targets
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## ' $(MAKEFILE_LIST) | sed 's/:.*##/\t-/' | sort

# ==============================================================================
# Dependencies (uv)
# ==============================================================================

install: ## Bootstrap local dev environment
	$(UV) sync --dev

lock: ## Recompile uv.lock from pyproject.toml (pin all deps)
	$(UV) lock

upgrade: ## Upgrade all deps to latest allowed versions and relock
	$(UV) lock --upgrade

# ==============================================================================
# Env utilities (unchanged)
# ==============================================================================

env-fix: ## Create env files from examples if missing
	@mkdir -p $(ENV_DIR)
	@[ -f $(ENV_DIR)/base.env ]       || cp $(ENV_DIR)/base.env.example       $(ENV_DIR)/base.env
	@[ -f $(ENV_DIR)/dev.env ]        || cp $(ENV_DIR)/dev.env.example        $(ENV_DIR)/dev.env
	@[ -f $(ENV_DIR)/dev_docker.env ] || cp $(ENV_DIR)/dev_docker.env.example $(ENV_DIR)/dev_docker.env
	@[ -f $(ENV_DIR)/test.env ]       || cp $(ENV_DIR)/test.env.example       $(ENV_DIR)/test.env
	@echo "Ensured env files exist."

secret: ## Ensure SECRET_KEY exists in base.env (does not overwrite)
	@mkdir -p $(ENV_DIR)
	@touch $(ENV_DIR)/base.env
	@if grep -q '^SECRET_KEY=' $(ENV_DIR)/base.env; then \
		echo "SECRET_KEY already present (leaving as-is)"; \
	else \
		SECRET=$$($(UV) run python -c "import secrets; alphabet='abcdefghijklmnopqrstuvwxyz0123456789!@#$$%^&*(-_=+)'; print(''.join(secrets.choice(alphabet) for _ in range(50)))"); \
		printf 'SECRET_KEY="%s"\n' "$$SECRET" >> $(ENV_DIR)/base.env; \
		echo "Added SECRET_KEY to $(ENV_DIR)/base.env"; \
	fi

secret-rotate: ## Rotate SECRET_KEY in base.env
	@mkdir -p $(ENV_DIR)
	@touch $(ENV_DIR)/base.env
	@sed -i.bak '/^SECRET_KEY=/d' $(ENV_DIR)/base.env || true
	@SECRET=$$($(UV) run python -c "import secrets; alphabet='abcdefghijklmnopqrstuvwxyz0123456789!@#$$%^&*(-_=+)'; print(''.join(secrets.choice(alphabet) for _ in range(50)))"); \
	printf 'SECRET_KEY="%s"\n' "$$SECRET" >> $(ENV_DIR)/base.env
	@rm -f $(ENV_DIR)/base.env.bak
	@echo "Rotated SECRET_KEY."

# ==============================================================================
# Local Django commands
# ==============================================================================

makemigrations: env-fix ## Local: create migrations
	ENV=$(ENV) $(UV) run manage.py makemigrations

migrate: env-fix ## Local: apply migrations
	ENV=$(ENV) $(UV) run manage.py migrate

runserver: env-fix ## Local: run Django dev server
	ENV=$(ENV) $(UV) run manage.py runserver

shell: env-fix ## Local: Django shell
	ENV=$(ENV) $(UV) run manage.py shell

shell-plus: env-fix ## Local: shell_plus (django-extensions)
	ENV=$(ENV) $(UV) run manage.py shell_plus

# ==============================================================================
# Code quality
# ==============================================================================

format: ## Format with ruff format + auto-fix lint
	$(UV) run ruff format .
	$(UV) run ruff check . --fix

lint: ## Check formatting and linting
	$(UV) run ruff format --check .
	$(UV) run ruff check .

pre-commit-install: ## Install git hooks
	$(UV) run pre-commit install

pre-commit-run: ## Run all pre-commit hooks
	$(UV) run pre-commit run --all-files

test: env-fix ## Run pytest
	ENV=test $(UV) run pytest

clean: ## Remove caches
	rm -rf .pytest_cache .ruff_cache __pycache__ */__pycache__ */*/__pycache__ .mypy_cache

# ==============================================================================
# Docker stack (keep existing targets unchanged below this line)
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
