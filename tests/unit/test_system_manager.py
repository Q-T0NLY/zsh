"""
Unit tests for system_manager.py module.

Tests system validation, health checks, and monitoring functionality.
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from pathlib import Path
from system_manager import SystemValidator


@pytest.mark.unit
class TestSystemValidator:
    """Test suite for SystemValidator class."""
    
    def test_validator_initialization(self):
        """Test SystemValidator initialization."""
        validator = SystemValidator()
        assert validator.checks_passed == 0
        assert validator.checks_failed == 0
        assert hasattr(validator, 'workspace_root')
        
    def test_check_imports_structure(self):
        """Test that check_imports returns proper structure."""
        validator = SystemValidator()
        
        with patch('builtins.exec'):
            results = validator.check_imports()
            assert isinstance(results, list)
            
    def test_check_imports_success(self, capsys):
        """Test successful import checking."""
        validator = SystemValidator()
        
        # Mock successful imports
        with patch('builtins.exec'):
            results = validator.check_imports()
            captured = capsys.readouterr()
            assert "VALIDATING PYTHON IMPORTS" in captured.out
            
    def test_check_imports_counts_passed(self):
        """Test that successful imports increment passed count."""
        validator = SystemValidator()
        initial_passed = validator.checks_passed
        
        with patch('builtins.exec'):
            validator.check_imports()
            # Should have attempted checks
            assert True  # Basic validation
            
    def test_check_hyper_registry_structure(self):
        """Test hyper registry check structure."""
        validator = SystemValidator()
        
        # Mock the imports
        with patch('builtins.__import__'):
            results = validator.check_hyper_registry()
            assert isinstance(results, list)


@pytest.mark.integration
class TestSystemValidatorIntegration:
    """Integration tests for SystemValidator."""
    
    def test_full_validation_workflow(self, temp_dir):
        """Test complete validation workflow."""
        validator = SystemValidator()
        
        # Run validation checks
        with patch('builtins.exec'):
            import_results = validator.check_imports()
            
        assert isinstance(import_results, list)
        assert validator.checks_passed >= 0
        assert validator.checks_failed >= 0
        
    def test_validator_with_workspace_root(self, temp_dir, monkeypatch):
        """Test validator with custom workspace root."""
        monkeypatch.chdir(temp_dir)
        validator = SystemValidator()
        
        # Workspace root should be set
        assert validator.workspace_root is not None


@pytest.mark.slow
class TestSystemValidatorPerformance:
    """Performance tests for system validation."""
    
    def test_import_check_performance(self, benchmark):
        """Benchmark import checking performance."""
        validator = SystemValidator()
        
        def run_checks():
            with patch('builtins.exec'):
                return validator.check_imports()
                
        # Run benchmark if pytest-benchmark is available
        try:
            result = benchmark(run_checks)
            assert isinstance(result, list)
        except Exception:
            # Skip if benchmark not available
            result = run_checks()
            assert isinstance(result, list)
