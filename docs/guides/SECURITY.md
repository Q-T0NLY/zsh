# Security Best Practices Guide

## Overview

This guide outlines security best practices for the NEXUS Platform development and deployment.

## Code Security

### 1. Input Validation

Always validate and sanitize user inputs:

```python
from typing import Optional
import re

def validate_username(username: str) -> bool:
    """Validate username format.
    
    Args:
        username: Username to validate
        
    Returns:
        True if valid, False otherwise
    """
    # Only alphanumeric and underscore, 3-20 characters
    pattern = r'^[a-zA-Z0-9_]{3,20}$'
    return bool(re.match(pattern, username))

def sanitize_input(user_input: str) -> str:
    """Sanitize user input.
    
    Args:
        user_input: Raw user input
        
    Returns:
        Sanitized input
    """
    # Remove dangerous characters
    dangerous_chars = ['<', '>', '&', '"', "'", '/', '\\']
    sanitized = user_input
    for char in dangerous_chars:
        sanitized = sanitized.replace(char, '')
    return sanitized.strip()
```

### 2. SQL Injection Prevention

Use parameterized queries:

```python
# ❌ BAD - SQL Injection vulnerable (NEVER use this pattern!)
# This example demonstrates a security vulnerability
def get_user_bad(username: str):
    query = f"SELECT * FROM users WHERE username = '{username}'"
    return db.execute(query)

# ✅ GOOD - Safe from SQL injection
def get_user_good(username: str):
    query = "SELECT * FROM users WHERE username = ?"
    return db.execute(query, (username,))
```

### 3. Command Injection Prevention

Avoid shell execution with user input:

```bash
# ❌ BAD - Command injection vulnerable
user_input="$1"
eval "ls -la $user_input"

# ✅ GOOD - Safe parameter handling
user_input="$1"
ls -la -- "${user_input}"
```

Python:
```python
import subprocess
from shlex import quote

# ❌ BAD
def run_command_bad(filename: str):
    os.system(f"cat {filename}")

# ✅ GOOD
def run_command_good(filename: str):
    subprocess.run(['cat', filename], check=True)
```

## Secret Management

### 1. Environment Variables

Store secrets in environment variables, never in code:

```python
import os
from typing import Optional

def get_secret(key: str, default: Optional[str] = None) -> str:
    """Get secret from environment.
    
    Args:
        key: Secret key name
        default: Default value if not found
        
    Returns:
        Secret value
        
    Raises:
        ValueError: If secret not found and no default
    """
    value = os.environ.get(key, default)
    if value is None:
        raise ValueError(f"Secret '{key}' not found")
    return value

# Usage
API_KEY = get_secret('OPENAI_API_KEY')
```

### 2. Configuration Files

```python
# .env (never commit this!)
OPENAI_API_KEY=sk-...
DATABASE_PASSWORD=secure_password
REDIS_PASSWORD=another_secure_password

# Load with python-dotenv
from dotenv import load_dotenv
load_dotenv()
```

### 3. Secret Scanning

Add pre-commit hook to detect secrets:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
```

## Authentication & Authorization

### 1. Password Handling

```python
import hashlib
import secrets
from typing import Tuple

def hash_password(password: str) -> Tuple[str, str]:
    """Hash password with salt.
    
    Args:
        password: Plain text password
        
    Returns:
        Tuple of (salt, hashed_password)
    """
    salt = secrets.token_hex(32)
    hashed = hashlib.pbkdf2_hmac(
        'sha256',
        password.encode('utf-8'),
        salt.encode('utf-8'),
        100000  # iterations
    )
    return salt, hashed.hex()

def verify_password(password: str, salt: str, hashed: str) -> bool:
    """Verify password against hash.
    
    Args:
        password: Plain text password
        salt: Password salt
        hashed: Hashed password
        
    Returns:
        True if password matches
    """
    new_hash = hashlib.pbkdf2_hmac(
        'sha256',
        password.encode('utf-8'),
        salt.encode('utf-8'),
        100000
    )
    return new_hash.hex() == hashed
```

### 2. API Key Generation

```python
import secrets

def generate_api_key(length: int = 32) -> str:
    """Generate secure API key.
    
    Args:
        length: Key length in bytes
        
    Returns:
        Hex-encoded API key
    """
    return secrets.token_hex(length)
```

## Data Protection

### 1. Encryption at Rest

```python
from cryptography.fernet import Fernet

