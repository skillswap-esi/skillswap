# Guide de test - Service User

## 🧪 Tests manuels avec curl

### Prérequis

1. MongoDB en cours d'exécution sur `localhost:27017`
2. Service User démarré sur le port `8081`

```bash
# Démarrer MongoDB
docker run -d -p 27017:27017 --name mongodb mongo:latest

# Démarrer le service
cd skillswap-service-user
mvn spring-boot:run
```

### Scénario de test complet

#### 1. Créer un profil utilisateur

```bash
curl -X POST http://localhost:8081/users/profile \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "phoneNumber": "+33612345678",
    "fullName": "Alice Dupont",
    "idToken": "test-firebase-token"
  }'
```

**Réponse attendue (201 Created):**
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "email": "alice@example.com",
  "phoneNumber": "+33612345678",
  "fullName": "Alice Dupont",
  "phoneVerified": false,
  "creditsBalance": 0,
  "helperScore": 0.0,
  "avatar": null,
  "roles": ["USER"],
  "fcmTokens": [],
  "createdAt": "2024-12-01T10:00:00.000+00:00",
  "updatedAt": "2024-12-01T10:00:00.000+00:00"
}
```

**Sauvegarder le userId pour les tests suivants !**

#### 2. Récupérer le profil

```bash
# Remplacer {userId} par l'UUID reçu
curl "http://localhost:8081/users/me?userId={userId}"
```

#### 3. Mettre à jour le profil

```bash
curl -X PUT "http://localhost:8081/users/me?userId={userId}" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Alice Martin",
    "avatar": "https://example.com/avatar.jpg"
  }'
```

#### 4. Vérifier le téléphone (bonus de 50 crédits)

```bash
curl -X POST "http://localhost:8081/users/{userId}/verify-phone"
```

**Réponse attendue:**
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "email": "alice@example.com",
  "phoneNumber": "+33612345678",
  "fullName": "Alice Martin",
  "phoneVerified": true,
  "creditsBalance": 50,
  "helperScore": 0.0,
  "avatar": "https://example.com/avatar.jpg",
  "roles": ["USER"],
  "fcmTokens": [],
  "createdAt": "2024-12-01T10:00:00.000+00:00",
  "updatedAt": "2024-12-01T10:05:00.000+00:00"
}
```

**Vérifier:** `phoneVerified = true` et `creditsBalance = 50`

#### 5. Enregistrer un token FCM

```bash
curl -X POST "http://localhost:8081/users/fcm-tokens?userId={userId}" \
  -H "Content-Type: application/json" \
  -d '{
    "fcmToken": "firebase-fcm-token-123456"
  }'
```

#### 6. Voir l'historique des transactions

```bash
curl "http://localhost:8081/users/ledger?userId={userId}&limit=50"
```

**Réponse attendue:**
```json
[
  {
    "transactionId": "660e8400-e29b-41d4-a716-446655440001",
    "fromUserId": null,
    "toUserId": "550e8400-e29b-41d4-a716-446655440000",
    "amount": 50,
    "missionId": null,
    "timestamp": "2024-12-01T10:05:00.000+00:00",
    "description": "Phone verification bonus"
  }
]
```

#### 7. Créer un deuxième utilisateur

```bash
curl -X POST http://localhost:8081/users/profile \
  -H "Content-Type: application/json" \
  -d '{
    "email": "bob@example.com",
    "phoneNumber": "+33698765432",
    "fullName": "Bob Martin",
    "idToken": "test-firebase-token-2"
  }'
```

**Sauvegarder le userId de Bob !**

#### 8. Ajouter des crédits à Bob

```bash
curl -X POST "http://localhost:8081/users/{bobUserId}/credits/add?amount=100&description=Initial+bonus"
```

#### 9. Transférer des crédits d'Alice à Bob

```bash
curl -X POST "http://localhost:8081/users/credits/transfer" \
  -d "fromUserId={aliceUserId}" \
  -d "toUserId={bobUserId}" \
  -d "amount=20"
```

