SHELL := /bin/bash

# Default environment
ENV ?= dev
PYTHON := $(shell [ -f ".venv/bin/python" ] && echo ".venv/bin/python" || echo ".venv/Scripts/python")

.PHONY: runserver makemigrations migrate shell setup compile venv deps format lint test test-fast commit push feature release secret superuser smoke

# Run Django development server
runserver:
	@echo "🚀 Starting Django runserver..."
	$(PYTHON) manage.py runserver

makemigrations:
	@echo "📝 Creating new migrations..."
	$(PYTHON) manage.py makemigrations

migrate:
	@echo "📦 Running database migrations..."
	$(PYTHON) manage.py migrate

shell:
	@echo "🐚 Opening Django shell..."
	$(PYTHON) manage.py shell_plus

# Setup project (new venv)
setup: venv compile
        pre-commit install
        @echo "✅ Setup complete! Activate with: source .venv/bin/activate (or .venv\\Scripts\\activate)"

# Compile requirements
compile:
        @echo "📦 Compiling requirements..."
        @command -v pip-compile >/dev/null || $(PYTHON) -m pip install pip-tools
        pip-compile requirements/base.in requirements/dev.in -o requirements/dev.txt
        @echo "✅ Requirements compiled."

# Create virtual environment and install dependencies
venv:
        @echo "🐍 Creating virtual environment..."
        python -m venv .venv
        $(PYTHON) -m pip install --upgrade pip
        $(PYTHON) -m pip install -r requirements/dev.txt
        @echo "✅ Virtual environment ready."

# Generate a new Django SECRET_KEY and append it to the env file
secret:
	@if [ -z "$(envfile)" ]; then \
		echo "❌ Please specify envfile: make secret envfile=environments/.dev"; \
		exit 1; \
	fi
	@echo "🔑 Generating Django SECRET_KEY..."
	SECRET_KEY=$$($(PYTHON) -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"); \
	if grep -q '^SECRET_KEY=' $(envfile); then \
		sed -i'' -e "s/^SECRET_KEY=.*/SECRET_KEY=$$SECRET_KEY/" $(envfile); \
	else \
		echo "SECRET_KEY=$$SECRET_KEY" >> $(envfile); \
	fi
	@echo "✅ SECRET_KEY updated in $(envfile)"

# Create superuser
superuser:
	@echo "Creating superuser"
	$(PYTHON) manage.py createsuperuser

# Format code
format:
	@echo "🖌️ Formatting code..."
	$(PYTHON) -m black apps config manage.py
	$(PYTHON) -m isort apps config manage.py
	@echo "✅ Formatting complete."

# Lint code
lint:
	@echo "🔍 Linting code..."
	$(PYTHON) -m flake8
	@echo "✅ Linting complete."

# Run tests with coverage
test:
	@echo "🧪 Running tests with coverage..."
	$(PYTHON) -m pytest --cov=apps --cov-report=term-missing
	@echo "✅ Tests complete."

# Run fast tests without coverage
test-fast:
	@echo "⚡ Running fast tests..."
	$(PYTHON) -m pytest
	@echo "✅ Fast tests complete."

smoke:
        @echo "🔥 Running URL smoke tests..."
        $(PYTHON) -m pytest apps/tests/test_urls.py -v

# Commit with quality checks
commit:
	@if [ -z "$(m)" ]; then \
		echo "❌ Please specify a commit message: make commit m='Your message'"; \
		exit 1; \
	fi
	@echo "✨ Running checks before commit..."
	make format
	make lint
	make test-fast
	@pre-commit run --all-files || (echo "❌ Pre-commit fixed files. Please re-stage and run make commit again." && exit 1)
        @git add -A
        @git commit -m "$(m)"
        @echo "✅ Commit created with message: $(m)"

# Bump commit version and push
push:
        @echo "🚀 Bumping commit version and pushing..."
        @if [ ! -f VERSION ]; then echo "0.0.0" > VERSION; fi; \
        version=$$(cat VERSION); \
        IFS='.' read -r rel feat commit <<< $$version; \
        commit=$$((commit + 1)); \
        new_version="$$rel.$$feat.$$commit"; \
        echo $$new_version > VERSION; \
        cz changelog; \
        git add VERSION CHANGELOG.md; \
        if [ -z "$$m" ]; then \
                msg="chore: version $$new_version"; \
        else \
                msg="$$m"; \
        fi; \
        git commit -m "$$msg"; \
        git tag -a "v$$new_version" -m "v$$new_version"; \
        git push; \
        git push origin "v$$new_version"; \
        echo "✅ Pushed v$$new_version"

# Bump feature version and reset commit
feature:
        @echo "✨ Starting new feature version..."
        @if [ ! -f VERSION ]; then echo "0.0.0" > VERSION; fi; \
        version=$$(cat VERSION); \
        IFS='.' read -r rel feat commit <<< $$version; \
        feat=$$((feat + 1)); \
        commit=0; \
        new_version="$$rel.$$feat.$$commit"; \
        echo $$new_version > VERSION; \
        cz changelog; \
        git add VERSION CHANGELOG.md; \
        if [ -z "$$m" ]; then \
                msg="chore: start feature $$new_version"; \
        else \
                msg="$$m"; \
        fi; \
        git commit -m "$$msg"; \
        git tag -a "v$$new_version" -m "v$$new_version"; \
        git push; \
        git push origin "v$$new_version"; \
        echo "✅ Pushed v$$new_version"

# Bump release version and reset feature/commit
release:
        @echo "🎉 Starting new release..."
        @if [ ! -f VERSION ]; then echo "0.0.0" > VERSION; fi; \
        version=$$(cat VERSION); \
        IFS='.' read -r rel feat commit <<< $$version; \
        rel=$$((rel + 1)); \
        feat=0; \
        commit=0; \
        new_version="$$rel.$$feat.$$commit"; \
        echo $$new_version > VERSION; \
        cz changelog; \
        git add VERSION CHANGELOG.md; \
        if [ -z "$$m" ]; then \
                msg="chore: start release $$new_version"; \
        else \
                msg="$$m"; \
        fi; \
        git commit -m "$$msg"; \
        git tag -a "v$$new_version" -m "v$$new_version"; \
        git push; \
        git push origin "v$$new_version"; \
        echo "✅ Pushed v$$new_version"
