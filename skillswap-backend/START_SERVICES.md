# 🚀 Guide de Démarrage des Services SkillSwap

## 📋 Prérequis

- Java 17+
- Maven 3.6+
- MongoDB Atlas (configuré)
- Ports disponibles: 8080, 8081, 8082

## 🔧 Configuration

### 1. Vérifier les URIs MongoDB

**Service User** (`skillswap-service-user/src/main/resources/application.yml`):
```yaml
spring:
  data:
    mongodb:
      uri: mongodb+srv://skillswap-user:SkillSwap2024!Secure@skillswap.f7fyqzw.mongodb.net/skillswap-users?retryWrites=true&w=majority&appName=skillswap
```

**Service Skill** (`skillswap-service-skill/src/main/resources/application.yml`):
```yaml
spring:
  data:
    mongodb:
      uri: mongodb+srv://skillswap-skill:sHJbFkZ7mpJPMOxN@skillswap.qjsfngt.mongodb.net/skillswap-skills?retryWrites=true&w=majority&appName=skillswap
```

### 2. Vérifier Firebase (Service User uniquement)

Assurez-vous que `firebase-service-account.json` existe dans:
```
skillswap-service-user/src/main/resources/firebase-service-account.json
```

## 🚀 Démarrage des Services

### Option 1: Démarrage Manuel (Recommandé pour le développement)

Ouvrir **3 terminaux** séparés:

#### Terminal 1: Service User (Port 8081)
```bash
cd skillswap-backend/skillswap-service-user
mvn spring-boot:run
```

Attendre le message: `Started UserServiceApplication`

#### Terminal 2: Service Skill (Port 8082)
```bash
cd skillswap-backend/skillswap-service-skill
mvn spring-boot:run
```

Attendre le message: `Started SkillServiceApplication`

#### Terminal 3: API Gateway (Port 8080)
```bash
cd skillswap-backend/skillswap-api-gateway
mvn spring-boot:run
```

Attendre le message: `Started ApiGatewayApplication`

### Option 2: Démarrage avec Script (Windows)

```bash
start-all-services.bat
```

## ✅ Vérification

### 1. Vérifier que les services sont démarrés

```bash
# Service User
curl http://localhost:8081/actuator/health

# Service Skill
curl http://localhost:8082/actuator/health

# API Gateway
curl http://localhost:8080/actuator/health
```

Tous doivent retourner: `{"status":"UP"}`

### 2. Vérifier MongoDB

Les collections seront créées automatiquement lors de la première insertion:
- Base `skillswap-users` → collection `users`
- Base `skillswap-skills` → collection `skills`

## 🧪 Tests de Communication

### Test 1: Créer un utilisateur (via Gateway)

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "phoneNumber": "+33612345678",
    "fullName": "Test User"
  }'
```

**Réponse attendue**: Token JWT + userId

### Test 2: Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com"
  }'
```

**Réponse attendue**: Token JWT

### Test 3: Créer une compétence (via Gateway avec JWT)

```bash
curl -X POST http://localhost:8080/api/skills \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "title": "Cours de guitare",
    "description": "Cours de guitare pour débutants",
    "category": "MUSIQUE",
    "latitude": 48.8566,
    "longitude": 2.3522
  }'
```

**Réponse attendue**: Compétence créée avec skillId

### Test 4: Rechercher des compétences (via Gateway)

```bash
curl "http://localhost:8080/api/skills/near?lat=48.8566&lng=2.3522&radius=10" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Réponse attendue**: Liste des compétences à proximité

## 🔍 Architecture de Communication

```
Client
  ↓
API Gateway (8080)
  ├─→ Service User (8081)
  │   └─→ MongoDB (skillswap-users)
  │
  └─→ Service Skill (8082)
      ├─→ MongoDB (skillswap-skills)
      └─→ Service User (8081) [Feign Client]
```

## 📊 Flux d'Authentification

1. **Client** → POST `/api/auth/login` → **Gateway (8080)**
2. **Gateway** → POST `/auth/login` → **User Service (8081)**
3. **User Service** → Retourne JWT
4. **Client** → Utilise JWT dans header `Authorization: Bearer TOKEN`
5. **Gateway** → Valide JWT → Extrait userId → Ajoute header `X-User-Id`
6. **Services** → Reçoivent `X-User-Id` pour identifier l'utilisateur

## 🗄️ Collections MongoDB

### Collection `users` (Base: skillswap-users)

```javascript
{
  "_id": UUID,
  "email": "string",
  "phoneNumber": "string",
  "fullName": "string",
  "phoneVerified": boolean,
  "creditsBalance": number,
  "helperScore": number,
  "avatar": "string",
  "roles": ["USER"],
  "fcmTokens": [],
  "createdAt": Date,
  "updatedAt": Date,
  "_class": "com.skillswap.user.model.User"
}
```

**Index**:
- `email` (unique)
- `phoneNumber` (unique)

### Collection `skills` (Base: skillswap-skills)

```javascript
{
  "_id": UUID,
  "ownerId": UUID,
  "title": "string",
  "description": "string",
  "category": "string",
  "geoPoint": {
    "type": "Point",
    "coordinates": [longitude, latitude]
  },
  "active": boolean,
  "createdAt": Date,
  "updatedAt": Date,
  "_class": "com.skillswap.skill.model.Skill"
}
```

**Index**:
- `ownerId`
- `category`
- `geoPoint` (2dsphere)

## 🐛 Dépannage

### Erreur: "Database name must not be empty"

**Solution**: Vérifier que l'URI MongoDB contient le nom de la base:
```
mongodb+srv://user:pass@cluster.net/DATABASE_NAME?options
```

### Erreur: "Port already in use"

**Solution**: Tuer le processus sur le port:
```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:8080 | xargs kill -9
```

### Erreur: "Connection refused" entre services

**Solution**: 
1. Vérifier que tous les services sont démarrés
2. Vérifier les URLs dans `application.yml`
3. Vérifier les logs pour les erreurs de connexion

### Erreur: "Unauthorized" sur API Gateway

**Solution**:
1. Vérifier que le JWT est valide
2. Vérifier que le secret JWT est le même dans User Service et Gateway
3. Vérifier le format du header: `Authorization: Bearer TOKEN`

## 📝 Logs

Les logs sont affichés dans la console de chaque service. Niveau DEBUG activé pour:
- `com.skillswap.user`
- `com.skillswap.skill`
- `com.skillswap.gateway`
- `org.springframework.cloud.gateway`

## 🎯 Prochaines Étapes

1. ✅ Services User et Skill fonctionnels
2. ✅ API Gateway configuré
3. ✅ Communication inter-services (Feign)
4. ✅ Collections MongoDB créées automatiquement
5. ⏳ Service Mission
6. ⏳ Service Notification
7. ⏳ Kafka pour événements

## 📞 Support

En cas de problème:
1. Vérifier les logs de chaque service
2. Vérifier la connectivité MongoDB
3. Vérifier que les ports sont disponibles
4. Consulter la documentation de chaque service
