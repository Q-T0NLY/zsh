# Deployment Guide

## Overview

This guide covers deploying the NEXUS Platform in various environments.

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+ (for local/dev)
- Kubernetes 1.24+ (for production)
- kubectl configured
- Access to container registry

## Development Deployment

### Using Docker Compose

```bash
# Clone repository
git clone https://github.com/Q-T0NLY/zsh.git
cd zsh

# Copy environment template
cp .env.example .env

# Edit configuration
vim .env

# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f nexus

# Stop services
docker-compose down
```

### Environment Variables

Create `.env` file:

```bash
# Application
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=DEBUG

# Database
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=nexus_dev
POSTGRES_USER=nexus
POSTGRES_PASSWORD=change_this_password

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# AI Providers (optional)
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# Monitoring
PROMETHEUS_ENABLED=true
GRAFANA_ENABLED=true
```

### Verify Deployment

```bash
# Check all containers are running
docker-compose ps

# Test application
curl http://localhost:8000/health

# Access dashboard
open http://localhost:5000

# Access Grafana
open http://localhost:3001  # admin/admin
```

## Staging Deployment

### Docker Registry

```bash
# Build image
docker build -t nexus-platform:latest .

# Tag for registry
docker tag nexus-platform:latest registry.example.com/nexus-platform:latest

# Push to registry
docker push registry.example.com/nexus-platform:latest
```

### Deploy to Staging

```bash
# Set staging context
kubectl config use-context staging

# Create namespace
kubectl create namespace nexus-staging

# Apply configurations
kubectl apply -f k8s/ -n nexus-staging

# Check deployment
kubectl get pods -n nexus-staging
kubectl get svc -n nexus-staging

# Check logs
kubectl logs -f deployment/nexus-platform -n nexus-staging
```

## Production Deployment

### Pre-deployment Checklist

- [ ] All tests passing
- [ ] Security scan completed
- [ ] Database migrations ready
- [ ] Backups configured
- [ ] Monitoring configured
- [ ] Rollback plan prepared
- [ ] Stakeholders notified

### Database Migration

```bash
# Connect to production database
kubectl port-forward svc/postgres 5432:5432 -n nexus

# Run migrations
alembic upgrade head

# Verify migration
alembic current
```

### Kubernetes Deployment

#### 1. Create Namespace

```bash
kubectl create namespace nexus
```

#### 2. Create Secrets

```bash
# Database credentials
kubectl create secret generic db-credentials \
  --from-literal=username=nexus \
  --from-literal=password=secure_password \
  -n nexus

# API keys
kubectl create secret generic api-keys \
  --from-literal=openai-key=sk-... \
  --from-literal=anthropic-key=sk-ant-... \
  -n nexus

# Verify secrets
kubectl get secrets -n nexus
```

#### 3. Apply ConfigMaps

```bash
kubectl apply -f k8s/configmap.yaml -n nexus
```

#### 4. Deploy Application

```bash
# Apply deployment
kubectl apply -f k8s/deployment.yaml -n nexus

# Watch rollout
kubectl rollout status deployment/nexus-platform -n nexus

# Check pods
kubectl get pods -n nexus -w
```

#### 5. Expose Service

```bash
# Apply service
kubectl apply -f k8s/service.yaml -n nexus

# Apply ingress (if using)
kubectl apply -f k8s/ingress.yaml -n nexus

# Get external IP
kubectl get svc nexus-platform -n nexus
```

### Blue-Green Deployment

```bash
# Deploy green version
kubectl apply -f k8s/deployment-green.yaml -n nexus

# Verify green is healthy
kubectl get pods -l version=green -n nexus

# Switch traffic to green
kubectl patch service nexus-platform -n nexus \
  -p '{"spec":{"selector":{"version":"green"}}}'

# Monitor for issues
kubectl logs -f deployment/nexus-platform-green -n nexus

# If successful, remove blue
kubectl delete deployment nexus-platform-blue -n nexus

# If issues, rollback to blue
kubectl patch service nexus-platform -n nexus \
  -p '{"spec":{"selector":{"version":"blue"}}}'
```

### Canary Deployment

```bash
# Deploy canary with 10% traffic
kubectl apply -f k8s/deployment-canary.yaml -n nexus

# Monitor metrics
kubectl top pods -n nexus

# Gradually increase traffic
kubectl scale deployment nexus-platform-canary --replicas=3 -n nexus

# If successful, promote canary
kubectl apply -f k8s/deployment.yaml -n nexus

# Remove canary
kubectl delete deployment nexus-platform-canary -n nexus
```

## Health Checks

### Application Health

```bash
# Liveness probe
curl http://app-url/health

# Readiness probe
curl http://app-url/ready

# Metrics endpoint
curl http://app-url/metrics
```

### Database Health

```bash
# PostgreSQL
kubectl exec -it deployment/postgres -n nexus -- \
  pg_isready -U nexus

# Redis
kubectl exec -it deployment/redis -n nexus -- \
  redis-cli ping
```

