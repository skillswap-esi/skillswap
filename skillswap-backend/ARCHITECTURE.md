# Architecture SkillSwap - Guide Simple

## 🎯 Vue d'ensemble

SkillSwap est une plateforme d'échange de compétences construite avec une **architecture microservices**. Chaque service est indépendant et communique avec les autres via des APIs REST et des événements.

## 📐 Schéma de l'architecture

```
                    ┌─────────────────┐
                    │   Client App    │
                    │  (Mobile/Web)   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  API Gateway    │
                    │   Port: 8080    │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼─────┐      ┌──────▼──────┐      ┌─────▼──────┐
   │  User    │      │   Skill     │      │  Mission   │
   │ Service  │      │  Service    │      │  Service   │
   │ :8081    │      │   :8082     │      │   :8083    │
   └────┬─────┘      └──────┬──────┘      └─────┬──────┘
        │                   │                    │
        │                   │              ┌─────▼──────┐
        │                   │              │Notification│
        │                   │              │  Service   │
        │                   │              │   :8084    │
        │                   │              └─────┬──────┘
        │                   │                    │
   ┌────▼───────────────────▼────────────────────▼─────┐
   │              Kafka (Événements)                    │
   └────────────────────────────────────────────────────┘
        │                   │                    │
   ┌────▼─────┐      ┌──────▼──────┐      ┌─────▼──────┐
   │ MongoDB  │      │   MongoDB   │      │   Redis    │
   │  Users   │      │Skills/Missions     │   (OTP)    │
   └──────────┘      └─────────────┘      └────────────┘
```

## 🧩 Les 6 modules du projet

### 1. **skillswap-common** 
Module partagé par tous les services.

**Contenu :**
- DTOs (UserDto, SkillDto, etc.)
- Enums (MissionStatus, Role, NotificationType)
- Events (MissionEvent)
- Exceptions communes
- Configuration Kafka

**Pourquoi ?** Éviter la duplication de code entre services.

---

### 2. **api-gateway** (Port 8080)
Point d'entrée unique de l'application.

**Rôle :**
- Recevoir toutes les requêtes clients
- Router vers le bon service
- Vérifier l'authentification JWT
- Load balancing

**Exemple :**
```
Client → GET /api/users/123 → Gateway → Service User
```

---

### 3. **service-user** (Port 8081)
Gestion des utilisateurs et authentification.

**Fonctionnalités :**
- Inscription / Connexion
- Génération de tokens JWT
- Gestion du profil utilisateur
- Sécurité Spring Security

**Base de données :** MongoDB (collection `users`)

---

### 4. **service-skill** (Port 8082)
Gestion des compétences.

**Fonctionnalités :**
- Créer, lire, modifier, supprimer des compétences
- Rechercher des compétences
- Catégoriser les compétences

**Base de données :** MongoDB (collection `skills`)

---

### 5. **service-mission** (Port 8083)
Gestion des missions et système OTP.

**Fonctionnalités :**
- Créer des missions
- Accepter/Refuser des missions
- Générer des codes OTP (stockés dans Redis)
- Valider les OTP pour compléter une mission
- Publier des événements Kafka (mission créée, acceptée, complétée)

**Bases de données :**
- MongoDB (collection `missions`)
- Redis (stockage temporaire des OTP)

---

### 6. **service-notification** (Port 8084)
Gestion des notifications push.

**Fonctionnalités :**
- Envoyer des notifications via Firebase Cloud Messaging (FCM)
- Écouter les événements Kafka
- Notifier les utilisateurs en temps réel

**Base de données :** MongoDB (collection `notifications`)

---

## 🔄 Communication entre services

### 1. **Communication synchrone (REST)**
Les services communiquent via des appels HTTP REST.

**Exemple :**
```
Service Mission → GET http://service-user:8081/users/123
```

### 2. **Communication asynchrone (Kafka)**
Les services publient et consomment des événements.

**Exemple :**
```
Service Mission → Publie "MissionCreatedEvent" → Kafka
                                                    ↓
                                    Service Notification → Consomme l'événement
                                                    ↓
                                    Envoie une notification push
```

---

## 💾 Bases de données

| Service | Base de données | Collection/Clé |
|---------|----------------|----------------|
| User | MongoDB | `users` |
| Skill | MongoDB | `skills` |
| Mission | MongoDB + Redis | `missions` + OTP keys |
| Notification | MongoDB | `notifications` |

