# Contributing to NEXUS Platform

Thank you for your interest in contributing to the NEXUS Platform! This document provides guidelines and instructions for contributing.

## Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please be respectful and constructive in all interactions.

## How to Contribute

### Reporting Bugs

1. **Check existing issues** to avoid duplicates
2. **Create a new issue** with:
   - Clear, descriptive title
   - Detailed description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Python version, etc.)
   - Screenshots if applicable

### Suggesting Enhancements

1. **Check existing issues** for similar suggestions
2. **Create an enhancement issue** with:
   - Clear description of the enhancement
   - Use cases and benefits
   - Possible implementation approach
   - Any potential drawbacks

### Pull Requests

#### Before Submitting

1. **Fork the repository**
2. **Create a feature branch** from `develop`
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Follow coding standards** (see below)
4. **Write tests** for new functionality
5. **Update documentation** as needed
6. **Run tests and linters** locally

#### Submission Process

1. **Commit your changes** with clear messages
   ```bash
   git commit -m "feat: add new feature"
   ```

2. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create Pull Request** with:
   - Clear title and description
   - Reference to related issues
   - List of changes made
   - Screenshots for UI changes
   - Test results

4. **Wait for review** and address feedback

## Coding Standards

### Python

#### Style Guide

- Follow **PEP 8** style guide
- Use **Black** for code formatting (line length: 100)
- Use **isort** for import sorting
- Maximum line length: 100 characters
- Use 4 spaces for indentation

#### Type Hints

```python
from typing import Dict, List, Optional

def process_data(items: List[str], config: Optional[Dict] = None) -> bool:
    """Process items with optional configuration.
    
    Args:
        items: List of items to process
        config: Optional configuration dictionary
        
    Returns:
        True if successful, False otherwise
    """
    pass
```

#### Docstrings

Use Google-style docstrings:

```python
def complex_function(param1: str, param2: int) -> Dict[str, Any]:
    """One-line summary of function.
    
    Longer description if needed. Explain the purpose,
    behavior, and any important details.
    
    Args:
        param1: Description of first parameter
        param2: Description of second parameter
        
    Returns:
        Dictionary containing results with keys:
            - 'status': Operation status
            - 'data': Result data
            
    Raises:
        ValueError: If param1 is empty
        RuntimeError: If operation fails
        
    Example:
        >>> result = complex_function("test", 42)
        >>> print(result['status'])
        'success'
    """
    pass
```

#### Testing

```python
import pytest
from unittest.mock import Mock, patch

@pytest.mark.unit
def test_function_behavior():
    """Test specific function behavior."""
    result = my_function("input")
    assert result == "expected"

@pytest.mark.integration
async def test_async_integration():
    """Test async integration."""
    result = await async_function()
    assert result is not None
```

### Shell Scripts

#### Style Guide

- Use **ShellCheck** for linting
- Follow **Google Shell Style Guide**
- Use `#!/usr/bin/env bash` or `#!/usr/bin/env zsh`
- Include `set -euo pipefail` for error handling
- Use `readonly` for constants
- Quote variables: `"${variable}"`

#### Structure

```bash
#!/usr/bin/env bash
# Description of script purpose
# Usage: script.sh [options] <arguments>

set -euo pipefail

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION="1.0.0"

# Functions
function main() {
    local input="$1"
    echo "Processing: ${input}"
}

# Entry point
main "$@"
```

### Commit Messages

Follow **Conventional Commits** specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes

#### Examples

```
feat(api): add user authentication endpoint

Implement JWT-based authentication for API endpoints.
Includes login, logout, and token refresh functionality.

Closes #123
```

```
fix(dashboard): resolve memory leak in metrics collection

The metrics collector was not properly cleaning up
event listeners, causing memory to grow over time.

Fixes #456
```

## Testing Requirements

### Required Tests

All pull requests must include:

1. **Unit tests** for new functions/classes
2. **Integration tests** for component interactions
3. **Shell tests** for script changes (using BATS)

### Coverage Requirements

- Minimum **80% code coverage** for Python code
- All critical paths must be tested
- Edge cases should be covered

### Running Tests

```bash
# All tests
pytest

# With coverage
pytest --cov=. --cov-report=html

# Specific test file
pytest tests/unit/test_backend_config.py

# Shell tests
bats tests/shell/*.bats
```

## Code Review Process

### What Reviewers Look For

1. **Correctness**: Does it work as intended?
2. **Tests**: Are there adequate tests?
3. **Style**: Does it follow coding standards?
4. **Documentation**: Is it well documented?
5. **Performance**: Are there performance implications?
6. **Security**: Are there security concerns?

### Review Timeline

- Initial review: Within 2-3 business days
- Follow-up reviews: Within 1-2 business days
- Urgent fixes: Within 24 hours

## Development Environment

See [Development Guide](./docs/guides/DEVELOPMENT.md) for detailed setup instructions.

### Quick Setup

```bash
# Clone repository
git clone https://github.com/Q-T0NLY/zsh.git
cd zsh

# Set up environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements-test.txt

# Install pre-commit hooks
pre-commit install

# Run tests
pytest
```

## Documentation

### Requirements

- Update relevant documentation for any changes
- Add docstrings for new functions/classes
- Update API documentation for endpoint changes
- Add examples for new features

### Documentation Types

- **API Documentation**: `docs/api/API.md`
- **Architecture**: `docs/architecture/ARCHITECTURE.md`
- **Guides**: `docs/guides/`
- **ADRs**: `docs/adr/` (for architectural decisions)

## Security

### Reporting Security Issues

**Do not** create public issues for security vulnerabilities.

Instead:
1. Email security concerns to [security contact]
2. Include detailed description
3. Provide steps to reproduce
4. Allow time for fix before disclosure

### Security Best Practices

- Never commit secrets or credentials
- Use environment variables for sensitive data
- Sanitize user inputs
- Follow OWASP guidelines
- Run security scans before submitting

## Getting Help

- **Documentation**: Check `docs/` directory
- **Issues**: Search existing issues
- **Discussions**: Use GitHub Discussions
- **Chat**: [Community chat link if available]

## Recognition

Contributors will be:
- Listed in `CONTRIBUTORS.md`
- Mentioned in release notes
- Credited in commit history

Thank you for contributing to NEXUS Platform! 🚀
