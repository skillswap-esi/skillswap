# Notes d'implémentation - Service User

## ✅ Ce qui a été implémenté

### 1. Modèles de données

- **User** : Entité principale avec tous les champs requis
  - userId, email, phoneNumber, fullName
  - phoneVerified, creditsBalance, helperScore
  - roles, fcmTokens
  - Indexes uniques sur email et phoneNumber

- **LedgerTransaction** : Historique des transactions de crédits
  - transactionId, fromUserId, toUserId
  - amount, missionId, timestamp, description

### 2. DTOs (Data Transfer Objects)

- `UserDto` : Représentation publique d'un utilisateur
- `CreateProfileRequest` : Requête de création de profil
- `UpdateProfileRequest` : Requête de mise à jour de profil
- `FcmTokenRequest` : Requête d'enregistrement de token FCM
- `LedgerTransactionDto` : Représentation d'une transaction

### 3. Repositories

- `UserRepository` : Accès aux données utilisateurs
  - findByEmail, findByPhoneNumber
  - existsByEmail, existsByPhoneNumber

- `LedgerTransactionRepository` : Accès aux transactions
  - findByFromUserIdOrToUserIdOrderByTimestampDesc

### 4. Services

- **UserService** : Logique métier principale
  - `createProfile()` : Création de profil avec vérification Firebase
  - `getUserById()`, `getUserByEmail()` : Récupération d'utilisateurs
  - `updateProfile()` : Mise à jour du profil
  - `verifyPhone()` : Vérification téléphone + bonus de 50 crédits
  - `getLedgerTransactions()` : Historique des transactions
  - `addCredits()`, `deductCredits()` : Gestion des crédits
  - `transferCredits()` : Transfert entre utilisateurs
  - `saveFcmToken()` : Enregistrement des tokens FCM

- **FirebaseAuthService** : Vérification des tokens Firebase
  - `verifyIdToken()` : Vérifie un token Firebase (simplifié pour dev)

### 5. Controllers

- **UserController** : Endpoints REST
  - `GET /users/me` : Profil de l'utilisateur connecté
  - `POST /users/profile` : Création de profil
  - `PUT /users/me` : Mise à jour du profil
  - `POST /users/fcm-tokens` : Enregistrement token FCM
  - `GET /users/ledger` : Historique des transactions
  - `POST /users/{userId}/verify-phone` : Vérification téléphone
  - Endpoints internes pour les autres services

### 6. Gestion des erreurs

- `UserAlreadyExistsException` : Email ou téléphone déjà utilisé
- `UserNotFoundException` : Utilisateur introuvable
- `InvalidTokenException` : Token Firebase invalide
- `GlobalExceptionHandler` : Gestion centralisée des erreurs

### 7. Mappers

- `UserMapper` : Conversion entre entités et DTOs

### 8. Événements

- `PhoneVerifiedEvent` : Événement Kafka (structure prête)

## 🔄 Scénario implémenté

### Flux d'inscription complet

```
1. Utilisateur s'inscrit via Firebase Auth
   ↓
2. Firebase retourne idToken (JWT)
   ↓
3. App appelle POST /users/profile avec idToken
   ↓
4. Service vérifie le token Firebase
   ↓
5. Service vérifie unicité email/téléphone
   ↓
6. Service crée l'utilisateur (0 crédits, phoneVerified=false)
   ↓
7. Utilisateur vérifie son téléphone
   ↓
8. App appelle POST /users/{userId}/verify-phone
   ↓
9. Service marque phoneVerified=true
   ↓
10. Service ajoute 50 crédits de bonus
    ↓
11. Service crée une transaction dans le ledger
    ↓
12. Service publie événement PHONE_VERIFIED (TODO Kafka)
    ↓
13. Service Notification reçoit l'événement (futur)
```

## 🚧 Ce qui reste à faire

### 1. Intégration Firebase complète

**Fichier:** `FirebaseAuthService.java`

**Actions:**
1. Ajouter la dépendance Firebase Admin SDK dans `pom.xml`:
```xml
<dependency>
    <groupId>com.google.firebase</groupId>
    <artifactId>firebase-admin</artifactId>
    <version>9.2.0</version>
</dependency>
```

2. Télécharger le fichier `serviceAccountKey.json` depuis Firebase Console

3. Initialiser Firebase:
```java
@PostConstruct
public void initialize() {
    try {
        FileInputStream serviceAccount = new FileInputStream(
            "src/main/resources/serviceAccountKey.json"
        );
        
        FirebaseOptions options = FirebaseOptions.builder()
            .setCredentials(GoogleCredentials.fromStream(serviceAccount))
            .build();
        
        FirebaseApp.initializeApp(options);
    } catch (IOException e) {
        log.error("Failed to initialize Firebase", e);
    }
}
```

4. Implémenter la vérification réelle:
```java
public String verifyIdToken(String idToken) {
    try {
        FirebaseToken decodedToken = FirebaseAuth.getInstance()
            .verifyIdToken(idToken);
        return decodedToken.getUid();
    } catch (FirebaseAuthException e) {
        log.error("Error verifying token", e);
        return null;
    }
}
```

### 2. Intégration Kafka

**Fichier:** `UserService.java` (méthode `verifyPhone`)

**Actions:**
1. Ajouter la dépendance Kafka dans `pom.xml`:
```xml
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
```

2. Configurer Kafka dans `application.yml`:
```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
```

3. Injecter KafkaTemplate dans UserService:
```java
private final KafkaTemplate<String, PhoneVerifiedEvent> kafkaTemplate;
```

