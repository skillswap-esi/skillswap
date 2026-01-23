# Notes d'Implémentation - Skill Service

## 🎯 Objectifs réalisés

✅ Service de gestion des compétences avec géolocalisation  
✅ Recherche par proximité géographique (MongoDB 2dsphere)  
✅ Filtrage par catégorie  
✅ CRUD complet avec validation des permissions  
✅ API REST conforme à l'architecture  

## 🏗️ Architecture technique

### Modèle de données (Skill)

```java
@Document("skills")
public class Skill {
    @Id
    private UUID skillId;
    
    @Indexed
    private UUID ownerId;
    
    @Indexed
    private String category;
    
    private String title;
    private String description;
    
    @GeoSpatialIndexed
    private GeoJsonPoint geoPoint; // Format: [longitude, latitude]
    
    private boolean active;
    private Date createdAt;
    private Date updatedAt;
}
```

### Points clés de l'implémentation

#### 1. Géolocalisation avec MongoDB

**Format GeoJSON**:
```json
{
  "type": "Point",
  "coordinates": [longitude, latitude]
}
```

**Important**: MongoDB stocke les coordonnées dans l'ordre `[longitude, latitude]`, mais l'API accepte `latitude, longitude` pour plus d'intuitivité.

**Index géospatial**:
- Type: `2dsphere` (sphère terrestre)
- Créé automatiquement avec `@GeoSpatialIndexed`
- Permet les requêtes `$near`, `$geoWithin`, etc.

#### 2. Recherche par proximité

```java
Point location = new Point(longitude, latitude);
Distance distance = new Distance(radiusKm, Metrics.KILOMETERS);
List<Skill> skills = skillRepository.findByGeoPointNear(location, distance);
```

**Calcul de distance**:
- Formule de Haversine pour calculer la distance entre deux points GPS
- Résultat en kilomètres
- Tri automatique par distance croissante

#### 3. Sécurité et permissions

**Header X-User-Id**:
- Utilisé pour identifier l'utilisateur authentifié
- Vérifié lors des opérations de modification/suppression
- Dans une version production, remplacer par JWT

**Validation**:
- Seul le propriétaire peut modifier/supprimer sa compétence
- Exception `UnauthorizedException` si tentative non autorisée

#### 4. Validation des données

**Annotations Jakarta Validation**:
```java
@NotBlank(message = "Title is required")
private String title;

@NotNull(message = "Latitude is required")
private Double latitude;
```

**Gestion des erreurs**:
- `GlobalExceptionHandler` pour centraliser la gestion
- Retour de messages d'erreur clairs
- Codes HTTP appropriés (400, 403, 404, 500)

## 📊 Flux de données

### Création d'une compétence

```
Client → POST /api/skills
       ↓
Controller (validation)
       ↓
Service (conversion lat/lng → GeoJSON)
       ↓
Repository (save MongoDB)
       ↓
Response (SkillResponse DTO)
```

### Recherche géographique

```
Client → GET /api/skills/near?lat=48.8566&lng=2.3522&radius=10
       ↓
Controller (parsing params)
       ↓
Service (création Point + Distance)
       ↓
Repository (requête géospatiale MongoDB)
       ↓
Service (calcul distances + tri)
       ↓
Response (List<SkillResponse> avec distances)
```

## 🔧 Configuration MongoDB

### Index créés automatiquement

1. **Index géospatial sur geoPoint**:
```javascript
{
  "geoPoint": "2dsphere"
}
```

2. **Index sur ownerId** (pour requêtes par utilisateur):
```javascript
{
  "ownerId": 1
}
```

3. **Index sur category** (pour filtrage):
```javascript
{
  "category": 1
}
```

### Requête MongoDB générée

Pour une recherche à proximité:
```javascript
db.skills.find({
  geoPoint: {
    $near: {
      $geometry: {
        type: "Point",
        coordinates: [2.3522, 48.8566]
      },
      $maxDistance: 10000 // en mètres
    }
  },
  active: true
})
```

## 🚀 Améliorations futures

### Court terme

1. **Pagination**:
```java
Page<Skill> findByGeoPointNear(Point point, Distance distance, Pageable pageable);
```

2. **Cache Redis**:
- Cache des recherches fréquentes
- TTL de 5 minutes

3. **Validation des catégories**:
```java
@ValidCategory // Custom validator
private String category;
```

