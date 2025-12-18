# ADR 001: Use Dataclasses for Configuration Management

## Status
Accepted

## Context
The NEXUS platform requires a robust configuration management system that is:
- Type-safe
- Easy to validate
- Simple to serialize/deserialize
- Maintainable and extensible

We evaluated several approaches:
1. Dictionary-based configuration
2. Pydantic models
3. Python dataclasses
4. Custom configuration classes

## Decision
We will use Python dataclasses with type hints for configuration management throughout the platform.

## Rationale

### Advantages of Dataclasses
- **Built-in**: Part of Python standard library (3.7+)
- **Type Safety**: First-class support for type hints
- **Simplicity**: Less boilerplate than custom classes
- **Performance**: Faster than Pydantic for simple cases
- **Flexibility**: Can add custom methods and validation
- **Compatibility**: Works well with mypy and other tools

### Why Not Alternatives

**Dictionaries**:
- No type safety
- No IDE autocomplete
- Error-prone (typos, missing keys)
- Harder to validate

**Pydantic**:
- Extra dependency
- Overkill for simple configurations
- More complex for our use case
- Can be added later if needed

**Custom Classes**:
- More boilerplate
- Maintenance overhead
- Dataclasses provide same functionality

## Implementation

### Basic Configuration
```python
from dataclasses import dataclass, field
from typing import Optional, List

@dataclass
class AIProviderConfig:
    """Configuration for AI provider."""
    provider: str
    api_key: Optional[str] = None
    endpoint: str = ""
    models: List[str] = field(default_factory=list)
    enabled: bool = False
```

### With Validation
```python
from dataclasses import dataclass

@dataclass
class DatabaseConfig:
    """Database configuration."""
    host: str
    port: int
    database: str
    
    def __post_init__(self):
        """Validate configuration after initialization."""
        if not 1 <= self.port <= 65535:
            raise ValueError(f"Invalid port: {self.port}")
        if not self.database:
            raise ValueError("Database name required")
```

### Serialization
```python
from dataclasses import asdict, astuple
import json

config = AIProviderConfig(provider="openai", api_key="sk-...")
config_dict = asdict(config)
config_json = json.dumps(config_dict)
```

## Consequences

### Positive
- ✅ Type-safe configuration
- ✅ Better IDE support and autocomplete
- ✅ Easier to maintain and extend
- ✅ Self-documenting code
- ✅ Validation at initialization
- ✅ No external dependencies

### Negative
- ❌ Python 3.7+ required (acceptable for our use case)
- ❌ Less runtime validation than Pydantic
- ❌ Need manual serialization for complex types

### Neutral
- Migration path: Can gradually replace existing dict-based configs
- Future option: Can add Pydantic layer if needed for advanced validation

## Follow-up Actions
1. Create base configuration classes for common patterns
2. Document configuration patterns in developer guide
3. Add validation helpers for common cases
4. Create migration guide for existing configurations

## References
- [PEP 557 – Data Classes](https://peps.python.org/pep-0557/)
- [Python dataclasses documentation](https://docs.python.org/3/library/dataclasses.html)
- [Real Python: Python Data Classes](https://realpython.com/python-data-classes/)

---

**Date**: 2024-01-01  
**Author**: NEXUS Development Team  
**Reviewers**: Architecture Team
