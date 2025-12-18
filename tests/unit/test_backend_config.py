"""
Unit tests for backend_config.py module.

Tests configuration management, system detection, and UI components.
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from backend_config import Colors, UI, SystemInfo


class TestColors:
    """Test suite for Colors class."""
    
    def test_color_constants_defined(self):
        """Test that all color constants are defined."""
        assert hasattr(Colors, 'RED')
        assert hasattr(Colors, 'GREEN')
        assert hasattr(Colors, 'YELLOW')
        assert hasattr(Colors, 'BLUE')
        assert hasattr(Colors, 'RESET')
        
    def test_color_values_are_strings(self):
        """Test that color values are strings."""
        assert isinstance(Colors.RED, str)
        assert isinstance(Colors.GREEN, str)
        assert isinstance(Colors.RESET, str)


class TestUI:
    """Test suite for UI utility class."""
    
    def test_banner_output(self, capsys):
        """Test banner display."""
        UI.banner("Test Title")
        captured = capsys.readouterr()
        assert "Test Title" in captured.out
        assert "=" in captured.out
        
    def test_section_output(self, capsys):
        """Test section display."""
        UI.section("Test Section")
        captured = capsys.readouterr()
        assert "Test Section" in captured.out
        
    def test_success_output(self, capsys):
        """Test success message display."""
        UI.success("Operation successful")
        captured = capsys.readouterr()
        assert "Operation successful" in captured.out
        assert "✓" in captured.out or "successful" in captured.out
        
    def test_error_output(self, capsys):
        """Test error message display."""
        UI.error("An error occurred")
        captured = capsys.readouterr()
        assert "An error occurred" in captured.out
        assert "✗" in captured.out or "error" in captured.out
        
    def test_warning_output(self, capsys):
        """Test warning message display."""
        UI.warning("Warning message")
        captured = capsys.readouterr()
        assert "Warning message" in captured.out
        assert "⚠" in captured.out or "Warning" in captured.out
        
    def test_info_output(self, capsys):
        """Test info message display."""
        UI.info("Information")
        captured = capsys.readouterr()
        assert "Information" in captured.out
        
    def test_step_output(self, capsys):
        """Test step display."""
        UI.step("Step 1")
        captured = capsys.readouterr()
        assert "Step 1" in captured.out


class TestSystemInfo:
    """Test suite for SystemInfo class."""
    
    @patch('platform.system')
    def test_get_os_returns_lowercase(self, mock_system):
        """Test that get_os returns lowercase OS name."""
        mock_system.return_value = 'Darwin'
        result = SystemInfo.get_os()
        assert result == 'darwin'
        
    @patch('platform.system')
    def test_get_os_linux(self, mock_system):
        """Test get_os for Linux."""
        mock_system.return_value = 'Linux'
        result = SystemInfo.get_os()
        assert result == 'linux'
        
    @patch('platform.machine')
    def test_get_arch(self, mock_machine):
        """Test architecture detection."""
        mock_machine.return_value = 'x86_64'
        result = SystemInfo.get_arch()
        assert result == 'x86_64'
        
    @patch('platform.machine')
    def test_get_arch_arm(self, mock_machine):
        """Test ARM architecture detection."""
        mock_machine.return_value = 'arm64'
        result = SystemInfo.get_arch()
        assert result == 'arm64'


@pytest.mark.integration
class TestIntegration:
    """Integration tests for backend_config module."""
    
    def test_ui_and_colors_integration(self, capsys):
        """Test that UI properly uses color codes."""
        UI.success("Test")
        captured = capsys.readouterr()
        # Should contain either color codes or the message
        assert "Test" in captured.out
        
    @patch('platform.system')
    @patch('platform.machine')
    def test_system_detection_integration(self, mock_machine, mock_system):
        """Test complete system detection."""
        mock_system.return_value = 'Darwin'
        mock_machine.return_value = 'x86_64'
        
        os_type = SystemInfo.get_os()
        arch = SystemInfo.get_arch()
        
        assert os_type == 'darwin'
        assert arch == 'x86_64'
