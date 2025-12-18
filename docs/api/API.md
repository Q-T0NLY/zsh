# API Documentation

## Overview

The NEXUS Platform provides RESTful APIs for system management, AI integration, and monitoring.

## Base URL

```
Development: http://localhost:8000
Production: https://api.nexus-platform.com
```

## Authentication

All API requests require authentication via API key in the header:

```bash
Authorization: Bearer YOUR_API_KEY
```

## Endpoints

### Health Check

#### GET /health

Check system health status.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00Z",
  "version": "4.1.0",
  "components": {
    "database": "healthy",
    "redis": "healthy",
    "ai_services": "healthy"
  }
}
```

### System Metrics

#### GET /api/v1/metrics

Get current system metrics.

**Response:**
```json
{
  "cpu_percent": 45.2,
  "memory_percent": 62.5,
  "disk_percent": 38.7,
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### AI Integration

#### POST /api/v1/ai/query

Send query to AI provider.

**Request:**
```json
{
  "prompt": "Explain this code",
  "provider": "openai",
  "model": "gpt-4",
  "temperature": 0.7,
  "max_tokens": 2000
}
```

**Response:**
```json
{
  "request_id": "uuid-here",
  "provider": "openai",
  "model": "gpt-4",
  "content": "AI response here...",
  "tokens_used": 150,
  "latency_ms": 1250.5
}
```

### System Management

#### GET /api/v1/system/status

Get comprehensive system status.

**Response:**
```json
{
  "status": "operational",
  "uptime": 86400,
  "services": [
    {
      "name": "dashboard",
      "status": "running",
      "port": 5000
    },
    {
      "name": "api",
      "status": "running",
      "port": 8000
    }
  ]
}
```

## Error Handling

### Error Response Format

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Detailed error message",
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
```

### HTTP Status Codes

- `200 OK`: Successful request
- `201 Created`: Resource created
- `400 Bad Request`: Invalid request
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server error
- `503 Service Unavailable`: Service temporarily unavailable

## Rate Limiting

- Default: 100 requests per minute per API key
- Headers returned:
  - `X-RateLimit-Limit`: Request limit
  - `X-RateLimit-Remaining`: Remaining requests
  - `X-RateLimit-Reset`: Reset timestamp

## Examples

### Python

```python
import requests

headers = {
    "Authorization": "Bearer YOUR_API_KEY",
    "Content-Type": "application/json"
}

# Health check
response = requests.get("http://localhost:8000/health", headers=headers)
print(response.json())

# AI query
data = {
    "prompt": "Hello, AI!",
    "provider": "openai",
    "model": "gpt-4"
}
response = requests.post("http://localhost:8000/api/v1/ai/query", 
                        headers=headers, json=data)
print(response.json())
```

### cURL

```bash
# Health check
curl -H "Authorization: Bearer YOUR_API_KEY" \
     http://localhost:8000/health

# AI query
curl -X POST \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"prompt":"Hello","provider":"openai","model":"gpt-4"}' \
     http://localhost:8000/api/v1/ai/query
```

## Webhooks

The platform supports webhooks for real-time notifications.

### Webhook Events

- `system.health.changed`: System health status changed
- `ai.query.completed`: AI query processing completed
- `deployment.started`: Deployment initiated
- `deployment.completed`: Deployment finished

### Webhook Payload

```json
{
  "event": "system.health.changed",
  "timestamp": "2024-01-01T00:00:00Z",
  "data": {
    "previous_status": "healthy",
    "current_status": "degraded",
    "component": "database"
  }
}
```

## Versioning

The API uses URL versioning:
- Current: `/api/v1/`
- Legacy support: 6 months after new version release
