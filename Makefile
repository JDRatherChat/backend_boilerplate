SHELL := /bin/bash
.DEFAULT_GOAL := help

# Environment variables
ENV ?= dev
PYTHON := $(shell [ -f ".venv/bin/python" ] && echo ".venv/bin/python" || echo ".venv/Scripts/python")
DOCKER_COMPOSE := docker-compose
PROJECT_NAME := $(shell basename $(CURDIR))

.PHONY: help
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# ==============================================================================
# Database Commands
# ==============================================================================

db-reset: ## Reset database to a clean state
	@echo "🗑️ Resetting database..."
	$(PYTHON) manage.py reset_db --noinput
	make migrate
	@echo "✅ Database reset complete"

db-backup: ## Backup database
	@echo "💾 Backing up database..."
	@mkdir -p backups
	$(DOCKER_COMPOSE) exec db pg_dump -U postgres postgres > backups/backup-$(shell date +%Y%m%d_%H%M%S).sql
	@echo "✅ Backup complete"

db-restore: ## Restore database from backup file
	@if [ -z "$(file)" ]; then \
		echo "❌ Please specify backup file: make db-restore file=backups/backup.sql"; \
		exit 1; \
	fi
	@echo "📥 Restoring database from $(file)..."
	$(DOCKER_COMPOSE) exec -T db psql -U postgres postgres < $(file)
	@echo "✅ Restore complete"

db-shell: ## Open database shell
	$(DOCKER_COMPOSE) exec db psql -U postgres postgres

# ==============================================================================
# Docker Commands
# ==============================================================================

docker-build: ## Build Docker images
	$(DOCKER_COMPOSE) build

docker-up: ## Start Docker containers
	$(DOCKER_COMPOSE) up -d

docker-down: ## Stop Docker containers
	$(DOCKER_COMPOSE) down

docker-logs: ## View Docker logs
	$(DOCKER_COMPOSE) logs -f

docker-clean: ## Clean Docker resources
	@echo "🧹 Cleaning Docker resources..."
	$(DOCKER_COMPOSE) down -v --remove-orphans
	docker system prune -f
	@echo "✅ Clean complete"

# ==============================================================================
# Deployment Commands
# ==============================================================================

deploy-check: ## Check security requirements
	@echo "🔍 Checking deployment requirements..."
	make lint
	make test
	python manage.py check --deploy
	@echo "✅ Deployment checks passed"

collect-static: ## Collect static files
	@echo "📦 Collecting static files..."
	python manage.py collectstatic --noinput
	@echo "✅ Static files collected"

backup-before-deploy: ## Backup before security
	make db-backup
	@echo "📦 Creating code backup..."
	git archive --format=zip HEAD > backups/code-backup-$(shell date +%Y%m%d_%H%M%S).zip

deploy-prod: deploy-check backup-before-deploy ## Deploy to production
	@echo "🚀 Deploying to production..."
	git push origin main
	# Add your security commands here
	@echo "✅ Deployment complete"

# ==============================================================================
# Maintenance Commands
# ==============================================================================

clear-cache: ## Clear project cache
	@echo "🧹 Clearing cache..."
	$(PYTHON) manage.py clear_cache
	@echo "✅ Cache cleared"

clear-sessions: ## Clear expired sessions
	@echo "🧹 Clearing expired sessions..."
	$(PYTHON) manage.py clearsessions
	@echo "✅ Sessions cleared"

