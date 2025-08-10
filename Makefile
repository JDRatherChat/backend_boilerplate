SHELL := /bin/bash
.DEFAULT_GOAL := help

# -----------------------------
# Virtualenv-aware tool shims
# -----------------------------
ifeq ($(OS),Windows_NT)
PY := .venv/Scripts/python.exe
else
PY := .venv/bin/python
endif

PIP         := $(PY) -m pip
PIPTOOLS   := $(PY) -m piptools
PIP_COMPILE := $(PIPTOOLS) compile
PIP_SYNC    := $(PIPTOOLS) sync
BLACK       := $(PY) -m black
RUFF        := $(PY) -m ruff
PYTEST      := $(PY) -m pytest
DJANGO      := $(PY) manage.py

# -----------------------------
# Env files
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
        secret secret-rotate env-check env-fix \
        makemigrations migrate runserver shell \
        format lint lint-fix test clean

# -----------------------------
# Help
# -----------------------------
help: ## Show available targets
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | sed 's/:.*##/\t-/' | sort

# -----------------------------
# Environment / Dependencies
# -----------------------------
.venv: ## Create virtual environment if missing
	@echo "Creating virtual environment..."
	python -m venv .venv
	@echo "Upgrading pip, setuptools, and wheel..."
	$(PIP) install -U pip setuptools wheel
	@echo "Installing pip-tools..."
	$(PIP) install -U pip-tools
	@touch .venv
	@echo "Virtual environment ready"

venv: .venv ## Ensure venv exists

requirements: venv ## Compile requirements with pip-tools
	@echo "Compiling base requirements -> requirements/base.txt ..."
	$(PIP_COMPILE) requirements/base.in -o requirements/base.txt
	@echo "Compiling dev requirements  -> requirements/dev.txt ..."
	$(PIP_COMPILE) requirements/dev.in  -o requirements/dev.txt

sync: requirements ## Install pinned deps (base + dev)
	@echo "Syncing pinned dependencies from requirements/dev.txt ..."
	$(PIP_SYNC) requirements/dev.txt
	@echo "Dependencies installed"

install: sync ## Bootstrap dev environment (alias)

install-dev: sync ## Same as install (explicit name)

# -----------------------------
# Env utilities
# -----------------------------
secret: venv ## Ensure each env has a SECRET_KEY (does not overwrite existing)
	@mkdir -p $(ENV_DIR)
	@for f in $(ENV_FILES); do \
		touch $$f; \
		if grep -q '^SECRET_KEY=' $$f; then \
			echo "SECRET_KEY already present in $$f (leaving as-is)"; \
		else \
			SECRET=$$($(PY) -c "import secrets; alphabet='abcdefghijklmnopqrstuvwxyz0123456789!@#$$%^&*(-_=+)'; print(''.join(secrets.choice(alphabet) for _ in range(50)))"); \
			printf 'SECRET_KEY="%s"\n' "$$SECRET" >> $$f; \
			echo "Added SECRET_KEY to $$f"; \
		fi \
	done

secret-rotate: venv ## Force-rotate SECRET_KEY in all env files
	@mkdir -p $(ENV_DIR)
	@SECRET=$$($(PY) -c "import secrets; alphabet='abcdefghijklmnopqrstuvwxyz0123456789!@#$$%^&*(-_=+)'; print(''.join(secrets.choice(alphabet) for _ in range(50)))"); \
	for f in $(ENV_FILES); do \
		touch $$f; \
		if grep -q '^SECRET_KEY=' $$f; then \
			$(SED_INPLACE) 's/^SECRET_KEY=.*/SECRET_KEY="'"$$SECRET"'"/' $$f; \
			echo "Rotated SECRET_KEY in $$f"; \
		else \
			printf 'SECRET_KEY="%s"\n' "$$SECRET" >> $$f; \
			echo "Added SECRET_KEY to $$f"; \
		fi \
	done; \
	$(RM_BACKUPS)

env-check: ## Print env files (quick sanity)
	@echo "--- $(ENV_DIR)/base.env ---"; cat $(ENV_DIR)/base.env || true; echo
	@echo "--- $(ENV_DIR)/dev.env  ---"; cat $(ENV_DIR)/dev.env  || true; echo

env-fix: ## Fix common env issues (e.g., trailing comma in ALLOWED_HOSTS)
	@for f in $(ENV_FILES); do \
		if [ -f $$f ]; then \
			$(SED_INPLACE) 's/^\(ALLOWED_HOSTS=.*\),$$/\1/' $$f; \
		fi \
	done; \
	$(RM_BACKUPS); \
	echo "Normalized ALLOWED_HOSTS lines"

# -----------------------------
# Django commands
# -----------------------------
makemigrations: venv ## Create new migrations
	$(DJANGO) makemigrations

migrate: venv ## Apply database migrations
	$(DJANGO) migrate

runserver: venv ## Start Django development server
	$(DJANGO) runserver

shell: venv ## Open Django shell (plus if installed)
	$(DJANGO) shell_plus || $(DJANGO) shell

# -----------------------------
# Code quality
# -----------------------------
format: venv ## Format code with Black
	$(BLACK) apps config manage.py

lint: venv ## Run Ruff linter
	$(RUFF) check .

lint-fix: venv ## Auto-fix with Ruff
	$(RUFF) check . --fix

# -----------------------------
# Tests
# -----------------------------
test: venv ## Run tests with pytest
	$(PYTEST) --ds=config.settings.test

# -----------------------------
# Utilities
# -----------------------------
clean: ## Remove caches and build artifacts
	@find . -type d -name "__pycache__" -prune -exec rm -rf {} +
	@find . -type d -name ".pytest_cache" -prune -exec rm -rf {} +
	@find . -type d -name ".ruff_cache" -prune -exec rm -rf {} +
	@echo "Clean complete"
