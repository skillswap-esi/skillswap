@echo off
echo ========================================
echo Creating MongoDB Collections
echo ========================================
echo.
echo This script will create the collections by inserting test data.
echo Make sure all services are running!
echo.
pause

set GATEWAY=http://localhost:8080

echo.
echo Step 1: Creating User (this creates 'users' collection)
echo ----------------------------------------
curl -X POST %GATEWAY%/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test-collection@example.com\",\"phoneNumber\":\"+33612345678\",\"fullName\":\"Test Collection User\"}"
echo.
echo.

echo Step 2: Login to get JWT token
echo ----------------------------------------
echo Please copy the JWT token from the response above
echo.
set /p JWT_TOKEN="Paste JWT token here: "
echo.

echo Step 3: Creating Skill (this creates 'skills' collection)
echo ----------------------------------------
curl -X POST %GATEWAY%/api/skills ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer %JWT_TOKEN%" ^
  -d "{\"title\":\"Test Skill\",\"description\":\"This creates the skills collection\",\"category\":\"INFORMATIQUE\",\"latitude\":48.8566,\"longitude\":2.3522}"
echo.
echo.

echo ========================================
echo Collections Created!
echo ========================================
echo.
echo Now check your MongoDB Atlas:
echo 1. Database: skillswap-users
echo    - Collection: users (should have 1 document)
echo.
echo 2. Database: skillswap-skills
echo    - Collection: skills (should have 1 document)
echo    - Index: geoPoint (2dsphere index)
echo.
pause
