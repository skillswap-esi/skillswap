# SkillSwap Skill Service

Service de gestion des compétences avec géolocalisation.

## 🎯 Fonctionnalités

- Création de compétences avec géolocalisation (GeoJSON)
- Recherche de compétences par proximité géographique
- Filtrage par catégorie
- Gestion CRUD complète des compétences
- Index géospatial MongoDB 2dsphere

## 🚀 Démarrage

### Prérequis
- Java 17+
- Maven 3.6+
- MongoDB (avec support géospatial)

### Configuration

Créer un fichier `.env` basé sur `.env.example`:
```bash
MONGODB_URI=mongodb://localhost:27017/skillswap-skills
```

### Lancer le service

```bash
mvn spring-boot:run
```

Le service démarre sur le port **8082**.

## 📡 API Endpoints

### Créer une compétence
```http
POST /api/skills
Headers: X-User-Id: <UUID>
Body:
{
  "title": "Cours de guitare",
  "description": "Cours de guitare pour débutants",
  "category": "MUSIQUE",
  "latitude": 48.8566,
  "longitude": 2.3522
}
```

### Rechercher des compétences à proximité
```http
GET /api/skills/near?lat=48.8566&lng=2.3522&radius=10&category=MUSIQUE
```

### Obtenir les compétences d'un utilisateur
```http
GET /api/skills/user/{userId}
```

### Obtenir une compétence par ID
```http
GET /api/skills/{skillId}
```

### Mettre à jour une compétence
```http
PUT /api/skills/{skillId}
Headers: X-User-Id: <UUID>
Body:
{
  "title": "Nouveau titre",
  "active": false
}
```

### Supprimer une compétence
```http
DELETE /api/skills/{skillId}
Headers: X-User-Id: <UUID>
```

## 📦 Catégories disponibles

- BRICOLAGE
- SCOLAIRE
- SPORT
- INFORMATIQUE
- CUISINE
- JARDINAGE
- MUSIQUE
- LANGUES
- ART
- AUTRE

## 🗄️ Modèle de données

```json
{
  "skillId": "uuid",
  "ownerId": "uuid",
  "title": "string",
  "description": "string",
  "category": "string",
  "geoPoint": {
    "type": "Point",
    "coordinates": [longitude, latitude]
  },
  "active": true,
  "createdAt": "date",
  "updatedAt": "date"
}
```

## 🔍 Géolocalisation

Le service utilise MongoDB avec un index géospatial 2dsphere pour les recherches de proximité:
- Format: GeoJSON Point
- Coordonnées: [longitude, latitude]
- Distance calculée en kilomètres
- Résultats triés par distance

## 🏗️ Architecture

```
controller/ → Endpoints REST
service/    → Logique métier
repository/ → Accès MongoDB
model/      → Entités
dto/        → Data Transfer Objects
exception/  → Gestion des erreurs
```
