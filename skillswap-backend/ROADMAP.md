# 🗺️ SkillSwap Backend - Roadmap de Développement

## ✅ Étape 1: Service User (TERMINÉ)

### Fonctionnalités implémentées
- ✅ Inscription et connexion avec Firebase Auth
- ✅ Gestion du profil utilisateur
- ✅ Système de crédits
- ✅ Vérification téléphonique avec bonus
- ✅ JWT pour l'authentification
- ✅ MongoDB pour le stockage

### Port: 8081

---

## ✅ Étape 2: Service Skill (TERMINÉ)

### Fonctionnalités implémentées
- ✅ Création de compétences avec géolocalisation
- ✅ Recherche par proximité géographique (MongoDB 2dsphere)
- ✅ Filtrage par catégorie
- ✅ CRUD complet des compétences
- ✅ Validation des permissions (propriétaire uniquement)
- ✅ Calcul de distance avec formule de Haversine
- ✅ Index géospatial automatique

### Technologies clés
- MongoDB avec index 2dsphere
- GeoJSON Point format
- Spring Data MongoDB Geo

### Port: 8082

### Documentation
- README.md
- TESTING_GUIDE.md
- IMPLEMENTATION_NOTES.md
- SUMMARY.md
- Collection Postman

---

## 🚧 Étape 3: Service Mission (EN COURS)

### Objectif
Gérer le cycle de vie complet des missions d'échange de compétences.

### Fonctionnalités à implémenter

#### 3.1 Gestion des missions
- [ ] Créer une mission à partir d'une compétence
- [ ] Accepter/Refuser une mission
- [ ] Annuler une mission
- [ ] Lister les missions (par statut, par utilisateur)
- [ ] Détails d'une mission

#### 3.2 Système OTP
- [ ] Génération de code OTP (6 chiffres)
- [ ] Stockage dans Redis avec expiration (5 min)
- [ ] Validation du code OTP
- [ ] Complétion de la mission après validation

#### 3.3 Statuts de mission
```java
public enum MissionStatus {
    PENDING,      // En attente d'acceptation
    ACCEPTED,     // Acceptée par le helper
    IN_PROGRESS,  // En cours
    COMPLETED,    // Terminée avec succès
    CANCELLED,    // Annulée
    REJECTED      // Refusée
}
```

#### 3.4 Événements Kafka
- [ ] MissionCreatedEvent
- [ ] MissionAcceptedEvent
- [ ] MissionCompletedEvent
- [ ] MissionCancelledEvent

#### 3.5 Gestion des crédits
- [ ] Débiter le demandeur à la création
- [ ] Créditer le helper à la complétion
- [ ] Remboursement en cas d'annulation

### Modèle de données
```java
@Document("missions")
public class Mission {
    @Id
    private UUID missionId;
    
    @Indexed
    private UUID skillId;           // Compétence concernée
    
    @Indexed
    private UUID requesterId;       // Demandeur
    
    @Indexed
    private UUID helperId;          // Helper (null si pas encore accepté)
    
    private String title;
    private String description;
    private MissionStatus status;
    
    private Date scheduledDate;     // Date prévue
    private Integer duration;       // Durée en minutes
    private Integer creditCost;     // Coût en crédits
    
    private Date createdAt;
    private Date acceptedAt;
    private Date completedAt;
    
    private String otpCode;         // Code OTP (stocké aussi dans Redis)
}
```

### API Endpoints
```
POST   /api/missions                    - Créer une mission
GET    /api/missions/{id}               - Détails d'une mission
GET    /api/missions/user/{userId}      - Missions d'un utilisateur
POST   /api/missions/{id}/accept        - Accepter une mission
POST   /api/missions/{id}/reject        - Refuser une mission
POST   /api/missions/{id}/cancel        - Annuler une mission
POST   /api/missions/{id}/generate-otp  - Générer un code OTP
POST   /api/missions/{id}/validate-otp  - Valider le code OTP
```

### Technologies
- MongoDB (missions)
- Redis (OTP temporaires)
- Kafka (événements)
- Spring Data Redis
- Spring Kafka

### Port: 8083

### Dépendances
- Service User (vérification crédits)
- Service Skill (récupération compétence)
- Service Notification (via Kafka)

