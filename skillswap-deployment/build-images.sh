#!/bin/bash

# SkillSwap - Build All Docker Images
# This script builds Docker images for all microservices

set -e

echo "======================================"
echo "Building SkillSwap Docker Images"
echo "======================================"

# Navigate to backend directory
cd ../skillswap-backend

# Build API Gateway
echo ""
echo "[1/5] Building API Gateway..."
cd skillswap-api-gateway
mvn clean package -DskipTests
docker build -t skillswap/api-gateway:latest .
cd ..

# Build User Service
echo ""
echo "[2/5] Building User Service..."
cd skillswap-service-user
mvn clean package -DskipTests
docker build -t skillswap/user-service:latest .
cd ..

# Build Skill Service
echo ""
echo "[3/5] Building Skill Service..."
cd skillswap-service-skill
mvn clean package -DskipTests
docker build -t skillswap/skill-service:latest .
cd ..

# Build Mission Service
echo ""
echo "[4/5] Building Mission Service..."
cd skillswap-service-mission
mvn clean package -DskipTests
docker build -t skillswap/mission-service:latest .
cd ..

# Build Notification Service
echo ""
echo "[5/5] Building Notification Service..."
cd skillswap-service-notification
mvn clean package -DskipTests
docker build -t skillswap/notification-service:latest .
cd ..

echo ""
echo "======================================"
echo "✅ All images built successfully!"
echo "======================================"
echo ""
echo "Built images:"
docker images | grep skillswap
