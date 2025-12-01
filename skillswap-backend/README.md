# SkillSwap Backend - Architecture Microservices

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.4-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Maven](https://img.shields.io/badge/Maven-Multi--Module-blue.svg)](https://maven.apache.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-NoSQL-green.svg)](https://www.mongodb.com/)
[![Redis](https://img.shields.io/badge/Redis-Cache-red.svg)](https://redis.io/)

## 📋 Description

Backend de l'application SkillSwap - Une plateforme d'échange de compétences basée sur une architecture microservices.

## 🏗️ Architecture

Ce projet utilise une architecture **microservices** avec 6 modules Maven :

```
skillswap-backend/
├── skillswap-common         # Module partagé (DTOs, enums, events, exceptions)
├── skillswap-api-gateway              # API Gateway (Spring Cloud Gateway)
├── skillswap-service-user             # Gestion des utilisateurs et authentification
├── skillswap-service-skill            # Gestion des compétences
├── skillswap-service-mission          # Gestion des missions et OTP
└── skillswap-service-notification     # Gestion des notifications (FCM, Kafka)
```

## 🚀 Technologies

- **Spring Boot** 3.3.4
- **Maven** (Multi-modules)
- **MongoDB** (Base de données NoSQL)
- **Redis** (Cache et stockage OTP)
- **Kafka** (Messaging événementiel - optionnel)
- **Docker** (Containerisation)
- **JWT** (Authentification)
- **FCM** (Firebase Cloud Messaging)

## 📦 Modules

### 1. skillswap-common
Module partagé contenant les composants communs :
- **enums** : MissionStatus, Role, NotificationType
- **dto** : UserDto, SkillDto
- **events** : MissionEvent
- **exceptions** : ResourceNotFoundException, GlobalExceptionHandler
- **config** : KafkaConfig

### 2. skillswap-api-gateway
Point d'entrée unique pour tous les services :
- Routage des requêtes
- Filtre d'authentification
- Load balancing

### 3. skillswap-service-user
Gestion des utilisateurs :
- Authentification (JWT)
- Inscription / Connexion
- Gestion du profil
- Sécurité Spring Security

### 4. skillswap-service-skill
Gestion des compétences :
- CRUD des compétences
- Recherche et filtrage
- Catégorisation

### 5. skillswap-service-mission
Gestion des missions :
- Création de missions
- Acceptation / Refus
- Système OTP (Redis)
- Publication d'événements (Kafka)

### 6. skillswap-service-notification
Gestion des notifications :
- Notifications push (FCM)
- Consommation d'événements (Kafka)
- Notifications temps réel

## 🛠️ Installation

### Prérequis
- Java 17+
- Maven 3.8+
- MongoDB 6+
- Redis 7+
- Docker & Docker Compose 

### Démarrage rapide

#### 1. Démarrer les dépendances (MongoDB, Redis, Kafka)

```bash
docker-compose up -d
```

#### 2. Compiler le projet

```bash
mvn clean install -DskipTests
```


### Démarrage manuel d'un service

```bash
# Exemple : Démarrer le service User
cd skillswap-service-user
mvn spring-boot:run
```


## 📁 Structure des packages

Chaque service suit cette structure :

```
com.skillswap.{service}/
├── {Service}Application.java      # Point d'entrée Spring Boot
├── model/                          # Entités MongoDB
├── dto/                            # Data Transfer Objects
├── controllers/                    # Contrôleurs REST
├── services/                       # Logique métier
├── repositories/                   # Repositories MongoDB
├── mappers/                        # Mappers (DTOs ↔ Entities)
├── security/                       # Configuration sécurité (si applicable)
└── events/                         # Producteurs/Consommateurs d'événements
```

## 🔧 Configuration

Chaque service a son propre fichier `application.yml` dans `src/main/resources/`.

### Exemple de configuration (service-user)

```yaml
spring:
  application:
    name: service-user
  data:
    mongodb:
      uri: mongodb://localhost:27017/skillswap-users

server:
  port: 8081

jwt:
  secret: your-secret-key
  expiration: 86400000
```


## 🔗 Ports des services

| Service | Port | Description |
|---------|------|-------------|
| api-gateway | 8080 | API Gateway |
| service-user | 8081 | Service utilisateur |
| service-skill | 8082 | Service compétences |
| service-mission | 8083 | Service missions |
| service-notification | 8084 | Service notifications |


## 📊 Endpoints principaux

### API Gateway (8080)

```
GET  /api/users/**          → skillswap-service-user
GET  /api/skills/**         → skillswap-service-skill
GET  /api/missions/**       → skillswap-service-mission
POST /api/notifications/**  → skillswap-service-notification
```

### Service User (8081)

```
POST /auth/register         → Inscription
POST /auth/login            → Connexion
GET  /users/{id}            → Profil utilisateur
PUT  /users/{id}            → Mise à jour profil
```

### Service Skill (8082)

```
GET    /skills              → Liste des compétences
POST   /skills              → Créer une compétence
GET    /skills/{id}         → Détails d'une compétence
PUT    /skills/{id}         → Modifier une compétence
DELETE /skills/{id}         → Supprimer une compétence
```

### Service Mission (8083)

```
GET    /missions            → Liste des missions
POST   /missions            → Créer une mission
GET    /missions/{id}       → Détails d'une mission
POST   /missions/{id}/accept → Accepter une mission
POST   /missions/{id}/otp   → Générer un OTP
POST   /missions/{id}/validate → Valider un OTP
```

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT.

## 👥 Auteurs

- Sohayb El Bakali
- Aymen Ardouni

## 📞 Contact

Pour toute question, contactez l'équipe de développement.

---

**Date de création** : 22 novembre 2025  
**Version** : 1.0.0  
**Status** : ✅ Architecture créée - Prêt pour le développement

