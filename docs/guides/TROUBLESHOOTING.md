# Troubleshooting Guide

## Overview

This guide helps diagnose and resolve common issues with the NEXUS Platform.

## Installation Issues

### Python Dependencies

**Problem**: `pip install` fails with dependency conflicts

**Solution**:
```bash
# Create fresh virtual environment
rm -rf venv
python3 -m venv venv
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip setuptools wheel

# Install with --no-cache-dir
pip install --no-cache-dir -r requirements-test.txt
```

**Problem**: ImportError for specific modules

**Solution**:
```bash
# Check if module is installed
pip list | grep module-name

# Install missing module
pip install module-name

# Verify Python path
python -c "import sys; print('\n'.join(sys.path))"
```

### Shell Script Issues

**Problem**: Permission denied when running scripts

**Solution**:
```bash
# Make scripts executable
chmod +x *.sh

# Verify permissions
ls -la *.sh

# Run with explicit shell
bash ./install.sh
```

**Problem**: Script fails with "command not found"

**Solution**:
```bash
# Check if command exists
which command-name

# Install missing command (macOS)
brew install command-name

# Install missing command (Ubuntu/Debian)
sudo apt-get install command-name
```

## Runtime Issues

### Python Application

**Problem**: Application fails to start

**Diagnosis**:
```bash
# Check Python version
python --version  # Should be 3.8+

# Test script syntax
python -m py_compile script.py

# Run with verbose logging
python script.py --log-level DEBUG
```

**Problem**: Module import errors at runtime

**Solution**:
```python
# Add project root to Python path
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))
```

### Database Connection

**Problem**: Cannot connect to PostgreSQL

**Diagnosis**:
```bash
# Check if PostgreSQL is running
pg_isready -h localhost -p 5432

# Test connection
psql -h localhost -U postgres -d nexus_dev

# Check connection string
echo $DATABASE_URL
```

**Solution**:
```bash
# Start PostgreSQL (Docker)
docker-compose up -d postgres

# Check logs
docker-compose logs postgres

# Verify credentials in .env
cat .env | grep POSTGRES
```

**Problem**: Cannot connect to Redis

**Diagnosis**:
```bash
# Test Redis connection
redis-cli ping

# Check if Redis is running
docker ps | grep redis

# Test with Python
python -c "import redis; r = redis.Redis(); print(r.ping())"
```

**Solution**:
```bash
# Start Redis
docker-compose up -d redis

# Check Redis logs
docker-compose logs redis

# Verify configuration
redis-cli CONFIG GET maxmemory
```

## Testing Issues

### Pytest Failures

**Problem**: Tests fail with import errors

**Solution**:
```bash
# Ensure PYTHONPATH is set
export PYTHONPATH="${PYTHONPATH}:$(pwd)"

# Install test dependencies
pip install pytest pytest-asyncio pytest-cov

# Run from project root
cd /path/to/project
pytest
```

**Problem**: Async tests fail

**Solution**:
```bash
# Install pytest-asyncio
pip install pytest-asyncio

# Add to pytest.ini
# asyncio_mode = auto

# Mark tests correctly
# @pytest.mark.asyncio
```

**Problem**: Coverage too low

**Diagnosis**:
```bash
# Generate coverage report
pytest --cov=. --cov-report=html

# View coverage report
open htmlcov/index.html

# Check which files are missing coverage
pytest --cov=. --cov-report=term-missing
```

### Shell Tests

**Problem**: BATS tests not found

**Solution**:
```bash
# Install BATS
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local

# Verify installation
bats --version
```

**Problem**: BATS tests fail

**Diagnosis**:
```bash
# Run with verbose output
bats -t tests/shell/test_install.bats

# Run specific test
bats tests/shell/test_install.bats --filter "test name"

# Check script syntax
bash -n script.sh
```

## Performance Issues

### Slow Application

**Diagnosis**:
```bash
# Profile Python application
python -m cProfile -o profile.stats script.py

# Analyze profile
python -c "import pstats; p = pstats.Stats('profile.stats'); p.sort_stats('cumulative').print_stats(20)"

# Check memory usage
python -m memory_profiler script.py
```

**Solution**:
- Enable caching (Redis)
- Optimize database queries
- Use async operations
- Add connection pooling

### High Memory Usage

