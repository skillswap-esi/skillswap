# SkillSwap Common Module

Ce module contient les classes partagées utilisées par tous les microservices de l'application SkillSwap.

## Structure

```
com.esi.skillswap.common
│
├── enums/                  # Énumérations
│   ├── MissionStatus.java      # PENDING, ACCEPTED, COMPLETED, CANCELED, DISPUTED
│   └── NotificationType.java   # MISSION_REQUESTED, MISSION_ACCEPTED, OTP_GENERATED, etc.
│
├── models/                 # Modèles partagés
│   ├── GeoJsonPoint.java       # Structure GeoJSON pour MongoDB
│   └── MeetingPoint.java       # Point de rencontre (lat, lng, partnerPlaceId)
│
└── events/                 # Événements Kafka
    └── NotificationEvent.java  # Événement de notification
```

## Utilisation

### Dans le pom.xml de chaque microservice

Ajoutez la dépendance suivante :

```xml
<dependency>
    <groupId>com.esi.skillswap</groupId>
    <artifactId>skillswap-common</artifactId>
    <version>1.0-SNAPSHOT</version>
</dependency>
```

### Dépendances incluses

- **Lombok** : Pour la génération automatique de getters/setters/constructeurs
- **Jakarta Persistence API** : Pour les annotations JPA

## Compilation

```bash
mvn clean install
```

Cette commande compilera le module et l'installera dans votre repository Maven local, le rendant disponible pour les autres modules.

## Enums disponibles

### MissionStatus
- `PENDING` : Mission en attente
- `ACCEPTED` : Mission acceptée
- `COMPLETED` : Mission terminée
- `CANCELED` : Mission annulée
- `DISPUTED` : Mission contestée

### NotificationType
- `MISSION_REQUESTED` : Demande de mission
- `MISSION_ACCEPTED` : Mission acceptée
- `OTP_GENERATED` : OTP généré
- `MISSION_COMPLETED` : Mission terminée
- `PHONE_VERIFIED` : Téléphone vérifié
- `NEW_MESSAGE` : Nouveau message

## Models

### GeoJsonPoint
Structure MongoDB pour les coordonnées géographiques :
```java
{
  "type": "Point",
  "coordinates": [longitude, latitude]
}
```

### MeetingPoint
Point de rencontre pour les missions avec coordonnées et référence optionnelle à un lieu partenaire.

## Events

Les événements sont utilisés pour la communication asynchrone via Kafka entre les microservices.