#### 10. Vérifier les soldes

```bash
# Alice devrait avoir 30 crédits (50 - 20)
curl "http://localhost:8081/users/me?userId={aliceUserId}"

# Bob devrait avoir 120 crédits (100 + 20)
curl "http://localhost:8081/users/me?userId={bobUserId}"
```

#### 11. Voir les transactions d'Alice

```bash
curl "http://localhost:8081/users/ledger?userId={aliceUserId}&limit=50"
```

**Réponse attendue:**
```json
[
  {
    "transactionId": "...",
    "fromUserId": "{aliceUserId}",
    "toUserId": "{bobUserId}",
    "amount": 20,
    "missionId": null,
    "timestamp": "2024-12-01T10:10:00.000+00:00",
    "description": "Mission payment"
  },
  {
    "transactionId": "...",
    "fromUserId": null,
    "toUserId": "{aliceUserId}",
    "amount": 50,
    "missionId": null,
    "timestamp": "2024-12-01T10:05:00.000+00:00",
    "description": "Phone verification bonus"
  }
]
```

### Tests d'erreur

#### 1. Email déjà existant

```bash
curl -X POST http://localhost:8081/users/profile \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "phoneNumber": "+33611111111",
    "fullName": "Alice Clone",
    "idToken": "test-token"
  }'
```

**Réponse attendue (409 Conflict):**
```json
{
  "error": "Email already exists: alice@example.com"
}
```

#### 2. Téléphone déjà existant

```bash
curl -X POST http://localhost:8081/users/profile \
  -H "Content-Type: application/json" \
  -d '{
    "email": "charlie@example.com",
    "phoneNumber": "+33612345678",
    "fullName": "Charlie",
    "idToken": "test-token"
  }'
```

**Réponse attendue (409 Conflict):**
```json
{
  "error": "Phone number already exists: +33612345678"
}
```

#### 3. Utilisateur introuvable

```bash
curl "http://localhost:8081/users/me?userId=00000000-0000-0000-0000-000000000000"
```

**Réponse attendue (404 Not Found):**
```json
{
  "error": "User not found: 00000000-0000-0000-0000-000000000000"
}
```

#### 4. Crédits insuffisants

```bash
# Essayer de transférer plus que le solde d'Alice
curl -X POST "http://localhost:8081/users/credits/transfer" \
  -d "fromUserId={aliceUserId}" \
  -d "toUserId={bobUserId}" \
  -d "amount=1000"
```

**Réponse attendue (400 Bad Request):**
```json
{
  "error": "Insufficient credits"
}
```

#### 5. Validation des champs

```bash
curl -X POST http://localhost:8081/users/profile \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invalid-email",
    "fullName": "",
    "idToken": ""
  }'
```

**Réponse attendue (400 Bad Request):**
```json
{
  "email": "Email must be valid",
  "fullName": "Full name is required",
  "idToken": "Firebase ID token is required"
}
```

## 🧪 Tests avec Postman

### Collection Postman

Créer une collection avec les variables:
- `baseUrl`: `http://localhost:8081`
- `aliceUserId`: (à remplir après création)
- `bobUserId`: (à remplir après création)

### Requêtes

1. **Create Alice Profile**
   - Method: POST
   - URL: `{{baseUrl}}/users/profile`
   - Body: JSON (voir exemple ci-dessus)
   - Test script:
   ```javascript
   pm.test("Status is 201", function() {
       pm.response.to.have.status(201);
   });
   pm.test("User created", function() {
       var json = pm.response.json();
       pm.expect(json.email).to.eql("alice@example.com");
       pm.expect(json.creditsBalance).to.eql(0);
       pm.collectionVariables.set("aliceUserId", json.userId);
   });
   ```

2. **Get Alice Profile**
   - Method: GET
   - URL: `{{baseUrl}}/users/me?userId={{aliceUserId}}`

