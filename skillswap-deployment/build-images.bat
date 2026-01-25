@echo off
REM SkillSwap - Build All Docker Images (Windows)
REM This script builds Docker images for all microservices

echo ======================================
echo Building SkillSwap Docker Images
echo ======================================

cd ..\skillswap-backend

REM Build API Gateway
echo.
echo [1/5] Building API Gateway...
cd skillswap-api-gateway
call mvn clean package -DskipTests
docker build -t skillswap/api-gateway:latest .
cd ..

REM Build User Service
echo.
echo [2/5] Building User Service...
cd skillswap-service-user
call mvn clean package -DskipTests
docker build -t skillswap/user-service:latest .
cd ..

REM Build Skill Service
echo.
echo [3/5] Building Skill Service...
cd skillswap-service-skill
call mvn clean package -DskipTests
docker build -t skillswap/skill-service:latest .
cd ..

REM Build Mission Service
echo.
echo [4/5] Building Mission Service...
cd skillswap-service-mission
call mvn clean package -DskipTests
docker build -t skillswap/mission-service:latest .
cd ..

REM Build Notification Service
echo.
echo [5/5] Building Notification Service...
cd skillswap-service-notification
call mvn clean package -DskipTests
docker build -t skillswap/notification-service:latest .
cd ..

echo.
echo ======================================
echo All images built successfully!
echo ======================================
echo.
echo Built images:
docker images | findstr skillswap

cd ..\skillswap-deployment
