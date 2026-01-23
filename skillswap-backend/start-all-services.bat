@echo off
echo ========================================
echo Starting SkillSwap Services
echo ========================================
echo.

echo Starting Service User (Port 8081)...
start "User Service" cmd /k "cd skillswap-service-user && mvn spring-boot:run"
timeout /t 30

echo Starting Service Skill (Port 8082)...
start "Skill Service" cmd /k "cd skillswap-service-skill && mvn spring-boot:run"
timeout /t 30

echo Starting API Gateway (Port 8080)...
start "API Gateway" cmd /k "cd skillswap-api-gateway && mvn spring-boot:run"

echo.
echo ========================================
echo All services are starting...
echo ========================================
echo.
echo User Service:    http://localhost:8081
echo Skill Service:   http://localhost:8082
echo API Gateway:     http://localhost:8080
echo.
echo Wait 1-2 minutes for all services to start
echo.
pause