4. Publier l'événement:
```java
PhoneVerifiedEvent event = new PhoneVerifiedEvent(
    userId,
    updatedUser.getEmail(),
    updatedUser.getPhoneNumber(),
    PHONE_VERIFICATION_BONUS,
    new Date()
);
kafkaTemplate.send("phone-verified-events", event);
```

### 3. Spring Security avec JWT

**Objectif:** Extraire automatiquement l'userId du token JWT au lieu de le passer en paramètre

**Actions:**
1. Créer `JwtAuthenticationFilter`
2. Créer `SecurityConfig`
3. Modifier les endpoints pour utiliser `@AuthenticationPrincipal`

**Exemple:**
```java
@GetMapping("/me")
public ResponseEntity<UserDto> getCurrentUser(
    @AuthenticationPrincipal UserDetails userDetails
) {
    UUID userId = UUID.fromString(userDetails.getUsername());
    UserDto user = userService.getUserById(userId);
    return ResponseEntity.ok(user);
}
```

### 4. Tests

**Créer:**
- `UserServiceTest.java` : Tests unitaires du service
- `UserControllerTest.java` : Tests d'intégration des endpoints
- `UserRepositoryTest.java` : Tests du repository

**Exemple de test:**
```java
@Test
void createProfile_shouldCreateUser() {
    CreateProfileRequest request = new CreateProfileRequest();
    request.setEmail("test@example.com");
    request.setFullName("Test User");
    request.setIdToken("valid-token");
    
    UserDto user = userService.createProfile(request);
    
    assertNotNull(user.getUserId());
    assertEquals("test@example.com", user.getEmail());
    assertEquals(0, user.getCreditsBalance());
    assertFalse(user.isPhoneVerified());
}
```

### 5. Validation avancée

**Ajouter dans les DTOs:**
```java
@Pattern(regexp = "^\\+[1-9]\\d{1,14}$", message = "Invalid phone number format")
private String phoneNumber;

@Size(min = 2, max = 100, message = "Full name must be between 2 and 100 characters")
private String fullName;
```

### 6. Pagination

**Pour l'endpoint `/users/ledger`:**
```java
@GetMapping("/ledger")
public ResponseEntity<Page<LedgerTransactionDto>> getLedgerTransactions(
    @RequestParam UUID userId,
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "50") int size
) {
    // ...
}
```

## 📋 Checklist de déploiement

- [ ] Configurer Firebase Admin SDK
- [ ] Ajouter les credentials Firebase
- [ ] Configurer Kafka
- [ ] Implémenter Spring Security
- [ ] Ajouter les tests
- [ ] Configurer les variables d'environnement
- [ ] Créer les indexes MongoDB
- [ ] Configurer le monitoring
- [ ] Documenter les APIs (Swagger/OpenAPI)
- [ ] Configurer les logs
- [ ] Mettre en place le rate limiting
- [ ] Configurer CORS

## 🧪 Comment tester maintenant

### 1. Démarrer MongoDB

```bash
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

### 2. Démarrer le service

```bash
cd skillswap-service-user
mvn spring-boot:run
```

### 3. Tester avec curl

**Créer un profil:**
```bash
curl -X POST http://localhost:8081/users/profile \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "phoneNumber": "+33612345678",
    "fullName": "John Doe",
    "idToken": "test-token"
  }'
```

**Récupérer le profil:**
```bash
curl "http://localhost:8081/users/me?userId=<userId-from-previous-response>"
```

**Vérifier le téléphone:**
```bash
curl -X POST "http://localhost:8081/users/<userId>/verify-phone"
```

**Voir les transactions:**
```bash
curl "http://localhost:8081/users/ledger?userId=<userId>&limit=50"
```

## 📊 Structure finale

```
skillswap-service-user/
├── src/main/java/com/skillswap/user/
│   ├── UserServiceApplication.java
│   ├── controllers/
│   │   └── UserController.java          ✅
│   ├── dto/
│   │   ├── UserDto.java                 ✅
│   │   ├── CreateProfileRequest.java    ✅
│   │   ├── UpdateProfileRequest.java    ✅
│   │   ├── FcmTokenRequest.java         ✅
│   │   └── LedgerTransactionDto.java    ✅
│   ├── events/
│   │   └── PhoneVerifiedEvent.java      ✅
│   ├── exceptions/
│   │   ├── UserAlreadyExistsException.java    ✅
│   │   ├── UserNotFoundException.java         ✅
│   │   ├── InvalidTokenException.java         ✅
│   │   └── GlobalExceptionHandler.java        ✅
│   ├── mappers/
│   │   └── UserMapper.java              ✅
│   ├── model/
│   │   ├── User.java                    ✅
│   │   └── LedgerTransaction.java       ✅
│   ├── repositories/
│   │   ├── UserRepository.java          ✅
│   │   └── LedgerTransactionRepository.java   ✅
│   ├── security/                        🚧 TODO
│   └── services/
│       ├── UserService.java             ✅
│       └── FirebaseAuthService.java     ✅ (simplifié)
├── src/main/resources/
│   └── application.yml                  ✅
├── pom.xml                              ✅
└── README.md                            ✅
```

## 🎯 Prochaines étapes recommandées

1. **Tester le service localement** avec MongoDB
2. **Implémenter Firebase Auth** pour la production
3. **Ajouter Kafka** pour les événements
4. **Implémenter Spring Security** pour sécuriser les endpoints
5. **Créer les tests** unitaires et d'intégration
6. **Intégrer avec l'API Gateway**
7. **Déployer avec Docker Compose**

## 💡 Conseils

- Commencez par tester les endpoints de base sans Firebase
- Utilisez Postman ou curl pour tester les APIs
- Vérifiez les logs pour déboguer
- Consultez le README.md pour les exemples d'utilisation
- L'architecture est prête pour évoluer facilement
