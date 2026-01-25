#!/bin/bash

# SkillSwap - Deploy to Kubernetes
# This script deploys all components to Kubernetes cluster

set -e

echo "======================================"
echo "Deploying SkillSwap to Kubernetes"
echo "======================================"

# Create namespace
echo ""
echo "[1/11] Creating namespace..."
kubectl apply -f namespace.yaml

# Create ConfigMap and Secrets
echo ""
echo "[2/11] Creating ConfigMap..."
kubectl apply -f configmap.yaml

echo ""
echo "[3/11] Creating Secrets..."
kubectl apply -f secrets.yaml

# Deploy databases
echo ""
echo "[4/11] Deploying PostgreSQL..."
kubectl apply -f postgres-deployment.yaml

echo ""
echo "[5/11] Deploying MongoDB..."
kubectl apply -f mongodb-deployment.yaml

# Deploy Kafka
echo ""
echo "[6/11] Deploying Kafka & Zookeeper..."
kubectl apply -f kafka-deployment.yaml

# Wait for databases to be ready
echo ""
echo "Waiting for databases to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n skillswap --timeout=300s
kubectl wait --for=condition=ready pod -l app=mongodb -n skillswap --timeout=300s
kubectl wait --for=condition=ready pod -l app=zookeeper -n skillswap --timeout=300s
kubectl wait --for=condition=ready pod -l app=kafka -n skillswap --timeout=300s

# Deploy microservices
echo ""
echo "[7/11] Deploying User Service..."
kubectl apply -f user-service-deployment.yaml

echo ""
echo "[8/11] Deploying Skill Service..."
kubectl apply -f skill-service-deployment.yaml

echo ""
echo "[9/11] Deploying Mission Service..."
kubectl apply -f mission-service-deployment.yaml

echo ""
echo "[10/11] Deploying Notification Service..."
kubectl apply -f notification-service-deployment.yaml

echo ""
echo "[11/11] Deploying API Gateway..."
kubectl apply -f api-gateway-deployment.yaml

echo ""
echo "======================================"
echo "✅ Deployment Complete!"
echo "======================================"
echo ""
echo "Checking deployment status..."
kubectl get pods -n skillswap
echo ""
echo "Services:"
kubectl get services -n skillswap
echo ""
echo "To access the API Gateway:"
echo "kubectl port-forward -n skillswap service/api-gateway-service 8080:8080"
