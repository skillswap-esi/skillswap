#!/bin/bash

# Script de test de l'API Skill Service
# Usage: ./test-api.sh

BASE_URL="http://localhost:8082"
USER_ID="123e4567-e89b-12d3-a456-426614174000"

echo "🧪 Testing SkillSwap Skill Service API"
echo "========================================"
echo ""

# Test 1: Créer une compétence à Paris
echo "📍 Test 1: Créer une compétence à Paris"
SKILL_RESPONSE=$(curl -s -X POST "$BASE_URL/api/skills" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $USER_ID" \
  -d '{
    "title": "Cours de guitare",
    "description": "Cours de guitare acoustique pour débutants",
    "category": "MUSIQUE",
    "latitude": 48.8566,
    "longitude": 2.3522
  }')

SKILL_ID=$(echo $SKILL_RESPONSE | grep -o '"skillId":"[^"]*' | cut -d'"' -f4)
echo "✅ Compétence créée avec ID: $SKILL_ID"
echo ""

# Test 2: Créer une autre compétence à Paris
echo "📍 Test 2: Créer une compétence de bricolage"
curl -s -X POST "$BASE_URL/api/skills" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $USER_ID" \
  -d '{
    "title": "Réparation vélo",
    "description": "Réparation et entretien de vélos",
    "category": "BRICOLAGE",
    "latitude": 48.8606,
    "longitude": 2.3376
  }' > /dev/null
echo "✅ Compétence de bricolage créée"
echo ""

# Test 3: Rechercher des compétences à proximité
echo "🔍 Test 3: Rechercher des compétences à proximité de Paris"
curl -s "$BASE_URL/api/skills/near?lat=48.8566&lng=2.3522&radius=10" | jq '.'
echo ""

# Test 4: Rechercher avec filtre de catégorie
echo "🔍 Test 4: Rechercher uniquement les compétences MUSIQUE"
curl -s "$BASE_URL/api/skills/near?lat=48.8566&lng=2.3522&radius=10&category=MUSIQUE" | jq '.'
echo ""

# Test 5: Obtenir les compétences d'un utilisateur
echo "👤 Test 5: Obtenir toutes les compétences de l'utilisateur"
curl -s "$BASE_URL/api/skills/user/$USER_ID" | jq '.'
echo ""

# Test 6: Obtenir une compétence par ID
if [ ! -z "$SKILL_ID" ]; then
  echo "📄 Test 6: Obtenir la compétence par ID"
  curl -s "$BASE_URL/api/skills/$SKILL_ID" | jq '.'
  echo ""
  
  # Test 7: Mettre à jour la compétence
  echo "✏️ Test 7: Mettre à jour la compétence"
  curl -s -X PUT "$BASE_URL/api/skills/$SKILL_ID" \
    -H "Content-Type: application/json" \
    -H "X-User-Id: $USER_ID" \
    -d '{
      "title": "Cours de guitare avancé",
      "active": true
    }' | jq '.'
  echo ""
fi

echo "✅ Tests terminés!"
echo ""
echo "💡 Pour supprimer une compétence:"
echo "   curl -X DELETE $BASE_URL/api/skills/{skillId} -H \"X-User-Id: $USER_ID\""
