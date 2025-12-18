# Makefile for NEXUS Platform
# Automates common development and deployment tasks

.PHONY: help install test lint format clean docker-build docker-up docker-down deploy docs

# Default target
.DEFAULT_GOAL := help

# Variables
PYTHON := python3
PIP := pip3
PYTEST := pytest
DOCKER_COMPOSE := docker-compose
KUBECTL := kubectl
PROJECT_NAME := nexus-platform

## help: Show this help message
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

## install: Install dependencies
install:
	@echo "Installing dependencies..."
	$(PIP) install --upgrade pip setuptools wheel
	$(PIP) install -r requirements-test.txt
	@echo "Installing pre-commit hooks..."
	pre-commit install

## install-dev: Install development dependencies
install-dev: install
	$(PIP) install -e .
	@echo "Development environment ready"

## test: Run all tests
test:
	@echo "Running tests..."
	$(PYTEST) tests/ -v --cov=. --cov-report=html --cov-report=term

## test-unit: Run unit tests only
test-unit:
	@echo "Running unit tests..."
	$(PYTEST) tests/unit/ -v

## test-integration: Run integration tests
test-integration:
	@echo "Running integration tests..."
	$(PYTEST) tests/integration/ -v

## test-shell: Run shell script tests
test-shell:
	@echo "Running shell tests..."
	@if command -v bats >/dev/null 2>&1; then \
		bats tests/shell/*.bats; \
	else \
		echo "BATS not installed. Install with: git clone https://github.com/bats-core/bats-core.git && cd bats-core && sudo ./install.sh /usr/local"; \
	fi

## test-watch: Run tests in watch mode
test-watch:
	$(PYTEST) tests/ -v --cov=. -f

## lint: Run all linters
lint: lint-python lint-shell

## lint-python: Lint Python code
lint-python:
	@echo "Running Python linters..."
	@echo "=== Black (format check) ==="
	black --check --diff .
	@echo "\n=== isort (import check) ==="
	isort --check-only --diff .
	@echo "\n=== Flake8 ==="
	flake8 . --count --statistics
	@echo "\n=== Pylint ==="
	pylint *.py --exit-zero
	@echo "\n=== MyPy ==="
	mypy . --ignore-missing-imports --no-error-summary

## lint-shell: Lint shell scripts
lint-shell:
	@echo "Running ShellCheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		find . -name "*.sh" -not -path "./venv/*" -not -path "./env/*" -exec shellcheck {} +; \
	else \
		echo "ShellCheck not installed. Install with: brew install shellcheck (macOS) or apt-get install shellcheck (Linux)"; \
	fi

## format: Format code with Black and isort
format:
	@echo "Formatting code..."
	black .
	isort .
	@echo "Code formatted"

## security: Run security scans
security:
	@echo "Running security scans..."
	@echo "=== Bandit (Python security) ==="
	bandit -r . -ll -f screen || true
	@echo "\n=== Safety (dependency check) ==="
	safety check || true

## clean: Clean build artifacts and cache
clean:
	@echo "Cleaning build artifacts..."
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name '*.pyc' -delete
	find . -type f -name '*.pyo' -delete
	find . -type d -name '*.egg-info' -exec rm -rf {} + 2>/dev/null || true
	rm -rf .pytest_cache .mypy_cache .coverage htmlcov build dist
	@echo "Clean complete"

## docker-build: Build Docker image
docker-build:
	@echo "Building Docker image..."
	docker build -t $(PROJECT_NAME):latest .
	@echo "Build complete"

## docker-up: Start Docker services
docker-up:
	@echo "Starting Docker services..."
	$(DOCKER_COMPOSE) up -d
	@echo "Services started"
	@echo "Dashboard: http://localhost:5000"
	@echo "API: http://localhost:8000"
	@echo "Grafana: http://localhost:3001"

## docker-down: Stop Docker services
docker-down:
	@echo "Stopping Docker services..."
	$(DOCKER_COMPOSE) down
	@echo "Services stopped"

## docker-logs: View Docker logs
docker-logs:
	$(DOCKER_COMPOSE) logs -f

## docker-ps: List running containers
docker-ps:
	$(DOCKER_COMPOSE) ps

## docker-clean: Clean Docker resources
docker-clean:
	@echo "Cleaning Docker resources..."
	docker-compose down -v
	docker system prune -f
	@echo "Docker cleaned"

## k8s-deploy: Deploy to Kubernetes
k8s-deploy:
	@echo "Deploying to Kubernetes..."
	$(KUBECTL) apply -f k8s/ -n nexus
	@echo "Deployment complete"

## k8s-status: Check Kubernetes deployment status
k8s-status:
	$(KUBECTL) get pods -n nexus
	$(KUBECTL) get svc -n nexus

## k8s-logs: View Kubernetes logs
k8s-logs:
	$(KUBECTL) logs -f deployment/nexus-platform -n nexus

## k8s-delete: Delete Kubernetes deployment
k8s-delete:
	$(KUBECTL) delete -f k8s/ -n nexus

## docs: Build documentation
docs:
	@echo "Building documentation..."
	@if command -v sphinx-build >/dev/null 2>&1; then \
		sphinx-build -b html docs/ docs/_build/; \
		echo "Documentation built: docs/_build/index.html"; \
	else \
		echo "Sphinx not installed. Install with: pip install sphinx sphinx-rtd-theme"; \
	fi

## coverage: Generate and open coverage report
coverage:
	@echo "Generating coverage report..."
	$(PYTEST) --cov=. --cov-report=html
	@if command -v open >/dev/null 2>&1; then \
		open htmlcov/index.html; \
	elif command -v xdg-open >/dev/null 2>&1; then \
		xdg-open htmlcov/index.html; \
	else \
		echo "Coverage report: htmlcov/index.html"; \
	fi

## pre-commit: Run pre-commit hooks
pre-commit:
	pre-commit run --all-files

## ci: Run CI pipeline locally
ci: clean install lint test security
	@echo "CI pipeline complete"

## all: Run all checks
all: clean install lint test security coverage
	@echo "All checks complete"

## version: Show version information
version:
	@echo "NEXUS Platform v4.1.0"
	@echo "Python: $$($(PYTHON) --version)"
	@echo "Pip: $$($(PIP) --version)"
	@if command -v docker >/dev/null 2>&1; then echo "Docker: $$(docker --version)"; fi
	@if command -v $(KUBECTL) >/dev/null 2>&1; then echo "kubectl: $$($(KUBECTL) version --client --short)"; fi