## Monitoring Setup

### Prometheus

```bash
# Deploy Prometheus
kubectl apply -f monitoring/prometheus/ -n nexus

# Access Prometheus
kubectl port-forward svc/prometheus 9090:9090 -n nexus
open http://localhost:9090
```

### Grafana

```bash
# Deploy Grafana
kubectl apply -f monitoring/grafana/ -n nexus

# Get admin password
kubectl get secret grafana -n nexus -o jsonpath="{.data.admin-password}" | base64 --decode

# Access Grafana
kubectl port-forward svc/grafana 3000:3000 -n nexus
open http://localhost:3000
```

## Scaling

### Manual Scaling

```bash
# Scale deployment
kubectl scale deployment nexus-platform --replicas=5 -n nexus

# Verify scaling
kubectl get pods -n nexus
```

### Auto-scaling

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nexus-platform-hpa
  namespace: nexus
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nexus-platform
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

```bash
# Apply HPA
kubectl apply -f hpa.yaml -n nexus

# Check HPA status
kubectl get hpa -n nexus
```

## Backup and Recovery

### Database Backup

```bash
# Create backup
kubectl exec deployment/postgres -n nexus -- \
  pg_dump -U nexus nexus_prod > backup_$(date +%Y%m%d).sql

# Upload to S3
aws s3 cp backup_*.sql s3://nexus-backups/

# Schedule automated backups
kubectl apply -f k8s/cronjob-backup.yaml -n nexus
```

### Restore from Backup

```bash
# Download backup
aws s3 cp s3://nexus-backups/backup_20240101.sql .

# Restore
kubectl exec -i deployment/postgres -n nexus -- \
  psql -U nexus nexus_prod < backup_20240101.sql
```

## Rollback

### Quick Rollback

```bash
# View rollout history
kubectl rollout history deployment/nexus-platform -n nexus

# Rollback to previous version
kubectl rollout undo deployment/nexus-platform -n nexus

# Rollback to specific revision
kubectl rollout undo deployment/nexus-platform --to-revision=2 -n nexus

# Verify rollback
kubectl rollout status deployment/nexus-platform -n nexus
```

### Database Rollback

```bash
# Downgrade database
alembic downgrade -1

# Or to specific revision
alembic downgrade <revision-id>
```

## Disaster Recovery

### Recovery Plan

1. **Assess Impact**: Determine scope of failure
2. **Communicate**: Notify stakeholders
3. **Isolate**: Stop affected services
4. **Restore**: From latest backup
5. **Verify**: Test functionality
6. **Resume**: Return to normal operations
7. **Post-mortem**: Document and improve

### Recovery Steps

```bash
# 1. Stop current deployment
kubectl scale deployment nexus-platform --replicas=0 -n nexus

# 2. Restore database
kubectl exec -i deployment/postgres -n nexus -- \
  psql -U nexus nexus_prod < latest_backup.sql

# 3. Deploy previous version
kubectl rollout undo deployment/nexus-platform -n nexus

# 4. Verify health
kubectl get pods -n nexus
curl http://app-url/health

# 5. Scale up
kubectl scale deployment nexus-platform --replicas=3 -n nexus
```

## Security Hardening

### Network Policies

```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: nexus-network-policy
  namespace: nexus
spec:
  podSelector:
    matchLabels:
      app: nexus
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              access: nexus
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: postgres
```

### Pod Security Policy

```yaml
# pod-security-policy.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: nexus-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  fsGroup:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
```

## Maintenance

### Update Application

```bash
# Build new version
docker build -t nexus-platform:v4.2.0 .

# Push to registry
docker push registry.example.com/nexus-platform:v4.2.0

# Update deployment
kubectl set image deployment/nexus-platform \
  nexus=registry.example.com/nexus-platform:v4.2.0 -n nexus

# Monitor rollout
kubectl rollout status deployment/nexus-platform -n nexus
```

### Update Dependencies

```bash
# Update Python packages
pip install --upgrade -r requirements.txt
pip freeze > requirements-frozen.txt

# Rebuild and redeploy
docker build -t nexus-platform:latest .
```

## Troubleshooting Deployment

### Pod Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name> -n nexus

# Check events
kubectl get events -n nexus --sort-by='.lastTimestamp'

# Check logs
kubectl logs <pod-name> -n nexus --previous
```

### Service Not Accessible

```bash
# Check service
kubectl get svc -n nexus
kubectl describe svc nexus-platform -n nexus

# Check endpoints
kubectl get endpoints nexus-platform -n nexus

# Test from within cluster
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  wget -O- http://nexus-platform:8000/health
```

## Post-Deployment

- [ ] Verify all services healthy
- [ ] Check logs for errors
- [ ] Monitor metrics
- [ ] Run smoke tests
- [ ] Update documentation
- [ ] Notify stakeholders
- [ ] Schedule post-mortem (if issues)
