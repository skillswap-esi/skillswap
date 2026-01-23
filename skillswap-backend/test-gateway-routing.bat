@echo off
echo ========================================
echo Testing API Gateway Routing
echo ========================================
echo.

set GATEWAY=http://localhost:8080

echo Test 1: API Gateway Health Check
echo ----------------------------------------
curl -s %GATEWAY%/actuator/health
echo.
echo.

echo Test 2: Route to User Service (Health)
echo ----------------------------------------
curl -s %GATEWAY%/api/users/health
echo.
echo.

echo Test 3: Route to Skill Service (Health)
echo ----------------------------------------
curl -s %GATEWAY%/api/skills/health
echo.
echo.

echo Test 4: Register User through Gateway
echo ----------------------------------------
curl -X POST %GATEWAY%/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"gateway-test@example.com\",\"phoneNumber\":\"+33612345678\",\"fullName\":\"Gateway Test\"}"
echo.
echo.

echo ========================================
echo Gateway routing tests completed!
echo ========================================
echo.
echo If all tests passed, the API Gateway is working correctly.
echo The mobile app can now communicate through the gateway.
echo.
pause
