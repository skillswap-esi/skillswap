@echo off
setlocal enabledelayedexpansion

echo ========================================
echo SkillSwap Integration Tests
echo ========================================
echo.

set GATEWAY_URL=http://localhost:8080
set USER_SERVICE_URL=http://localhost:8081
set SKILL_SERVICE_URL=http://localhost:8082

echo Test 1: Health Checks
echo ----------------------------------------
echo.

echo Checking User Service...
curl -s %USER_SERVICE_URL%/actuator/health
echo.

echo Checking Skill Service...
curl -s %SKILL_SERVICE_URL%/actuator/health
echo.

echo Checking API Gateway...
curl -s %GATEWAY_URL%/actuator/health
echo.
echo.

echo Test 2: Register User via Gateway
echo ----------------------------------------
curl -X POST %GATEWAY_URL%/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@example.com\",\"phoneNumber\":\"+33612345678\",\"fullName\":\"Test User\"}"
echo.
echo.

echo Test 3: Login via Gateway
echo ----------------------------------------
echo Please save the JWT token from the response
curl -X POST %GATEWAY_URL%/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@example.com\"}"
echo.
echo.

echo ========================================
echo Integration tests completed!
echo ========================================
echo.
echo Next steps:
echo 1. Copy the JWT token from the login response
echo 2. Use it to create skills:
echo.
echo curl -X POST %GATEWAY_URL%/api/skills ^
echo   -H "Content-Type: application/json" ^
echo   -H "Authorization: Bearer YOUR_JWT_TOKEN" ^
echo   -d "{\"title\":\"Cours de guitare\",\"description\":\"Cours pour debutants\",\"category\":\"MUSIQUE\",\"latitude\":48.8566,\"longitude\":2.3522}"
echo.
pause