---

## 📱 Étape 4: Service Notification (À VENIR)

### Objectif
Envoyer des notifications push aux utilisateurs en temps réel.

### Fonctionnalités à implémenter

#### 4.1 Notifications push
- [ ] Intégration Firebase Cloud Messaging (FCM)
- [ ] Envoi de notifications push
- [ ] Gestion des tokens FCM
- [ ] Historique des notifications

#### 4.2 Types de notifications
```java
public enum NotificationType {
    MISSION_CREATED,        // Nouvelle mission disponible
    MISSION_ACCEPTED,       // Mission acceptée
    MISSION_REJECTED,       // Mission refusée
    MISSION_COMPLETED,      // Mission terminée
    MISSION_CANCELLED,      // Mission annulée
    SKILL_NEARBY,           // Nouvelle compétence à proximité
    CREDIT_RECEIVED,        // Crédits reçus
    CREDIT_SPENT            // Crédits dépensés
}
```

#### 4.3 Kafka Consumers
- [ ] Consumer MissionCreatedEvent
- [ ] Consumer MissionAcceptedEvent
- [ ] Consumer MissionCompletedEvent
- [ ] Consumer SkillCreatedEvent

#### 4.4 Préférences utilisateur
- [ ] Activer/Désactiver les notifications
- [ ] Choisir les types de notifications
- [ ] Rayon de notification pour les compétences

### Modèle de données
```java
@Document("notifications")
public class Notification {
    @Id
    private UUID notificationId;
    
    @Indexed
    private UUID userId;            // Destinataire
    
    private NotificationType type;
    private String title;
    private String message;
    private Map<String, Object> data;
    
    private boolean read;
    private Date sentAt;
    private Date readAt;
}
```

### API Endpoints
```
GET    /api/notifications              - Liste des notifications
GET    /api/notifications/unread       - Notifications non lues
POST   /api/notifications/{id}/read    - Marquer comme lu
DELETE /api/notifications/{id}         - Supprimer
POST   /api/notifications/token        - Enregistrer token FCM
```

### Technologies
- Firebase Cloud Messaging (FCM)
- Kafka Consumer
- MongoDB (historique)

### Port: 8084

---

## 🌐 Étape 5: API Gateway (À VENIR)

### Objectif
Point d'entrée unique pour toutes les requêtes clients.

### Fonctionnalités à implémenter

#### 5.1 Routing
- [ ] Route vers service-user (8081)
- [ ] Route vers service-skill (8082)
- [ ] Route vers service-mission (8083)
- [ ] Route vers service-notification (8084)

#### 5.2 Authentification
- [ ] Vérification JWT
- [ ] Extraction userId du token
- [ ] Ajout header X-User-Id
- [ ] Gestion des tokens expirés

#### 5.3 Rate Limiting
- [ ] Limitation par IP
- [ ] Limitation par utilisateur
- [ ] Configuration par endpoint

#### 5.4 CORS
- [ ] Configuration CORS pour mobile/web
- [ ] Whitelist des origines

#### 5.5 Monitoring
- [ ] Logs des requêtes
- [ ] Métriques (temps de réponse, erreurs)
- [ ] Health checks des services

### Configuration
```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: user-service
          uri: http://localhost:8081
          predicates:
            - Path=/api/users/**, /api/auth/**
        
        - id: skill-service
          uri: http://localhost:8082
          predicates:
            - Path=/api/skills/**
        
        - id: mission-service
          uri: http://localhost:8083
          predicates:
            - Path=/api/missions/**
        
        - id: notification-service
          uri: http://localhost:8084
          predicates:
            - Path=/api/notifications/**
```

### Technologies
- Spring Cloud Gateway
- JWT validation
- Redis (rate limiting)

### Port: 8080

---

## 🔄 Étape 6: Intégration et Communication

### 6.1 Communication REST
- [ ] Service Mission → Service User (vérifier crédits)
- [ ] Service Mission → Service Skill (récupérer compétence)
- [ ] Service Skill → Service User (enrichir réponses)

### 6.2 Événements Kafka
- [ ] Configuration Kafka
- [ ] Topics:
  - `mission-events`
  - `skill-events`
  - `user-events`
  - `notification-events`