3. **Verify Phone**
   - Method: POST
   - URL: `{{baseUrl}}/users/{{aliceUserId}}/verify-phone`
   - Test script:
   ```javascript
   pm.test("Phone verified", function() {
       var json = pm.response.json();
       pm.expect(json.phoneVerified).to.be.true;
       pm.expect(json.creditsBalance).to.eql(50);
   });
   ```

## 🐳 Tests avec Docker Compose

### docker-compose.test.yml

```yaml
version: '3.8'

services:
  mongodb:
    image: mongo:latest
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_DATABASE: skillswap-users

  service-user:
    build: ./skillswap-service-user
    ports:
      - "8081:8081"
    environment:
      MONGODB_URI: mongodb://mongodb:27017/skillswap-users
    depends_on:
      - mongodb
```

### Lancer les tests

```bash
docker-compose -f docker-compose.test.yml up -d
# Attendre que les services démarrent
sleep 10
# Lancer les tests curl
./run-tests.sh
```

## 📊 Vérification dans MongoDB

### Se connecter à MongoDB

```bash
docker exec -it mongodb mongosh
```


## 🔍 Debugging

### Logs du service

```bash
# Voir les logs en temps réel
tail -f logs/spring.log

# Ou avec Docker
docker logs -f skillswap-service-user
```

### Niveaux de log

Dans `application.yml`:
```yaml
logging:
  level:
    com.skillswap.user: DEBUG
    org.springframework.data.mongodb: DEBUG
```

## ✅ Checklist de test

- [ ] Créer un utilisateur avec email et téléphone
- [ ] Vérifier l'unicité de l'email
- [ ] Vérifier l'unicité du téléphone
- [ ] Récupérer un profil utilisateur
- [ ] Mettre à jour un profil
- [ ] Vérifier le téléphone et recevoir le bonus
- [ ] Enregistrer un token FCM
- [ ] Voir l'historique des transactions
- [ ] Ajouter des crédits
- [ ] Déduire des crédits
- [ ] Transférer des crédits entre utilisateurs
- [ ] Tester les erreurs (utilisateur introuvable, crédits insuffisants, etc.)
- [ ] Vérifier la validation des champs
- [ ] Vérifier les indexes MongoDB
- [ ] Tester la performance avec plusieurs utilisateurs

## 🚀 Tests de charge (optionnel)

### Avec Apache Bench

```bash
# Créer 100 utilisateurs
ab -n 100 -c 10 -p user.json -T application/json \
  http://localhost:8081/users/profile
```

### Avec k6

```javascript
import http from 'k6/http';
import { check } from 'k6';

export default function() {
  const payload = JSON.stringify({
    email: `user${__VU}@example.com`,
    phoneNumber: `+3361234${__VU}`,
    fullName: `User ${__VU}`,
    idToken: 'test-token'
  });

  const res = http.post('http://localhost:8081/users/profile', payload, {
    headers: { 'Content-Type': 'application/json' },
  });

  check(res, {
    'status is 201': (r) => r.status === 201,
  });
}
```

## 📝 Rapport de test

Après avoir exécuté tous les tests, vérifier:

1. ✅ Tous les endpoints répondent correctement
2. ✅ Les erreurs sont gérées proprement
3. ✅ Les transactions sont enregistrées dans le ledger
4. ✅ Les crédits sont correctement calculés
5. ✅ Les indexes MongoDB fonctionnent
6. ✅ Les logs sont clairs et informatifs
7. ✅ Les validations fonctionnent
8. ✅ Les tokens FCM sont enregistrés

## 🎯 Prochaines étapes

Une fois les tests manuels validés:
1. Créer des tests unitaires avec JUnit
2. Créer des tests d'intégration avec @SpringBootTest
3. Ajouter des tests de contrat avec Spring Cloud Contract
4. Mettre en place l'intégration continue (CI/CD)
