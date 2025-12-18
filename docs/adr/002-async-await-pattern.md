# ADR 002: Adopt Async/Await for I/O Operations

## Status
Accepted

## Context
The NEXUS platform performs numerous I/O operations:
- External API calls (AI providers)
- Database queries
- Redis cache operations
- File system operations
- Network requests

We need to decide on the concurrency model for handling these operations efficiently.

## Decision
We will use Python's async/await pattern with asyncio for all I/O-bound operations.

## Rationale

### Benefits of Async/Await
- **Performance**: Handle multiple I/O operations concurrently
- **Scalability**: Better resource utilization
- **Modern**: Python 3.8+ standard approach
- **Ecosystem**: Strong library support (aiohttp, asyncpg, etc.)
- **Maintainability**: More readable than callbacks or threading

### Why Not Alternatives

**Threading**:
- Global Interpreter Lock (GIL) limitations
- Higher memory overhead
- More complex debugging
- Race conditions

**Multiprocessing**:
- High overhead for I/O operations
- Complex state management
- Not suitable for I/O-bound tasks

**Synchronous**:
- Poor performance for concurrent I/O
- Blocks on network/disk operations
- Not scalable

## Implementation

### Basic Async Function
```python
import asyncio
import aiohttp
from typing import Dict, Any

async def fetch_ai_response(prompt: str, provider: str) -> Dict[str, Any]:
    """Fetch response from AI provider asynchronously.
    
    Args:
        prompt: User prompt
        provider: AI provider name
        
    Returns:
        Response dictionary
    """
    async with aiohttp.ClientSession() as session:
        async with session.post(
            f"https://api.{provider}.com/v1/chat",
            json={"prompt": prompt}
        ) as response:
            return await response.json()
```

### Concurrent Operations
```python
async def process_multiple_queries(queries: List[str]) -> List[Dict]:
    """Process multiple queries concurrently.
    
    Args:
        queries: List of query strings
        
    Returns:
        List of responses
    """
    tasks = [fetch_ai_response(q, "openai") for q in queries]
    return await asyncio.gather(*tasks)
```

### Mixed Sync/Async
```python
import asyncio
from concurrent.futures import ThreadPoolExecutor

async def run_in_executor(func, *args):
    """Run synchronous function in executor.
    
    Args:
        func: Synchronous function
        *args: Function arguments
        
    Returns:
        Function result
    """
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, func, *args)

# Usage
async def hybrid_operation():
    # Async operation
    result1 = await fetch_data()
    
    # Sync operation in executor
    result2 = await run_in_executor(blocking_operation)
    
    return result1, result2
```

## Guidelines

### When to Use Async
✅ External API calls  
✅ Database operations  
✅ File I/O (with aiofiles)  
✅ Network requests  
✅ Cache operations (Redis)  

### When to Use Sync
✅ CPU-intensive calculations  
✅ Simple utility functions  
✅ Configuration loading  
✅ Logging (unless high-volume)  

### Testing Async Code
```python
import pytest

@pytest.mark.asyncio
async def test_async_function():
    """Test async function."""
    result = await fetch_ai_response("test", "openai")
    assert result is not None
    
@pytest.fixture
def event_loop():
    """Create event loop for tests."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()
```

## Consequences

### Positive
- ✅ Improved performance for I/O operations
- ✅ Better resource utilization
- ✅ Scalable architecture
- ✅ Modern Python practices
- ✅ Strong library ecosystem

### Negative
- ❌ Learning curve for developers
- ❌ More complex debugging
- ❌ Need async-compatible libraries
- ❌ Cannot mix with some sync libraries

### Neutral
- Some libraries require async versions (e.g., httpx instead of requests)
- Need to plan for async/sync boundaries
- Testing requires pytest-asyncio

## Migration Strategy

### Phase 1: Core I/O Operations
- AI provider integration
- Database queries
- Redis operations

### Phase 2: API Endpoints
- Convert Flask to FastAPI
- Async request handlers
- WebSocket support

### Phase 3: Background Tasks
- Async task queues
- Periodic operations
- Event processing

## Dependencies
- `asyncio`: Built-in
- `aiohttp`: HTTP client/server
- `asyncpg`: PostgreSQL driver
- `aioredis`: Redis client
- `pytest-asyncio`: Testing

## References
- [Python asyncio documentation](https://docs.python.org/3/library/asyncio.html)
- [FastAPI async guide](https://fastapi.tiangolo.com/async/)
- [Real Python: Async IO in Python](https://realpython.com/async-io-python/)

---

**Date**: 2024-01-01  
**Author**: NEXUS Development Team  
**Reviewers**: Architecture Team
