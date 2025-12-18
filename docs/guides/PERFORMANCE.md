# Performance Optimization Guide

## Overview

This guide covers performance optimization strategies for the NEXUS Platform across Python, shell scripts, and infrastructure.

## Python Performance

### 1. Profiling

#### CPU Profiling
```python
import cProfile
import pstats
from pstats import SortKey

def profile_function():
    """Profile a function's performance."""
    profiler = cProfile.Profile()
    profiler.enable()
    
    # Your code here
    result = expensive_function()
    
    profiler.disable()
    stats = pstats.Stats(profiler)
    stats.sort_stats(SortKey.CUMULATIVE)
    stats.print_stats(10)  # Top 10 functions
    
    return result
```

#### Memory Profiling
```python
from memory_profiler import profile

@profile
def memory_intensive_function():
    """Function to profile memory usage."""
    large_list = [i for i in range(1000000)]
    return sum(large_list)
```

### 2. Caching Strategies

#### Function-level Caching
```python
from functools import lru_cache
from typing import List

@lru_cache(maxsize=128)
def expensive_computation(n: int) -> int:
    """Cache results of expensive computations.
    
    Args:
        n: Input number
        
    Returns:
        Computed result
    """
    # Expensive operation
    return sum(i * i for i in range(n))
```

#### Redis Caching
```python
import redis
import json
from typing import Optional, Any
from functools import wraps

class RedisCache:
    """Redis-based caching."""
    
    def __init__(self, host: str = 'localhost', port: int = 6379):
        self.redis = redis.Redis(host=host, port=port)
    
    def cache(self, ttl: int = 3600):
        """Decorator for caching function results.
        
        Args:
            ttl: Time to live in seconds
        """
        def decorator(func):
            @wraps(func)
            def wrapper(*args, **kwargs):
                # Create cache key
                key = f"{func.__name__}:{str(args)}:{str(kwargs)}"
                
                # Try to get from cache
                cached = self.redis.get(key)
                if cached:
                    return json.loads(cached)
                
                # Compute and cache
                result = func(*args, **kwargs)
                self.redis.setex(key, ttl, json.dumps(result))
                return result
            return wrapper
        return decorator

# Usage
cache = RedisCache()

@cache.cache(ttl=3600)
def fetch_user_data(user_id: int) -> dict:
    """Fetch user data with caching."""
    # Expensive database query
    return {"id": user_id, "name": "User"}
```

### 3. Database Optimization

#### Connection Pooling
```python
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    'postgresql://user:pass@localhost/db',
    poolclass=QueuePool,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True,
    pool_recycle=3600
)
```

#### Query Optimization
```python
from typing import List
from sqlalchemy.orm import Session, joinedload

def get_users_with_posts_optimized(session: Session) -> List:
    """Optimized query with eager loading.
    
    Args:
        session: Database session
        
    Returns:
        List of users with posts
    """
    # ❌ BAD - N+1 query problem
    # users = session.query(User).all()
    # for user in users:
    #     posts = user.posts  # Separate query for each user
    
    # ✅ GOOD - Single query with joins
    return session.query(User).options(
        joinedload(User.posts)
    ).all()
```

#### Batch Operations
```python
def batch_insert(session: Session, items: List[dict]) -> None:
    """Batch insert for better performance.
    
    Args:
        session: Database session
        items: Items to insert
    """
    # ❌ BAD - Individual inserts
    # for item in items:
    #     session.add(User(**item))
    #     session.commit()
    
    # ✅ GOOD - Bulk insert
    session.bulk_insert_mappings(User, items)
    session.commit()
```

### 4. Async Operations

#### Concurrent API Calls
```python
import asyncio
import aiohttp
from typing import List, Dict

async def fetch_multiple_endpoints(urls: List[str]) -> List[Dict]:
    """Fetch multiple endpoints concurrently.
    
    Args:
        urls: List of URLs to fetch
        
    Returns:
        List of responses
    """
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        return await asyncio.gather(*tasks)

async def fetch_url(session: aiohttp.ClientSession, url: str) -> Dict:
    """Fetch single URL.
    
    Args:
        session: HTTP session
        url: URL to fetch
        
    Returns:
        Response data
    """
    async with session.get(url) as response:
        return await response.json()

# Usage
urls = ['http://api1.com', 'http://api2.com', 'http://api3.com']
results = asyncio.run(fetch_multiple_endpoints(urls))
```

