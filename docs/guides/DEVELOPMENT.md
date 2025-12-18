# Development Setup Guide

## Prerequisites

### Required Software

- **Python**: 3.8 or higher
- **ZSH**: 5.0 or higher
- **Git**: 2.0 or higher
- **Docker**: 20.10 or higher (optional, for containerized development)
- **Docker Compose**: 2.0 or higher (optional)

### Optional Tools

- **VS Code**: Recommended IDE
- **Redis**: For caching (or use Docker)
- **PostgreSQL**: For database (or use Docker)

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/Q-T0NLY/zsh.git
cd zsh
```

### 2. Set Up Python Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # On macOS/Linux
# or
.\venv\Scripts\activate  # On Windows

# Install dependencies
pip install -r requirements-test.txt
```

### 3. Install Pre-commit Hooks

```bash
pip install pre-commit
pre-commit install
```

### 4. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your settings
vim .env
```

### 5. Start Development Services

#### Option A: Docker Compose (Recommended)

```bash
docker-compose up -d
```

#### Option B: Manual Setup

```bash
# Start Redis
redis-server

# Start PostgreSQL (if needed)
# Configure connection in .env
```

### 6. Run Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=. --cov-report=html

# Run specific test file
pytest tests/unit/test_backend_config.py

# Run shell tests
bats tests/shell/*.bats
```

### 7. Run Linters

```bash
# Format code
black .
isort .

# Check code quality
flake8 .
pylint *.py

# Type checking
mypy .

# Security scanning
bandit -r .

# Shell script checking
shellcheck *.sh
```

## Development Workflow

### 1. Create Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes

- Write code following style guide
- Add tests for new functionality
- Update documentation

### 3. Run Quality Checks

```bash
# Run pre-commit hooks
pre-commit run --all-files

# Run tests
pytest

# Run linters
black --check .
flake8 .
```

### 4. Commit Changes

```bash
git add .
git commit -m "feat: add new feature"
```

Commit message format:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `test:` Tests
- `refactor:` Code refactoring
- `style:` Formatting
- `chore:` Maintenance

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## IDE Setup

### VS Code

1. Install recommended extensions:
   - Python
   - Pylance
   - Black Formatter
   - ShellCheck
   - YAML

2. Use workspace settings (`.vscode/settings.json` included)

3. Configure launch configurations for debugging

### PyCharm

1. Open project
2. Configure Python interpreter to use virtualenv
3. Enable pytest as test runner
4. Configure file watchers for Black and isort

## Debugging

### Python Debugging

```python
# Use built-in debugger
import pdb; pdb.set_trace()

# Or use ipdb (better interface)
import ipdb; ipdb.set_trace()
```

### VS Code Debugging

Use the provided launch configurations in `.vscode/launch.json`

### Logging

```python
import logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
logger.debug("Debug message")
```

## Testing

### Unit Tests

```bash
# Run unit tests only
pytest tests/unit/ -v

# Run specific test class
pytest tests/unit/test_backend_config.py::TestSystemInfo -v

# Run with markers
pytest -m "not slow"
```

### Integration Tests

```bash
# Run integration tests
pytest tests/integration/ -v

# Skip slow tests
pytest -m "not slow"
```

### Shell Tests

```bash
# Install BATS
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local

# Run shell tests
bats tests/shell/*.bats
```

## Common Tasks

### Update Dependencies

```bash
pip install --upgrade -r requirements-test.txt
pip freeze > requirements-frozen.txt
```

### Clean Build Artifacts

```bash
# Remove Python artifacts
find . -type d -name __pycache__ -exec rm -rf {} +
find . -type f -name '*.pyc' -delete
find . -type f -name '*.pyo' -delete

# Remove test artifacts
rm -rf .pytest_cache htmlcov .coverage
```

### Database Migrations

```bash
# Create migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

## Troubleshooting

### Import Errors

```bash
# Ensure virtual environment is activated
source venv/bin/activate

# Reinstall dependencies
pip install -r requirements-test.txt
```

### Test Failures

```bash
# Run with verbose output
pytest -vv

# Show print statements
pytest -s

# Stop on first failure
pytest -x
```

### Docker Issues

```bash
# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# View logs
docker-compose logs -f
```

## Resources

- [Python Style Guide](https://pep8.org/)
- [Testing Best Practices](https://docs.pytest.org/en/stable/)
- [Git Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows)
- [Docker Documentation](https://docs.docker.com/)