**Pourquoi MongoDB ?** Base NoSQL flexible, idéale pour des données non relationnelles.

**Pourquoi Redis ?** Cache ultra-rapide pour les OTP temporaires (expiration automatique).

---

## 🔐 Sécurité

### JWT (JSON Web Token)
1. L'utilisateur se connecte via `service-user`
2. Le service génère un token JWT
3. Le client envoie ce token dans chaque requête
4. L'API Gateway vérifie le token avant de router

**Flux :**
```
Client → POST /auth/login → Service User → Retourne JWT
Client → GET /api/missions (+ JWT) → Gateway vérifie JWT → Service Mission
```

---

## 🚀 Démarrage du projet

### Option 1 : Avec Docker Compose (recommandé)
```bash
docker-compose up
```

### Option 2 : Manuellement
```bash
# 1. Démarrer MongoDB et Redis
# 2. Compiler le projet
mvn clean install

# 3. Démarrer chaque service
cd skillswap-api-gateway
mvn spring-boot:run

cd ../skillswap-service-user
mvn spring-boot:run

# ... répéter pour chaque service
```

---

## 📊 Exemple de flux complet

### Scénario : Créer et accepter une mission

1. **Utilisateur A crée une mission**
   ```
   Client → POST /api/missions → Gateway → Service Mission
   ```
   - Mission sauvegardée dans MongoDB
   - Événement `MissionCreatedEvent` publié sur Kafka

2. **Service Notification reçoit l'événement**
   - Consomme `MissionCreatedEvent`
   - Envoie une notification push aux utilisateurs concernés

3. **Utilisateur B accepte la mission**
   ```
   Client → POST /api/missions/123/accept → Gateway → Service Mission
   ```
   - Statut de la mission mis à jour
   - Événement `MissionAcceptedEvent` publié

4. **Génération d'un OTP**
   ```
   Client → POST /api/missions/123/otp → Service Mission
   ```
   - Code OTP généré et stocké dans Redis (expire après 5 min)

5. **Validation de l'OTP**
   ```
   Client → POST /api/missions/123/validate → Service Mission
   ```
   - OTP vérifié dans Redis
   - Mission marquée comme complétée
   - Événement `MissionCompletedEvent` publié

---

## 🛠️ Technologies utilisées

- **Spring Boot 3.3.4** : Framework Java
- **Maven** : Gestion des dépendances
- **MongoDB** : Base de données NoSQL
- **Redis** : Cache et stockage temporaire
- **Kafka** : Messaging événementiel
- **JWT** : Authentification
- **FCM** : Notifications push
- **Docker** : Containerisation

---

## 📁 Structure d'un service type

```
service-user/
├── src/main/java/com/skillswap/user/
│   ├── UserApplication.java          # Point d'entrée
│   ├── model/
│   │   └── User.java                 # Entité MongoDB
│   ├── dto/
│   │   └── UserDto.java              # Data Transfer Object
│   ├── controller/
│   │   └── UserController.java       # API REST
│   ├── service/
│   │   └── UserService.java          # Logique métier
│   ├── repository/
│   │   └── UserRepository.java       # Accès MongoDB
│   └── security/
│       └── JwtUtil.java              # Gestion JWT
└── src/main/resources/
    └── application.yml                # Configuration
```

---

## ✅ Avantages de cette architecture

1. **Scalabilité** : Chaque service peut être déployé et scalé indépendamment
2. **Maintenabilité** : Code organisé et séparé par domaine métier
3. **Résilience** : Si un service tombe, les autres continuent de fonctionner
4. **Flexibilité** : Possibilité d'utiliser différentes technologies par service
5. **Développement parallèle** : Plusieurs équipes peuvent travailler simultanément

---

## 📞 Questions fréquentes

**Q : Pourquoi ne pas tout mettre dans un seul service ?**
R : Un monolithe devient difficile à maintenir et à scaler. Les microservices permettent plus de flexibilité.

**Q : Comment les services se trouvent-ils ?**
R : Via l'API Gateway qui connaît les URLs de chaque service.

**Q : Que se passe-t-il si Kafka est down ?**
R : Les notifications ne seront pas envoyées, mais les services principaux continuent de fonctionner.

**Q : Pourquoi Redis pour les OTP ?**
R : Redis permet une expiration automatique des clés, parfait pour des codes temporaires.

---

**Version** : 1.0.0  
**Dernière mise à jour** : 1 Décembre 2024