## Shell Script Performance

### 1. Reduce Subprocess Calls

```bash
# ❌ BAD - Multiple subprocess calls
for file in *.txt; do
    count=$(wc -l < "$file")
    echo "$file: $count"
done

# ✅ GOOD - Single call
wc -l *.txt
```

### 2. Use Built-in Commands

```bash
# ❌ BAD - External command
if [ "$(echo "$var" | grep -c 'pattern')" -gt 0 ]; then
    echo "found"
fi

# ✅ GOOD - Built-in pattern matching
if [[ "$var" == *"pattern"* ]]; then
    echo "found"
fi
```

### 3. Array Operations

```bash
# ❌ BAD - String concatenation in loop
result=""
for item in "${items[@]}"; do
    result="${result}${item},"
done

# ✅ GOOD - Array join
printf -v result "%s," "${items[@]}"
result="${result%,}"  # Remove trailing comma
```

## Infrastructure Performance

### 1. Docker Optimization

```dockerfile
# Multi-stage build for smaller images
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["python", "app.py"]
```

### 2. Kubernetes Resource Limits

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### 3. Redis Optimization

```bash
# redis.conf optimizations
maxmemory 512mb
maxmemory-policy allkeys-lru
save ""  # Disable persistence for cache-only
```

## Monitoring Performance

### 1. Application Metrics

```python
from prometheus_client import Counter, Histogram, Gauge
import time

# Metrics
request_count = Counter('requests_total', 'Total requests')
request_duration = Histogram('request_duration_seconds', 'Request duration')
active_connections = Gauge('active_connections', 'Active connections')

def track_performance(func):
    """Decorator to track function performance."""
    def wrapper(*args, **kwargs):
        request_count.inc()
        
        start = time.time()
        try:
            return func(*args, **kwargs)
        finally:
            duration = time.time() - start
            request_duration.observe(duration)
    return wrapper
```

### 2. Query Monitoring

```python
import logging
import time
from contextlib import contextmanager

@contextmanager
def query_timer(query_name: str):
    """Time database queries.
    
    Args:
        query_name: Name of the query
    """
    start = time.time()
    try:
        yield
    finally:
        duration = time.time() - start
        if duration > 0.5:  # Log slow queries
            logging.warning(f"Slow query {query_name}: {duration:.2f}s")
```

## Best Practices

### 1. Data Structures

```python
# ✅ Use appropriate data structures
# For membership testing:
items_set = set(items)  # O(1) lookup
if item in items_set:  # Fast

# For ordered operations:
from collections import deque
queue = deque()  # O(1) append/pop from both ends

# For counting:
from collections import Counter
counts = Counter(items)  # Efficient counting
```

### 2. List Comprehensions

```python
# ✅ GOOD - List comprehension (faster)
squares = [x*x for x in range(1000)]

# ❌ BAD - Loop with append (slower)
squares = []
for x in range(1000):
    squares.append(x*x)
```

### 3. Generator Expressions

```python
# ✅ GOOD - Generator (memory efficient)
total = sum(x*x for x in range(1000000))

# ❌ BAD - List (memory intensive)
total = sum([x*x for x in range(1000000)])
```

## Load Testing

### 1. Using Locust

```python
from locust import HttpUser, task, between

class QuickstartUser(HttpUser):
    wait_time = between(1, 3)

    @task
    def index_page(self):
        self.client.get("/")

    @task(3)
    def view_item(self):
        self.client.get("/api/v1/metrics")
```

### 2. Using Apache Bench

```bash
# 1000 requests with 10 concurrent connections
ab -n 1000 -c 10 http://localhost:8000/api/v1/metrics
```

## Performance Checklist

### Python
- [ ] Profile critical code paths
- [ ] Implement caching where appropriate
- [ ] Use connection pooling
- [ ] Optimize database queries
- [ ] Use async for I/O operations
- [ ] Choose appropriate data structures

### Shell Scripts
- [ ] Minimize subprocess calls
- [ ] Use built-in commands
- [ ] Avoid unnecessary loops
- [ ] Use arrays efficiently

### Infrastructure
- [ ] Set resource limits
- [ ] Enable caching layers
- [ ] Optimize container images
- [ ] Monitor resource usage
- [ ] Scale horizontally when needed

### Monitoring
- [ ] Track response times
- [ ] Monitor resource usage
- [ ] Log slow operations
- [ ] Set up alerts
- [ ] Regular performance reviews