clear-media: ## Clear media files (use with caution)
	@echo "⚠️ This will delete all media files. Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo "🗑️ Clearing media files..."
	rm -rf media/*
	@echo "✅ Media files cleared"

maintenance-on: ## Enable maintenance mode
	@echo "🔧 Enabling maintenance mode..."
	# Add commands to enable maintenance mode
	@echo "✅ Maintenance mode enabled"

maintenance-off: ## Disable maintenance mode
	@echo "🔧 Disabling maintenance mode..."
	# Add commands to disable maintenance mode
	@echo "✅ Maintenance mode disabled"

# ==============================================================================
# Development Shortcuts
# ==============================================================================

dev: ## Start development environment
	make docker-up
	make migrate
	make runserver

clean: ## Clean development environment
	make docker-down
	find . -type d -name "__pycache__" -exec rm -r {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.pyd" -delete
	find . -type f -name ".coverage" -delete
	find . -type d -name "*.egg-info" -exec rm -r {} +
	find . -type d -name "*.egg" -exec rm -r {} +
	find . -type d -name ".pytest_cache" -exec rm -r {} +
	find . -type d -name ".mypy_cache" -exec rm -r {} +
	find . -type d -name ".coverage" -exec rm -r {} +
	rm -rf build/ dist/ .eggs/ *.egg-info .coverage htmlcov/

# Default environment
ENV ?= dev
envfile ?= environments/dev.env
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
setup:
	venv compile
	pre-commit install
	@echo "✅ Setup complete! Activate with: source .venv/bin/activate (or .venv\\Scripts\\activate)"

# Compile requirements
compile:
	@echo "📦 Compiling requirements..."
	@chmod +x scripts/compile-requirements.sh
	@./scripts/compile-requirements.sh
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
	@echo "🔑 Generating Django SECRET_KEY..."
	@touch $(envfile)
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

# Smoke tests
.PHONY: smoke
smoke:
	$(PYTHON) -m pytest tests/smoke/test_urls_smoke.py -v

# Run full test suite
.PHONY: test
test:
	$(PYTHON) -m pytest -v

# Update any direct references:
# Previously: $(PYTHON) -m pytest apps/tests/test_urls.py -v
# Now:       $(PYTHON) -m pytest tests/smoke/test_urls_smoke.py -v

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

# Add these to your existing Makefile

test-unit:
	@echo "🧪 Running unit tests..."
	$(PYTHON) -m pytest -m "unit" --cov=apps --cov-report=term-missing

test-integration:
	@echo "🔄 Running integration tests..."
	$(PYTHON) -m pytest -m "integration" --cov=apps --cov-report=term-missing

test-coverage-html:
	@echo "📊 Generating coverage report..."
	$(PYTHON) -m pytest --cov=apps --cov-report=html
	@echo "✅ Coverage report generated in htmlcov/index.html"

# Documentation commands
docs-serve:
	@echo "📚 Starting documentation server..."
	mkdocs serve

docs-build:
	@echo "📚 Building documentation..."
	mkdocs build

docs-deploy:
	@echo "🚀 Deploying documentation..."
	mkdocs gh-deploy --force

# Add these to your existing Makefile

reset-db:
	@chmod +x scripts/reset_db.sh
	@./scripts/reset_db.sh

lint-all:
	@chmod +x scripts/lint.sh
	@./scripts/lint.sh

create-app:
	@if [ -z "$(name)" ]; then \
		echo "❌ Please specify app name: make create-app name=myapp"; \
		exit 1; \
	fi
	@chmod +x scripts/create_app.sh
	@./scripts/create_app.sh $(name)

shell-plus:
	$(PYTHON) manage.py shell_plus --ipython

dev-setup:
	@echo "🔧 Setting up development environment..."
	make setup
	make migrate
	make create-superuser
	@echo "✅ Development environment ready!"

# Version management commands
.PHONY: version-* changelog release

version-major: ## Bump major version (breaking changes)
	@./scripts/release.sh major

version-minor: ## Bump minor version (new features)
	@./scripts/release.sh minor

version-patch: ## Bump patch version (bug fixes)
	@./scripts/release.sh patch

changelog: ## Generate changelog
	@echo "📝 Generating changelog..."
	cz changelog
	@echo "✅ Changelog updated"

release: ## Interactive release process
	@echo "🚀 Starting release process..."
	@echo "Select version type:"
	@echo "1) Major (breaking changes)"
	@echo "2) Minor (new features)"
	@echo "3) Patch (bug fixes)"
	@read -p "Choice: " choice; \
	case $$choice in \
		1) make version-major ;; \
		2) make version-minor ;; \
		3) make version-patch ;; \
		*) echo "Invalid choice"; exit 1 ;; \
	esac
