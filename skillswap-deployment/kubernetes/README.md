# SkillSwap Kubernetes Deployment Guide

Complete guide for deploying the SkillSwap microservices platform on Kubernetes.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Detailed Deployment](#detailed-deployment)
- [Configuration](#configuration)
- [Monitoring](#monitoring)
- [Scaling](#scaling)
- [Troubleshooting](#troubleshooting)
- [Maintenance](#maintenance)

## 🎯 Overview

This Kubernetes deployment provides a production-ready setup for the SkillSwap platform with:
- **High Availability**: Multiple replicas for each service
- **Auto-scaling**: Horizontal Pod Autoscaling (HPA)
- **Load Balancing**: Service discovery and load distribution
- **Persistent Storage**: StatefulSets for databases
- **Configuration Management**: ConfigMaps and Secrets
- **Health Checks**: Liveness and readiness probes

## 📦 Architecture

### Deployment Topology

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                    │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │              Namespace: skillswap                 │  │
│  ├──────────────────────────────────────────────────┤  │
│  │                                                    │  │
│  │  ┌─────────────────────────────────────────┐    │  │
│  │  │         LoadBalancer Service            │    │  │
│  │  │         (External Access)               │    │  │
│  │  └──────────────┬──────────────────────────┘    │  │
│  │                 │                                 │  │
│  │                 ↓                                 │  │
│  │  ┌─────────────────────────────────────────┐    │  │
│  │  │      API Gateway (2 replicas)           │    │  │
│  │  │      Port: 8080                         │    │  │
│  │  └──────────────┬──────────────────────────┘    │  │
│  │                 │                                 │  │
│  │     ┌───────────┼───────────┬──────────┐        │  │
│  │     ↓           ↓           ↓          ↓        │  │
│  │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐       │  │
│  │  │User  │  │Skill │  │Mission│ │Notif.│       │  │
│  │  │Svc   │  │Svc   │  │Svc    │ │Svc   │       │  │
│  │  │x2    │  │x2    │  │x2     │ │x2    │       │  │
│  │  └──┬───┘  └──┬───┘  └──┬────┘ └──┬───┘       │  │
│  │     │         │         │          │            │  │
│  │     ↓         ↓         ↓          ↓            │  │
│  │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐       │  │
│  │  │Postgres│ │MongoDB│ │Kafka │ │Redis │       │  │
│  │  │StatefulSet│StatefulSet│StatefulSet│StatefulSet│ │
│  │  └──────┘  └──────┘  └──────┘  └──────┘       │  │
│  │                                                    │  │
│  └────────────────────────────────────────────────┘  │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

### Components

#### Application Services (Deployments)
- **API Gateway**: 2 replicas, LoadBalancer service
- **User Service**: 2 replicas, ClusterIP service
- **Skill Service**: 2 replicas, ClusterIP service
- **Mission Service**: 2 replicas, ClusterIP service
- **Notification Service**: 2 replicas, ClusterIP service

#### Infrastructure (StatefulSets)
- **PostgreSQL**: 1 replica, persistent storage for user data
- **MongoDB**: 1 replica, persistent storage for skills/missions
- **Kafka + Zookeeper**: 1 replica each, event streaming
- **Redis**: 1 replica, caching layer

#### Configuration
- **ConfigMap**: Environment variables and configuration
- **Secrets**: Sensitive data (passwords, API keys, JWT secrets)
- **Namespace**: Isolated environment for SkillSwap resources

## 🚀 Prerequisites

### Required Tools
```bash
# Kubernetes cluster (choose one)
- Minikube (local development)
- Docker Desktop with Kubernetes
- Google Kubernetes Engine (GKE)
- Amazon EKS
- Azure AKS

# CLI Tools
kubectl >= 1.25
docker >= 20.10
```

### Verify Installation
```bash
# Check kubectl
kubectl version --client

# Check cluster connection
kubectl cluster-info

# Check nodes
kubectl get nodes
```

### Resource Requirements

**Minimum Cluster Resources:**
- **CPU**: 8 cores
- **Memory**: 16 GB RAM
- **Storage**: 50 GB

**Per Service Requirements:**
| Service | CPU Request | CPU Limit | Memory Request | Memory Limit |
|---------|-------------|-----------|----------------|--------------|
| API Gateway | 200m | 500m | 256Mi | 512Mi |
| User Service | 200m | 500m | 256Mi | 512Mi |
| Skill Service | 200m | 500m | 256Mi | 512Mi |
| Mission Service | 200m | 500m | 256Mi | 512Mi |
| Notification Service | 200m | 500m | 256Mi | 512Mi |
| PostgreSQL | 500m | 1000m | 512Mi | 1Gi |
| MongoDB | 500m | 1000m | 512Mi | 1Gi |
| Kafka | 500m | 1000m | 1Gi | 2Gi |
| Redis | 100m | 200m | 128Mi | 256Mi |

## ⚡ Quick Start

### 1. Build Docker Images

```bash
cd skillswap-deployment
chmod +x build-images.sh
./build-images.sh
```

This script:
- Builds Docker images for all microservices
- Tags images with version numbers
- Pushes to Docker registry (optional)

### 2. Configure Secrets

Edit `kubernetes/secrets.yaml` with your actual values:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: skillswap-secrets
  namespace: skillswap
type: Opaque
stringData:
  # Database Credentials
  postgres-password: "YOUR_POSTGRES_PASSWORD"
  mongodb-root-password: "YOUR_MONGODB_PASSWORD"
  
  # JWT Secret
  jwt-secret: "YOUR_JWT_SECRET_KEY_MIN_32_CHARS"
  
  # Firebase (base64 encoded service account JSON)
  firebase-service-account: "BASE64_ENCODED_JSON"
```

**Generate JWT Secret:**
```bash
openssl rand -base64 32
```

**Encode Firebase Service Account:**
```bash
base64 -i firebase-service-account.json
```

### 3. Deploy Everything

```bash
cd kubernetes
chmod +x deploy-all.sh
./deploy-all.sh
```

### 4. Verify Deployment

```bash
# Check all pods are running
kubectl get pods -n skillswap

# Check services
kubectl get svc -n skillswap

# Get API Gateway external IP
kubectl get svc api-gateway -n skillswap
```

### 5. Access the Application

```bash
# Get the external IP
export API_GATEWAY_IP=$(kubectl get svc api-gateway -n skillswap -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test the API
curl http://$API_GATEWAY_IP:8080/actuator/health
```

## 📝 Detailed Deployment

### Step 1: Create Namespace

```bash
kubectl apply -f namespace.yaml
```

This creates an isolated namespace `skillswap` for all resources.

### Step 2: Create Secrets

```bash
# Edit secrets.yaml with your values
kubectl apply -f secrets.yaml

# Verify secrets
kubectl get secrets -n skillswap
```

### Step 3: Create ConfigMap

```bash
kubectl apply -f configmap.yaml

# View configuration
kubectl describe configmap skillswap-config -n skillswap
```

The ConfigMap contains:
- Service URLs
- Database connection strings
- Kafka bootstrap servers
- Redis configuration
- Application properties

### Step 4: Deploy Databases

```bash
# Deploy PostgreSQL
kubectl apply -f postgres-deployment.yaml

# Deploy MongoDB
kubectl apply -f mongodb-deployment.yaml

# Wait for databases to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n skillswap --timeout=300s
kubectl wait --for=condition=ready pod -l app=mongodb -n skillswap --timeout=300s

# Verify
kubectl get statefulsets -n skillswap
kubectl get pvc -n skillswap
```

**PostgreSQL Details:**
- StatefulSet with 1 replica
- PersistentVolumeClaim: 10Gi
- Service: postgres-service (ClusterIP)
- Port: 5432

**MongoDB Details:**
- StatefulSet with 1 replica
- PersistentVolumeClaim: 20Gi
- Service: mongodb-service (ClusterIP)
- Port: 27017

### Step 5: Deploy Kafka & Zookeeper

```bash
# Deploy Zookeeper first
kubectl apply -f zookeeper-deployment.yaml

# Wait for Zookeeper
kubectl wait --for=condition=ready pod -l app=zookeeper -n skillswap --timeout=180s

# Deploy Kafka
kubectl apply -f kafka-deployment.yaml

# Wait for Kafka
kubectl wait --for=condition=ready pod -l app=kafka -n skillswap --timeout=180s
```

### Step 6: Deploy Redis

```bash
kubectl apply -f redis-deployment.yaml

# Verify
kubectl get pods -l app=redis -n skillswap
```

### Step 7: Deploy Microservices

Deploy in order to handle dependencies:

```bash
# 1. User Service (no dependencies)
kubectl apply -f user-service-deployment.yaml
kubectl wait --for=condition=ready pod -l app=user-service -n skillswap --timeout=300s

# 2. Skill Service (no dependencies)
kubectl apply -f skill-service-deployment.yaml
kubectl wait --for=condition=ready pod -l app=skill-service -n skillswap --timeout=300s

# 3. Mission Service (depends on Skill Service)
kubectl apply -f mission-service-deployment.yaml
kubectl wait --for=condition=ready pod -l app=mission-service -n skillswap --timeout=300s

# 4. Notification Service (depends on Kafka)
kubectl apply -f notification-service-deployment.yaml
kubectl wait --for=condition=ready pod -l app=notification-service -n skillswap --timeout=300s

# 5. API Gateway (depends on all services)
kubectl apply -f api-gateway-deployment.yaml
kubectl wait --for=condition=ready pod -l app=api-gateway -n skillswap --timeout=300s
```

### Step 8: Verify Deployment

```bash
# Check all pods
kubectl get pods -n skillswap -o wide

# Check services
kubectl get svc -n skillswap

# Check deployments
kubectl get deployments -n skillswap

# Check statefulsets
kubectl get statefulsets -n skillswap

# Check persistent volumes
kubectl get pv
kubectl get pvc -n skillswap
```

Expected output:
```
NAME                                    READY   STATUS    RESTARTS   AGE
api-gateway-xxxxxxxxxx-xxxxx            1/1     Running   0          2m
user-service-xxxxxxxxxx-xxxxx           1/1     Running   0          3m
skill-service-xxxxxxxxxx-xxxxx          1/1     Running   0          3m
mission-service-xxxxxxxxxx-xxxxx        1/1     Running   0          3m
notification-service-xxxxxxxxxx-xxxxx   1/1     Running   0          3m
postgres-0                              1/1     Running   0          5m
mongodb-0                               1/1     Running   0          5m
kafka-0                                 1/1     Running   0          4m
zookeeper-0                             1/1     Running   0          4m
redis-xxxxxxxxxx-xxxxx                  1/1     Running   0          4m
```

## ⚙️ Configuration

### Environment Variables

All services use environment variables from ConfigMap and Secrets:

**ConfigMap Variables:**
```yaml
# Service Discovery
USER_SERVICE_URL: "http://user-service:8081"
SKILL_SERVICE_URL: "http://skill-service:8082"
MISSION_SERVICE_URL: "http://mission-service:8083"

# Database URLs
POSTGRES_HOST: "postgres-service"
MONGODB_HOST: "mongodb-service"
REDIS_HOST: "redis-service"
KAFKA_BOOTSTRAP_SERVERS: "kafka-service:9092"

# Application Settings
SPRING_PROFILES_ACTIVE: "prod"
```

**Secret Variables:**
```yaml
# Injected as environment variables
DB_PASSWORD: from secret
JWT_SECRET: from secret
FIREBASE_CREDENTIALS: from secret (mounted as file)
```

### Updating Configuration

```bash
# Edit ConfigMap
kubectl edit configmap skillswap-config -n skillswap

# Edit Secrets
kubectl edit secret skillswap-secrets -n skillswap

# Restart pods to pick up changes
kubectl rollout restart deployment/user-service -n skillswap
kubectl rollout restart deployment/skill-service -n skillswap
# ... repeat for other services
```

### Resource Limits

Each deployment has resource requests and limits:

```yaml
resources:
  requests:
    cpu: "200m"      # Minimum guaranteed CPU
    memory: "256Mi"  # Minimum guaranteed memory
  limits:
    cpu: "500m"      # Maximum CPU
    memory: "512Mi"  # Maximum memory
```

**Adjust for your cluster:**
```bash
kubectl edit deployment user-service -n skillswap
# Modify resources section
```

## 📊 Monitoring

### Health Checks

All services have health probes:

**Liveness Probe**: Restarts pod if unhealthy
```yaml
livenessProbe:
  httpGet:
    path: /actuator/health
    port: 8081
  initialDelaySeconds: 60
  periodSeconds: 10
```

**Readiness Probe**: Removes from service if not ready
```yaml
readinessProbe:
  httpGet:
    path: /actuator/health
    port: 8081
  initialDelaySeconds: 30
  periodSeconds: 5
```

### Check Service Health

```bash
# Check pod health
kubectl get pods -n skillswap

# Describe pod for events
kubectl describe pod <pod-name> -n skillswap

# Check logs
kubectl logs <pod-name> -n skillswap

# Follow logs
kubectl logs -f <pod-name> -n skillswap

# Check previous container logs (if crashed)
kubectl logs <pod-name> -n skillswap --previous
```

### Metrics

```bash
# Pod resource usage
kubectl top pods -n skillswap

# Node resource usage
kubectl top nodes

# Detailed pod metrics
kubectl describe pod <pod-name> -n skillswap | grep -A 5 "Requests\|Limits"
```

### Port Forwarding for Testing

```bash
# Forward API Gateway
kubectl port-forward svc/api-gateway 8080:8080 -n skillswap

# Forward User Service
kubectl port-forward svc/user-service 8081:8081 -n skillswap

# Forward MongoDB
kubectl port-forward svc/mongodb-service 27017:27017 -n skillswap

# Forward PostgreSQL
kubectl port-forward svc/postgres-service 5432:5432 -n skillswap
```

## 📈 Scaling

### Manual Scaling

```bash
# Scale User Service to 3 replicas
kubectl scale deployment user-service --replicas=3 -n skillswap

# Scale all services
kubectl scale deployment api-gateway --replicas=3 -n skillswap
kubectl scale deployment user-service --replicas=3 -n skillswap
kubectl scale deployment skill-service --replicas=3 -n skillswap
kubectl scale deployment mission-service --replicas=3 -n skillswap
kubectl scale deployment notification-service --replicas=3 -n skillswap

# Verify
kubectl get deployments -n skillswap
```

### Horizontal Pod Autoscaling (HPA)

Create HPA for automatic scaling:

```bash
# Create HPA for User Service
kubectl autoscale deployment user-service \
  --cpu-percent=70 \
  --min=2 \
  --max=10 \
  -n skillswap

# Create HPA for all services
kubectl autoscale deployment api-gateway --cpu-percent=70 --min=2 --max=10 -n skillswap
kubectl autoscale deployment skill-service --cpu-percent=70 --min=2 --max=10 -n skillswap
kubectl autoscale deployment mission-service --cpu-percent=70 --min=2 --max=10 -n skillswap
kubectl autoscale deployment notification-service --cpu-percent=70 --min=2 --max=10 -n skillswap

# View HPA status
kubectl get hpa -n skillswap

# Describe HPA
kubectl describe hpa user-service -n skillswap
```

### Database Scaling

**PostgreSQL:**
```bash
# Scale to 3 replicas (requires replication setup)
kubectl scale statefulset postgres --replicas=3 -n skillswap
```

**MongoDB:**
```bash
# Scale to 3 replicas (requires replica set configuration)
kubectl scale statefulset mongodb --replicas=3 -n skillswap
```

**Note**: Database scaling requires additional configuration for replication and clustering.

## 🔧 Troubleshooting

### Common Issues

#### 1. Pods Not Starting

```bash
# Check pod status
kubectl get pods -n skillswap

# Describe pod for events
kubectl describe pod <pod-name> -n skillswap

# Check logs
kubectl logs <pod-name> -n skillswap

# Common causes:
# - Image pull errors
# - Resource constraints
# - Configuration errors
# - Health check failures
```

#### 2. Service Not Accessible

```bash
# Check service
kubectl get svc -n skillswap

# Check endpoints
kubectl get endpoints -n skillswap

# Test service internally
kubectl run test-pod --image=curlimages/curl -it --rm -n skillswap -- sh
# Inside pod:
curl http://user-service:8081/actuator/health
```

#### 3. Database Connection Issues

```bash
# Check database pods
kubectl get pods -l app=postgres -n skillswap
kubectl get pods -l app=mongodb -n skillswap

# Check database logs
kubectl logs postgres-0 -n skillswap
kubectl logs mongodb-0 -n skillswap

# Test database connection
kubectl exec -it postgres-0 -n skillswap -- psql -U postgres
kubectl exec -it mongodb-0 -n skillswap -- mongo
```

#### 4. Persistent Volume Issues

```bash
# Check PVCs
kubectl get pvc -n skillswap

# Check PVs
kubectl get pv

# Describe PVC
kubectl describe pvc postgres-pvc -n skillswap

# Common causes:
# - No available storage class
# - Insufficient storage
# - PV not bound
```

#### 5. Out of Memory (OOMKilled)

```bash
# Check pod events
kubectl describe pod <pod-name> -n skillswap | grep -A 10 "Events"

# Increase memory limits
kubectl edit deployment <service-name> -n skillswap
# Increase memory limits in resources section
```

### Debug Commands

```bash
# Get all resources
kubectl get all -n skillswap

# Get events
kubectl get events -n skillswap --sort-by='.lastTimestamp'

# Execute command in pod
kubectl exec -it <pod-name> -n skillswap -- /bin/sh

# Copy files from pod
kubectl cp <pod-name>:/path/to/file ./local-file -n skillswap

# Check resource usage
kubectl top pods -n skillswap
kubectl top nodes

# View pod YAML
kubectl get pod <pod-name> -n skillswap -o yaml

# View service YAML
kubectl get svc <service-name> -n skillswap -o yaml
```

## 🛠️ Maintenance

### Rolling Updates

```bash
# Update image version
kubectl set image deployment/user-service \
  user-service=skillswap/user-service:v2.0.0 \
  -n skillswap

# Check rollout status
kubectl rollout status deployment/user-service -n skillswap

# View rollout history
kubectl rollout history deployment/user-service -n skillswap

# Rollback to previous version
kubectl rollout undo deployment/user-service -n skillswap

# Rollback to specific revision
kubectl rollout undo deployment/user-service --to-revision=2 -n skillswap
```

### Backup and Restore

**PostgreSQL Backup:**
```bash
# Backup
kubectl exec postgres-0 -n skillswap -- pg_dump -U postgres skillswap_users > backup.sql

# Restore
kubectl exec -i postgres-0 -n skillswap -- psql -U postgres skillswap_users < backup.sql
```

**MongoDB Backup:**
```bash
# Backup
kubectl exec mongodb-0 -n skillswap -- mongodump --out=/tmp/backup
kubectl cp mongodb-0:/tmp/backup ./mongodb-backup -n skillswap

# Restore
kubectl cp ./mongodb-backup mongodb-0:/tmp/restore -n skillswap
kubectl exec mongodb-0 -n skillswap -- mongorestore /tmp/restore
```

### Cleanup

```bash
# Delete all resources in namespace
kubectl delete namespace skillswap

# Delete specific resources
kubectl delete deployment user-service -n skillswap
kubectl delete svc user-service -n skillswap
kubectl delete pvc postgres-pvc -n skillswap

# Delete all deployments
kubectl delete deployments --all -n skillswap

# Delete all services
kubectl delete services --all -n skillswap
```

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Spring Boot on Kubernetes](https://spring.io/guides/gs/spring-boot-kubernetes/)
- [MongoDB on Kubernetes](https://www.mongodb.com/kubernetes)
- [PostgreSQL on Kubernetes](https://www.postgresql.org/docs/current/high-availability.html)

## 🤝 Support

For issues or questions:
1. Check logs: `kubectl logs <pod-name> -n skillswap`
2. Check events: `kubectl get events -n skillswap`
3. Review this documentation
4. Contact the development team

---

**Last Updated**: January 25, 2026