### 6.3 Feign Clients
```java
@FeignClient(name = "service-user", url = "http://localhost:8081")
public interface UserClient {
    @GetMapping("/api/users/{userId}")
    UserDto getUserById(@PathVariable UUID userId);
    
    @PostMapping("/api/users/{userId}/credits/debit")
    void debitCredits(@PathVariable UUID userId, @RequestParam Integer amount);
}
```

---

## 🐳 Étape 7: Containerisation et Déploiement

### 7.1 Docker
- [x] Dockerfile pour service-user
- [x] Dockerfile pour service-skill
- [ ] Dockerfile pour service-mission
- [ ] Dockerfile pour service-notification
- [ ] Dockerfile pour api-gateway

### 7.2 Docker Compose
- [x] MongoDB
- [x] Redis
- [x] Kafka + Zookeeper
- [ ] Tous les services
- [ ] Mongo Express (UI)

### 7.3 Kubernetes (Optionnel)
- [ ] Deployments
- [ ] Services
- [ ] ConfigMaps
- [ ] Secrets
- [ ] Ingress

---

## 📊 Étape 8: Monitoring et Observabilité

### 8.1 Logs
- [ ] Centralization avec ELK Stack
- [ ] Structured logging (JSON)
- [ ] Correlation IDs

### 8.2 Métriques
- [ ] Prometheus
- [ ] Grafana dashboards
- [ ] Alerting

### 8.3 Tracing
- [ ] Distributed tracing (Zipkin/Jaeger)
- [ ] Request tracing entre services

---

## 🧪 Étape 9: Tests

### 9.1 Tests unitaires
- [x] Service User
- [x] Service Skill
- [ ] Service Mission
- [ ] Service Notification

### 9.2 Tests d'intégration
- [ ] Tests avec MongoDB
- [ ] Tests avec Redis
- [ ] Tests avec Kafka

### 9.3 Tests end-to-end
- [ ] Scénarios complets
- [ ] Tests de charge
- [ ] Tests de sécurité

---

## 🚀 Étape 10: Production

### 10.1 Sécurité
- [ ] HTTPS
- [ ] Secrets management
- [ ] Rate limiting
- [ ] Input validation
- [ ] SQL/NoSQL injection prevention

### 10.2 Performance
- [ ] Caching (Redis)
- [ ] Database indexing
- [ ] Connection pooling
- [ ] Async processing

### 10.3 Scalabilité
- [ ] Horizontal scaling
- [ ] Load balancing
- [ ] Database sharding
- [ ] CDN pour assets

### 10.4 Backup et Recovery
- [ ] MongoDB backup
- [ ] Redis persistence
- [ ] Disaster recovery plan

---

## 📅 Timeline Estimée

| Étape | Durée estimée | Status |
|-------|---------------|--------|
| Service User | 2 semaines | ✅ Terminé |
| Service Skill | 1 semaine | ✅ Terminé |
| Service Mission | 2 semaines | 🚧 En cours |
| Service Notification | 1 semaine | ⏳ À venir |
| API Gateway | 1 semaine | ⏳ À venir |
| Intégration | 1 semaine | ⏳ À venir |
| Tests | 1 semaine | ⏳ À venir |
| Déploiement | 1 semaine | ⏳ À venir |

**Total estimé**: 10 semaines

---

## 🎯 Priorités Immédiates

1. **Service Mission** (Critique)
   - Implémente la logique métier principale
   - Nécessaire pour le MVP

2. **API Gateway** (Important)
   - Point d'entrée unique
   - Authentification centralisée

3. **Service Notification** (Important)
   - Améliore l'expérience utilisateur
   - Engagement temps réel

4. **Tests et Documentation** (Important)
   - Qualité du code
   - Maintenabilité

---

## 📝 Notes

- Chaque service doit être indépendant et déployable séparément
- Utiliser des événements Kafka pour la communication asynchrone
- Privilégier REST pour la communication synchrone
- Documenter chaque service avec README, TESTING_GUIDE, etc.
- Créer des collections Postman pour chaque service
- Suivre les conventions de code établies

---

**Version**: 1.0.0  
**Dernière mise à jour**: 22 Janvier 2026  
**Prochaine étape**: Service Mission