**Diagnosis**:
```bash
# Monitor memory
docker stats

# Check Python memory
python -c "import psutil; print(f'Memory: {psutil.virtual_memory().percent}%')"

# Profile memory usage
python -m memory_profiler script.py
```

**Solution**:
```python
# Use generators instead of lists
data = (process(item) for item in large_dataset)

# Clear large objects
del large_object
import gc; gc.collect()

# Limit cache size
from functools import lru_cache
@lru_cache(maxsize=128)
def cached_function():
    pass
```

### Slow Database Queries

**Diagnosis**:
```sql
-- PostgreSQL
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';

-- Check slow queries
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;
```

**Solution**:
```sql
-- Add indexes
CREATE INDEX idx_users_email ON users(email);

-- Use connection pooling
-- Optimize queries (avoid SELECT *)
-- Use pagination
```

## Docker Issues

### Container Won't Start

**Diagnosis**:
```bash
# Check container status
docker ps -a

# View logs
docker logs container-name

# Inspect container
docker inspect container-name

# Check resource usage
docker stats
```

**Solution**:
```bash
# Rebuild container
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Remove old containers
docker system prune -a

# Check disk space
df -h
```

### Container Networking

**Problem**: Cannot connect between containers

**Diagnosis**:
```bash
# Check network
docker network ls
docker network inspect nexus-network

# Test connectivity
docker exec container-name ping other-container

# Check DNS
docker exec container-name nslookup other-container
```

**Solution**:
```bash
# Recreate network
docker-compose down
docker network prune
docker-compose up -d

# Use service names in connection strings
# redis://redis:6379 (not localhost)
```

## CI/CD Issues

### GitHub Actions Failures

**Problem**: Tests fail in CI but pass locally

**Diagnosis**:
```bash
# Run tests with same Python version
python3.8 -m pytest

# Check environment variables
env | sort

# Run in clean environment
docker run --rm -it python:3.8 bash
```

**Solution**:
- Ensure dependencies are pinned
- Check environment variables
- Verify Python version matches
- Add missing system dependencies

**Problem**: Security scan finds vulnerabilities

**Solution**:
```bash
# Update dependencies
pip install --upgrade package-name

# Check for updates
pip list --outdated

# Run security scan locally
bandit -r .
safety check
```

## Logging and Debugging

### Enable Debug Logging

```python
import logging

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)
logger.debug("Debug message")
```

### Interactive Debugging

```python
# Using pdb
import pdb; pdb.set_trace()

# Using ipdb (better interface)
import ipdb; ipdb.set_trace()

# Common pdb commands:
# n - next line
# s - step into
# c - continue
# l - list code
# p variable - print variable
# q - quit
```

### Shell Script Debugging

```bash
# Enable debug mode
set -x  # Print commands
set -v  # Print input lines

# Or run with debug flag
bash -x script.sh

# Trace specific section
set -x
# code to debug
set +x
```

## Common Error Messages

### "ModuleNotFoundError: No module named 'X'"

**Solution**:
```bash
pip install X
# or
pip install -r requirements-test.txt
```

### "Permission denied"

**Solution**:
```bash
chmod +x script.sh
# or for directories
chmod -R 755 directory/
```

### "Connection refused"

**Solution**:
- Check if service is running
- Verify host and port
- Check firewall rules
- Ensure correct credentials

### "Port already in use"

**Solution**:
```bash
# Find process using port
lsof -i :8000

# Kill process
kill -9 PID

# Or use different port
export PORT=8001
```

## Getting Help

### Check Logs

```bash
# Application logs
tail -f logs/app.log

# Docker logs
docker-compose logs -f

# System logs
journalctl -u service-name -f
```

### Collect Diagnostic Info

```bash
# System information
uname -a
python --version
docker --version

# Environment
env | sort

# Running processes
ps aux | grep python

# Network
netstat -tulpn
```

### Report Issues

When reporting issues, include:

1. **Environment**: OS, Python version, Docker version
2. **Steps to reproduce**: Exact commands run
3. **Expected vs actual**: What should happen vs what happens
4. **Logs**: Relevant log output
5. **Configuration**: Relevant config files (sanitized)
6. **Stack trace**: Full error message and traceback

## Resources

- [Documentation](../README.md)
- [GitHub Issues](https://github.com/Q-T0NLY/zsh/issues)
- [Development Guide](./DEVELOPMENT.md)
- [Security Guide](./SECURITY.md)