### Moyen terme

1. **Score de pertinence**:
- Intégrer le `helperScore` de l'utilisateur
- Pondération distance + score

2. **Recherche avancée**:
- Recherche textuelle (titre, description)
- Filtres multiples (catégories, distance, score)
- Tri personnalisable

3. **Statistiques**:
- Nombre de vues par compétence
- Compétences les plus populaires
- Heatmap géographique

### Long terme

1. **Événements Kafka**:
```java
@KafkaListener(topics = "skill-events")
public void handleSkillEvent(SkillEvent event) {
    // Notification, analytics, etc.
}
```

2. **Elasticsearch**:
- Recherche full-text performante
- Agrégations complexes
- Suggestions de recherche

3. **Machine Learning**:
- Recommandations personnalisées
- Prédiction de matching
- Détection de fraude

## 🔗 Intégration avec les autres services

### Service User

**Appel REST pour récupérer les infos utilisateur**:
```java
@FeignClient(name = "service-user")
public interface UserClient {
    @GetMapping("/api/users/{userId}")
    UserDto getUserById(@PathVariable UUID userId);
}
```

**Enrichissement des réponses**:
```java
SkillResponse response = mapToResponse(skill);
UserDto owner = userClient.getUserById(skill.getOwnerId());
response.setOwnerName(owner.getFullName());
response.setOwnerScore(owner.getHelperScore());
```

### Service Mission

**Événements à publier**:
- `SkillCreatedEvent`: Nouvelle compétence disponible
- `SkillDeletedEvent`: Compétence supprimée (annuler missions associées)
- `SkillDeactivatedEvent`: Compétence désactivée

### Service Notification

**Notifications à envoyer**:
- Nouvelle compétence dans la zone de l'utilisateur
- Compétence recherchée disponible
- Rappel de compétences non utilisées

## 📝 Conventions de code

### Naming

- **Entities**: Singular (Skill, not Skills)
- **Collections MongoDB**: Plural (skills)
- **DTOs**: Suffixe Request/Response
- **Services**: Suffixe Service
- **Repositories**: Suffixe Repository

### Logging

```java
log.info("Creating skill for owner: {}", ownerId);
log.debug("Skill data: {}", skill);
log.error("Error creating skill: {}", e.getMessage(), e);
```

### Exceptions

- `SkillNotFoundException`: Compétence non trouvée (404)
- `UnauthorizedException`: Action non autorisée (403)
- `ValidationException`: Données invalides (400)

## 🧪 Tests à implémenter

### Tests unitaires

```java
@Test
void createSkill_shouldReturnSkillResponse() {
    // Given
    CreateSkillRequest request = new CreateSkillRequest(...);
    
    // When
    SkillResponse response = skillService.createSkill(request, userId);
    
    // Then
    assertNotNull(response.getSkillId());
    assertEquals(request.getTitle(), response.getTitle());
}
```

### Tests d'intégration

```java
@SpringBootTest
@AutoConfigureMockMvc
class SkillControllerIntegrationTest {
    
    @Test
    void searchSkillsNear_shouldReturnSkillsOrderedByDistance() {
        // Test avec vraie base MongoDB
    }
}
```

### Tests de géolocalisation

```java
@Test
void calculateDistance_shouldReturnCorrectDistance() {
    // Paris to Lyon ≈ 392 km
    double distance = skillService.calculateDistance(
        48.8566, 2.3522,  // Paris
        45.7640, 4.8357   // Lyon
    );
    
    assertEquals(392, distance, 10); // ±10 km
}
```

## 📚 Ressources

- [MongoDB Geospatial Queries](https://docs.mongodb.com/manual/geospatial-queries/)
- [Spring Data MongoDB Geo](https://docs.spring.io/spring-data/mongodb/docs/current/reference/html/#mongo.geospatial)
- [GeoJSON Specification](https://geojson.org/)
- [Haversine Formula](https://en.wikipedia.org/wiki/Haversine_formula)

## ✅ Checklist de déploiement

- [ ] Variables d'environnement configurées
- [ ] MongoDB avec support géospatial
- [ ] Index créés et vérifiés
- [ ] Tests passent
- [ ] Documentation API à jour
- [ ] Logs configurés
- [ ] Monitoring en place
- [ ] Backup MongoDB configuré
