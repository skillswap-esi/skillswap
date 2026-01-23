@echo off
REM Script de test de l'API Skill Service pour Windows
REM Usage: test-api.bat

set BASE_URL=http://localhost:8082
set USER_ID=123e4567-e89b-12d3-a456-426614174000

echo Testing SkillSwap Skill Service API
echo ========================================
echo.

echo Test 1: Creer une competence a Paris
curl -X POST "%BASE_URL%/api/skills" ^
  -H "Content-Type: application/json" ^
  -H "X-User-Id: %USER_ID%" ^
  -d "{\"title\":\"Cours de guitare\",\"description\":\"Cours de guitare acoustique pour debutants\",\"category\":\"MUSIQUE\",\"latitude\":48.8566,\"longitude\":2.3522}"
echo.
echo.

echo Test 2: Creer une competence de bricolage
curl -X POST "%BASE_URL%/api/skills" ^
  -H "Content-Type: application/json" ^
  -H "X-User-Id: %USER_ID%" ^
  -d "{\"title\":\"Reparation velo\",\"description\":\"Reparation et entretien de velos\",\"category\":\"BRICOLAGE\",\"latitude\":48.8606,\"longitude\":2.3376}"
echo.
echo.

echo Test 3: Rechercher des competences a proximite de Paris
curl "%BASE_URL%/api/skills/near?lat=48.8566&lng=2.3522&radius=10"
echo.
echo.

echo Test 4: Rechercher uniquement les competences MUSIQUE
curl "%BASE_URL%/api/skills/near?lat=48.8566&lng=2.3522&radius=10&category=MUSIQUE"
echo.
echo.

echo Test 5: Obtenir toutes les competences de l'utilisateur
curl "%BASE_URL%/api/skills/user/%USER_ID%"
echo.
echo.

echo Tests termines!
echo.
pause
