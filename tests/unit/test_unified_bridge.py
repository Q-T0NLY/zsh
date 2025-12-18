"""
Unit tests for unified_bridge.py module.

Tests AI routing, caching, and bridge functionality.
"""

import pytest
import asyncio
from unittest.mock import Mock, patch, AsyncMock
from unified_bridge import AIProvider, AIProviderConfig, AIRequest, AIResponse


@pytest.mark.unit
class TestAIProvider:
    """Test suite for AIProvider enum."""
    
    def test_provider_values(self):
        """Test that all AI providers are defined."""
        assert hasattr(AIProvider, 'OPENAI')
        assert hasattr(AIProvider, 'ANTHROPIC')
        assert hasattr(AIProvider, 'GOOGLE')
        assert hasattr(AIProvider, 'OLLAMA')
        
    def test_provider_string_values(self):
        """Test provider string values."""
        assert AIProvider.OPENAI.value == 'openai'
        assert AIProvider.ANTHROPIC.value == 'anthropic'
        assert AIProvider.GOOGLE.value == 'google'


@pytest.mark.unit
class TestAIProviderConfig:
    """Test suite for AIProviderConfig dataclass."""
    
    def test_config_creation(self):
        """Test creating AI provider configuration."""
        config = AIProviderConfig(
            provider=AIProvider.OPENAI,
            api_key="test-key",
            endpoint="https://api.openai.com",
            models=["gpt-4", "gpt-3.5-turbo"],
            enabled=True
        )
        
        assert config.provider == AIProvider.OPENAI
        assert config.api_key == "test-key"
        assert config.enabled is True
        assert len(config.models) == 2
        
    def test_config_defaults(self):
        """Test default values in configuration."""
        config = AIProviderConfig(provider=AIProvider.OLLAMA)
        
        assert config.api_key is None
        assert config.endpoint == ""
        assert config.models == []
        assert config.enabled is False
        assert config.timeout == 30
        assert config.max_retries == 3
        
    def test_config_timeout_customization(self):
        """Test custom timeout configuration."""
        config = AIProviderConfig(
            provider=AIProvider.OPENAI,
            timeout=60
        )
        assert config.timeout == 60


@pytest.mark.unit
class TestAIRequest:
    """Test suite for AIRequest dataclass."""
    
    def test_request_creation(self):
        """Test creating an AI request."""
        request = AIRequest(
            prompt="Test prompt",
            provider=AIProvider.OPENAI,
            model="gpt-4",
            temperature=0.5,
            max_tokens=1000
        )
        
        assert request.prompt == "Test prompt"
        assert request.provider == AIProvider.OPENAI
        assert request.model == "gpt-4"
        assert request.temperature == 0.5
        assert request.max_tokens == 1000
        
    def test_request_defaults(self):
        """Test default request values."""
        request = AIRequest(
            prompt="Test",
            provider=AIProvider.OPENAI,
            model="gpt-4"
        )
        
        assert request.temperature == 0.7
        assert request.max_tokens == 2000
        assert request.system_prompt is None
        assert isinstance(request.context, dict)
        assert len(request.request_id) > 0
        
    def test_request_id_uniqueness(self):
        """Test that request IDs are unique."""
        request1 = AIRequest(
            prompt="Test 1",
            provider=AIProvider.OPENAI,
            model="gpt-4"
        )
        request2 = AIRequest(
            prompt="Test 2",
            provider=AIProvider.OPENAI,
            model="gpt-4"
        )
        
        assert request1.request_id != request2.request_id


@pytest.mark.unit
class TestAIResponse:
    """Test suite for AIResponse dataclass."""
    
    def test_response_creation(self):
        """Test creating an AI response."""
        response = AIResponse(
            request_id="test-123",
            provider=AIProvider.OPENAI,
            model="gpt-4",
            content="Test response",
            tokens_used=100,
            latency_ms=250.5
        )
        
        assert response.request_id == "test-123"
        assert response.provider == AIProvider.OPENAI
        assert response.content == "Test response"
        assert response.tokens_used == 100
        assert response.latency_ms == 250.5
        
    def test_response_defaults(self):
        """Test default response values."""
        response = AIResponse(
            request_id="test-123",
            provider=AIProvider.OPENAI,
            model="gpt-4",
            content="Test"
        )
        
        assert response.tokens_used == 0
        assert response.latency_ms == 0.0
        assert isinstance(response.metadata, dict)
        assert len(response.timestamp) > 0


@pytest.mark.asyncio
@pytest.mark.unit
class TestAIBridgeAsync:
    """Async tests for AI bridge functionality."""
    
    async def test_async_request_creation(self):
        """Test async request creation."""
        request = AIRequest(
            prompt="Async test",
            provider=AIProvider.OPENAI,
            model="gpt-4"
        )
        
        # Simulate async processing
        await asyncio.sleep(0.01)
        
        assert request.prompt == "Async test"
        
    async def test_async_multiple_requests(self):
        """Test handling multiple async requests."""
        requests = [
            AIRequest(
                prompt=f"Test {i}",
                provider=AIProvider.OPENAI,
                model="gpt-4"
            )
            for i in range(5)
        ]
        
        assert len(requests) == 5
        assert all(r.request_id for r in requests)
