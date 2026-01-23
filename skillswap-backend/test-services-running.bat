@echo off
echo ========================================
echo Testing SkillSwap Services
echo ========================================
echo.

echo Testing API Gateway (port 8080)...
curl -s http://localhost:8080/actuator/health 2>nul
if %errorlevel% neq 0 (
    echo [X] API Gateway NOT running on port 8080
) else (
    echo [OK] API Gateway is running
)
echo.

echo Testing User Service (port 8081)...
curl -s http://localhost:8081/actuator/health 2>nul
if %errorlevel% neq 0 (
    echo [X] User Service NOT running on port 8081
) else (
    echo [OK] User Service is running
)
echo.

echo Testing Skill Service (port 8082)...
curl -s http://localhost:8082/actuator/health 2>nul
if %errorlevel% neq 0 (
    echo [X] Skill Service NOT running on port 8082
) else (
    echo [OK] Skill Service is running
)
echo.

echo ========================================
echo Testing API Gateway Routes
echo ========================================
echo.

echo Testing auth endpoint (should be accessible)...
curl -X POST http://localhost:8080/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@test.com\",\"fullName\":\"Test\",\"idToken\":\"test\"}" ^
  2>nul
echo.
echo.

echo ========================================
echo If services are not running, start them:
echo ========================================
echo.
echo Terminal 1: cd skillswap-service-user ^&^& mvn spring-boot:run
echo Terminal 2: cd skillswap-service-skill ^&^& mvn spring-boot:run
echo Terminal 3: cd skillswap-api-gateway ^&^& mvn spring-boot:run
echo.
pause
