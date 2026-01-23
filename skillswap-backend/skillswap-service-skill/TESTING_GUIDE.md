# Guide de Test - Skill Service

## 🧪 Tests avec cURL

### 1. Créer une compétence

```bash
curl -X POST http://localhost:8082/api/skills \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 123e4567-e89b-12d3-a456-426614174000" \
  -d '{
    "title": "Cours de guitare",
    "description": "Cours de guitare acoustique pour débutants et intermédiaires",
    "category": "MUSIQUE",
    "latitude": 48.8566,
    "longitude": 2.3522
  }'
```

### 2. Rechercher des compétences à proximité

```bash
# Recherche dans un rayon de 10 km
curl "http://localhost:8082/api/skills/near?lat=48.8566&lng=2.3522&radius=10"

# Recherche avec filtre de catégorie
curl "http://localhost:8082/api/skills/near?lat=48.8566&lng=2.3522&radius=10&category=MUSIQUE"

# Recherche dans un rayon de 50 km
curl "http://localhost:8082/api/skills/near?lat=48.8566&lng=2.3522&radius=50"
```

### 3. Obtenir les compétences d'un utilisateur

```bash
curl http://localhost:8082/api/skills/user/123e4567-e89b-12d3-a456-426614174000
```

### 4. Obtenir une compétence par ID

```bash
curl http://localhost:8082/api/skills/{skillId}
```

### 5. Mettre à jour une compétence

```bash
curl -X PUT http://localhost:8082/api/skills/{skillId} \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 123e4567-e89b-12d3-a456-426614174000" \
  -d '{
    "title": "Cours de guitare avancé",
    "description": "Cours de guitare pour niveau avancé",
    "active": true
  }'
```

### 6. Supprimer une compétence

```bash
curl -X DELETE http://localhost:8082/api/skills/{skillId} \
  -H "X-User-Id: 123e4567-e89b-12d3-a456-426614174000"
```

## 🧪 Tests avec Postman

### Collection Postman

Créer une collection avec les variables:
- `baseUrl`: http://localhost:8082
- `userId`: 123e4567-e89b-12d3-a456-426614174000

### Scénario de test complet

1. **Créer plusieurs compétences** dans différentes localisations:
   - Paris (48.8566, 2.3522)
   - Lyon (45.7640, 4.8357)
   - Marseille (43.2965, 5.3698)

2. **Tester la recherche géographique**:
   - Depuis Paris avec rayon 10 km → devrait trouver les compétences parisiennes
   - Depuis Paris avec rayon 500 km → devrait trouver toutes les compétences
   - Depuis Lyon avec rayon 50 km → devrait trouver uniquement Lyon

3. **Tester les filtres**:
   - Recherche avec catégorie MUSIQUE
   - Recherche avec catégorie SPORT
   - Recherche sans catégorie

4. **Tester les permissions**:
   - Essayer de modifier une compétence d'un autre utilisateur → devrait échouer
   - Essayer de supprimer une compétence d'un autre utilisateur → devrait échouer

## 📊 Données de test

### Compétences à Paris

```json
[
  {
    "title": "Cours de guitare",
    "description": "Cours de guitare acoustique",
    "category": "MUSIQUE",
    "latitude": 48.8566,
    "longitude": 2.3522
  },
  {
    "title": "Réparation vélo",
    "description": "Réparation et entretien de vélos",
    "category": "BRICOLAGE",
    "latitude": 48.8606,
    "longitude": 2.3376
  },
  {
    "title": "Cours de yoga",
    "description": "Cours de yoga pour tous niveaux",
    "category": "SPORT",
    "latitude": 48.8529,
    "longitude": 2.3499
  }
]
```

### Compétences à Lyon

```json
[
  {
    "title": "Cours de mathématiques",
    "description": "Soutien scolaire en mathématiques",
    "category": "SCOLAIRE",
    "latitude": 45.7640,
    "longitude": 4.8357
  },
  {
    "title": "Développement web",
    "description": "Formation en développement web",
    "category": "INFORMATIQUE",
    "latitude": 45.7578,
    "longitude": 4.8320
  }
]
```

## 🔍 Vérification MongoDB

### Vérifier l'index géospatial

```javascript
db.skills.getIndexes()
```

Devrait afficher un index sur `geoPoint` de type `2dsphere`.

### Vérifier les données

```javascript
// Compter les compétences
db.skills.countDocuments()

// Afficher toutes les compétences
db.skills.find().pretty()

// Recherche géospatiale manuelle
db.skills.find({
  geoPoint: {
    $near: {
      $geometry: {
        type: "Point",
        coordinates: [2.3522, 48.8566]
      },
      $maxDistance: 10000 // 10 km en mètres
    }
  }
})
```

## ✅ Checklist de validation

- [ ] Création de compétence avec géolocalisation
- [ ] Recherche par proximité fonctionne
- [ ] Filtre par catégorie fonctionne
- [ ] Tri par distance fonctionne
- [ ] Seules les compétences actives sont retournées
- [ ] Mise à jour uniquement par le propriétaire
- [ ] Suppression uniquement par le propriétaire
- [ ] Validation des champs obligatoires
- [ ] Gestion des erreurs (404, 403, 400)
- [ ] Index géospatial créé automatiquement

## 🐛 Problèmes courants

### Erreur: "Index not found"
**Solution**: Vérifier que `auto-index-creation: true` est dans application.yml

### Erreur: "Invalid coordinates"
**Solution**: Vérifier que longitude est entre -180 et 180, latitude entre -90 et 90

### Aucun résultat dans la recherche
**Solution**: 
- Vérifier que les compétences sont `active: true`
- Augmenter le rayon de recherche
- Vérifier les coordonnées (longitude, latitude)

### Erreur 403 lors de la modification
**Solution**: Vérifier que le header `X-User-Id` correspond au `ownerId` de la compétence
