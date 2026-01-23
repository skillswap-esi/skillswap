# 🚀 Quick Start - Skill Service

## Démarrage en 5 minutes

### 1. Prérequis

```bash
# Vérifier Java
java -version  # Doit être 17+

# Vérifier Maven
mvn -version   # Doit être 3.6+

# Vérifier MongoDB (local ou Atlas)
```

### 2. Configuration

```bash
# Option A: MongoDB local
export MONGODB_URI="mongodb://localhost:27017/skillswap-skills"

# Option B: MongoDB Atlas (recommandé)
export MONGODB_URI="mongodb+srv://user:password@cluster.mongodb.net/skillswap-skills"
```

### 3. Lancer le service

```bash
cd skillswap-backend/skillswap-service-skill
mvn spring-boot:run
```

Le service démarre sur **http://localhost:8082**

### 4. Test rapide

#### Windows (PowerShell/CMD)
```bash
test-api.bat
```

#### Linux/Mac
```bash
chmod +x test-api.sh
./test-api.sh
```

#### Ou avec cURL
```bash
# Créer une compétence
curl -X POST http://localhost:8082/api/skills \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 123e4567-e89b-12d3-a456-426614174000" \
  -d '{
    "title": "Cours de guitare",
    "description": "Cours de guitare pour débutants",
    "category": "MUSIQUE",
    "latitude": 48.8566,
    "longitude": 2.3522
  }'

# Rechercher à proximité
curl "http://localhost:8082/api/skills/near?lat=48.8566&lng=2.3522&radius=10"
```

### 5. Importer dans Postman

1. Ouvrir Postman
2. Import → File
3. Sélectionner `SkillSwap-Skill-Service.postman_collection.json`
4. Exécuter les requêtes dans l'ordre

## 📚 Documentation complète

- **README.md**: Vue d'ensemble et API
- **TESTING_GUIDE.md**: Tests détaillés
- **IMPLEMENTATION_NOTES.md**: Architecture technique
- **SUMMARY.md**: Résumé complet

## 🐛 Problèmes courants

### Le service ne démarre pas
```bash
# Vérifier que le port 8082 est libre
netstat -ano | findstr :8082  # Windows
lsof -i :8082                 # Linux/Mac
```

### Erreur de connexion MongoDB
```bash
# Vérifier la connexion
mongosh "mongodb://localhost:27017"

# Ou tester l'URI Atlas
mongosh "mongodb+srv://user:password@cluster.mongodb.net"
```

### Index géospatial non créé
```javascript
// Dans MongoDB shell
use skillswap-skills
db.skills.createIndex({ geoPoint: "2dsphere" })
```

## ✅ Checklist de validation

- [ ] Service démarre sans erreur
- [ ] Création de compétence fonctionne
- [ ] Recherche géographique retourne des résultats
- [ ] Filtrage par catégorie fonctionne
- [ ] Mise à jour nécessite le bon userId
- [ ] Suppression nécessite le bon userId

## 🎯 Prochaines étapes

1. Tester tous les endpoints
2. Créer des données de test variées
3. Vérifier les index MongoDB
4. Intégrer avec API Gateway
5. Connecter avec Service User

## 💡 Astuces

- Utiliser Postman pour sauvegarder les skillId automatiquement
- Créer des compétences dans différentes villes pour tester la géolocalisation
- Vérifier les logs pour le debugging: `tail -f logs/skill-service.log`
- Utiliser Mongo Express pour visualiser les données: http://localhost:8081

## 📞 Support

En cas de problème:
1. Vérifier les logs du service
2. Consulter TESTING_GUIDE.md
3. Vérifier IMPLEMENTATION_NOTES.md
4. Consulter l'ARCHITECTURE.md du projet