class DataEncryptor:
    """Encrypt and decrypt sensitive data."""
    
    def __init__(self, key: bytes):
        """Initialize encryptor.
        
        Args:
            key: Encryption key
        """
        self.cipher = Fernet(key)
    
    def encrypt(self, data: str) -> bytes:
        """Encrypt data.
        
        Args:
            data: Plain text data
            
        Returns:
            Encrypted data
        """
        return self.cipher.encrypt(data.encode())
    
    def decrypt(self, encrypted: bytes) -> str:
        """Decrypt data.
        
        Args:
            encrypted: Encrypted data
            
        Returns:
            Plain text data
        """
        return self.cipher.decrypt(encrypted).decode()
```

### 2. Secure File Permissions

```bash
# Set restrictive permissions on sensitive files
chmod 600 ~/.ssh/id_rsa
chmod 600 .env

# Check permissions
ls -la ~/.ssh/id_rsa
# Should show: -rw------- (only owner can read/write)
```

## Network Security

### 1. HTTPS/TLS

Always use HTTPS for production:

```python
# Production configuration
if os.environ.get('ENVIRONMENT') == 'production':
    app.config['SESSION_COOKIE_SECURE'] = True
    app.config['SESSION_COOKIE_HTTPONLY'] = True
    app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
```

### 2. CORS Configuration

```python
from flask_cors import CORS

# ❌ BAD - Allows all origins
CORS(app, resources={r"/*": {"origins": "*"}})

# ✅ GOOD - Specific origins only
CORS(app, resources={
    r"/api/*": {
        "origins": ["https://app.example.com"],
        "methods": ["GET", "POST"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})
```

## Container Security

### 1. Dockerfile Best Practices

```dockerfile
# Use specific version, not latest
FROM python:3.11.6-slim

# Run as non-root user
RUN useradd -m -u 1000 appuser
USER appuser

# Don't include secrets in image
# Use environment variables instead

# Scan for vulnerabilities
# docker scan nexus-platform:latest
```

### 2. Docker Compose Security

```yaml
services:
  app:
    # Don't use privileged mode
    privileged: false
    
    # Limit resources
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    
    # Read-only root filesystem
    read_only: true
    
    # Drop capabilities
    cap_drop:
      - ALL
```

## Logging & Monitoring

### 1. Secure Logging

```python
import logging
import re

def sanitize_log_message(message: str) -> str:
    """Remove sensitive data from log messages.
    
    Args:
        message: Log message
        
    Returns:
        Sanitized message
    """
    # Redact API keys
    message = re.sub(r'api[_-]?key[=:]\s*\S+', 'api_key=***', message, flags=re.IGNORECASE)
    # Redact tokens
    message = re.sub(r'token[=:]\s*\S+', 'token=***', message, flags=re.IGNORECASE)
    # Redact passwords
    message = re.sub(r'password[=:]\s*\S+', 'password=***', message, flags=re.IGNORECASE)
    return message

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
```

## Security Checklist

### Development
- [ ] Input validation on all user inputs
- [ ] Parameterized queries for database
- [ ] No secrets in code or version control
- [ ] Dependencies up to date
- [ ] Security linting enabled

### Deployment
- [ ] HTTPS/TLS enabled
- [ ] Secure headers configured
- [ ] Environment variables for secrets
- [ ] Minimal container privileges
- [ ] Security scanning in CI/CD

### Monitoring
- [ ] Audit logging enabled
- [ ] Anomaly detection configured
- [ ] Security alerts set up
- [ ] Regular security reviews
- [ ] Incident response plan

## Tools

### Security Scanning
```bash
# Python code scanning
bandit -r . -ll

# Dependency vulnerability check
safety check

# Docker image scanning
docker scan nexus-platform:latest

# Secret detection
detect-secrets scan
```

### Updates
```bash
# Update Python dependencies
pip list --outdated
pip install --upgrade -r requirements.txt

# Update system packages
apt-get update && apt-get upgrade
```

## Incident Response

### 1. Security Incident Procedure

1. **Detect**: Monitor alerts and logs
2. **Contain**: Isolate affected systems
3. **Investigate**: Analyze the incident
4. **Remediate**: Fix vulnerabilities
5. **Recover**: Restore normal operations
6. **Review**: Post-incident analysis

### 2. Emergency Contacts

- Security Team: [security@example.com]
- On-call Engineer: [See PagerDuty]
- Management: [See escalation matrix]

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [Python Security Best Practices](https://python.readthedocs.io/en/stable/library/security_warnings.html)
