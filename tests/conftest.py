"""
Pytest configuration and shared fixtures.

This module provides reusable fixtures and configuration for all tests.
"""

import os
import sys
import tempfile
import shutil
from pathlib import Path
from typing import Dict, Any, Generator
import pytest
from unittest.mock import Mock, MagicMock

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))


# ============================================================================
# DIRECTORY FIXTURES
# ============================================================================

@pytest.fixture
def temp_dir() -> Generator[Path, None, None]:
    """Create a temporary directory for test isolation.
    
    Yields:
        Path: Path to temporary directory
        
    Example:
        >>> def test_file_creation(temp_dir):
        ...     test_file = temp_dir / "test.txt"
        ...     test_file.write_text("content")
        ...     assert test_file.exists()
    """
    tmp = tempfile.mkdtemp()
    try:
        yield Path(tmp)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


@pytest.fixture
def config_dir(temp_dir: Path) -> Path:
    """Create a temporary config directory structure.
    
    Args:
        temp_dir: Temporary directory fixture
        
    Returns:
        Path: Path to config directory
    """
    config = temp_dir / ".config" / "ultra-zsh"
    config.mkdir(parents=True, exist_ok=True)
    
    # Create subdirectories
    (config / "modules").mkdir(exist_ok=True)
    (config / "plugins").mkdir(exist_ok=True)
    (config / "backups").mkdir(exist_ok=True)
    (config / "logs").mkdir(exist_ok=True)
    (config / "cache").mkdir(exist_ok=True)
    
    return config


# ============================================================================
# ENVIRONMENT FIXTURES
# ============================================================================

@pytest.fixture
def clean_env(monkeypatch) -> Dict[str, str]:
    """Provide a clean environment without user-specific variables.
    
    Args:
        monkeypatch: Pytest monkeypatch fixture
        
    Returns:
        Dict[str, str]: Clean environment variables
    """
    env = {
        'PATH': os.environ.get('PATH', ''),
        'HOME': os.environ.get('HOME', '/tmp'),
        'USER': 'testuser',
    }
    
    for key in list(os.environ.keys()):
        if key not in env:
            monkeypatch.delenv(key, raising=False)
    
    for key, value in env.items():
        monkeypatch.setenv(key, value)
    
    return env


@pytest.fixture
def mock_system_info() -> Dict[str, Any]:
    """Provide mock system information for testing.
    
    Returns:
        Dict[str, Any]: Mock system information
    """
    return {
        'os': 'darwin',
        'platform': 'macOS-11.0-Intel',
        'architecture': 'x86_64',
        'python_version': '3.8.0',
        'hostname': 'test-host',
        'processors': 4,
        'memory': 16.0,
    }


# ============================================================================
# MOCK SERVICE FIXTURES
# ============================================================================

@pytest.fixture
def mock_redis():
    """Provide a mock Redis client.
    
    Returns:
        Mock: Mock Redis client
    """
    redis_mock = MagicMock()
    redis_mock.ping.return_value = True
    redis_mock.get.return_value = None
    redis_mock.set.return_value = True
    redis_mock.delete.return_value = 1
    redis_mock.exists.return_value = False
    return redis_mock


@pytest.fixture
def mock_database():
    """Provide a mock database connection.
    
    Returns:
        Mock: Mock database connection
    """
    db_mock = MagicMock()
    db_mock.is_connected.return_value = True
    db_mock.execute.return_value = []
    return db_mock


# ============================================================================
# ASYNC FIXTURES
# ============================================================================

@pytest.fixture
def event_loop():
    """Create an event loop for async tests.
    
    Yields:
        asyncio event loop
    """
    import asyncio
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


# ============================================================================
# UTILITY FIXTURES
# ============================================================================

@pytest.fixture
def sample_config() -> Dict[str, Any]:
    """Provide sample configuration data for testing.
    
    Returns:
        Dict[str, Any]: Sample configuration
    """
    return {
        'version': '4.1.0',
        'debug': False,
        'log_level': 'INFO',
        'services': {
            'redis': {
                'host': 'localhost',
                'port': 6379,
                'db': 0,
            },
            'database': {
                'host': 'localhost',
                'port': 5432,
                'name': 'nexus_test',
            }
        },
        'ai': {
            'providers': ['openai', 'anthropic'],
            'default_model': 'gpt-4',
        }
    }


@pytest.fixture
def capture_logs(caplog):
    """Capture log output for testing.
    
    Args:
        caplog: Pytest log capture fixture
        
    Returns:
        Log capture fixture
    """
    import logging
    caplog.set_level(logging.DEBUG)
    return caplog
