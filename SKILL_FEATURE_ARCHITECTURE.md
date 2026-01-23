# Skill Feature - Architecture Overview

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         MOBILE APPLICATION                           │
│                         (Flutter/Dart)                               │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
         ┌──────────▼──────────┐    ┌──────────▼──────────┐
         │   UI Layer (Pages)   │    │  Service Layer      │
         │                      │    │                     │
         │ • CreateSkillPage    │    │ • SkillService      │
         │ • MySkillsPage       │◄───┤ • AuthService       │
         │ • ExploreSkillsPage  │    │ • Geolocator        │
         │ • SkillDetailPage    │    │                     │
         └──────────┬───────────┘    └──────────┬──────────┘
                    │                           │
                    └─────────────┬─────────────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │   Model Layer             │
                    │                           │
                    │ • SkillModel              │
                    │ • SkillCategory           │
                    │ • CreateSkillRequest      │
                    │ • UpdateSkillRequest      │
                    └─────────────┬─────────────┘
                                  │
                                  │ HTTP/REST
                                  │
┌─────────────────────────────────▼─────────────────────────────────┐
│                         API GATEWAY                                │
│                         (Port 8080)                                │
│                                                                    │
│  Routes:                                                           │
│  • /api/skills/* → Skill Service                                  │
│  • /api/users/*  → User Service                                   │
│  • /api/auth/*   → Auth endpoints                                 │
└─────────────────────────────────┬─────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
         ┌──────────▼──────────┐    ┌──────────▼──────────┐
         │   SKILL SERVICE      │    │   USER SERVICE      │
         │   (Port 8082)        │    │   (Port 8081)       │
         │                      │    │                     │
         │ • SkillController    │    │ • UserController    │
         │ • SkillService       │    │ • AuthController    │
         │ • SkillRepository    │    │ • UserRepository    │
         └──────────┬───────────┘    └──────────┬──────────┘
                    │                           │
         ┌──────────▼───────────────────────────▼──────────┐
         │              MONGODB                             │
         │                                                  │
         │  Collections:                                    │
         │  • skills (with 2dsphere geospatial index)      │
         │  • users                                         │
         └──────────────────────────────────────────────────┘
```

## 📱 Mobile App Architecture

### Layer Structure

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Create Skill │  │  My Skills   │  │Explore Skills│     │
│  │     Page     │  │     Page     │  │     Page     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Skill Detail │  │  Home Page   │  │Custom Drawer │     │
│  │     Page     │  │ (Quick Acts) │  │ (Navigation) │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│                       BUSINESS LOGIC LAYER                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │              Skill Service                        │      │
│  │  • createSkill()                                  │      │
│  │  • getSkillsNear()                                │      │
│  │  • getSkillsByUser()                              │      │
│  │  • getSkillById()                                 │      │
│  │  • updateSkill()                                  │      │
│  │  • deleteSkill()                                  │      │
│  └──────────────────────────────────────────────────┘      │
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │           Geolocator Service                      │      │
│  │  • getCurrentPosition()                           │      │
│  │  • checkPermission()                              │      │
│  │  • requestPermission()                            │      │
│  └──────────────────────────────────────────────────┘      │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│                         DATA LAYER                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │              Skill Model                          │      │
│  │  • skillId, ownerId                               │      │
│  │  • title, description, category                   │      │
│  │  • latitude, longitude                            │      │
│  │  • active, createdAt, updatedAt                   │      │
│  │  • distance (for search results)                  │      │
│  │  • owner info (enriched)                          │      │
│  └──────────────────────────────────────────────────┘      │
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │           Skill Category Enum                     │      │
│  │  • BRICOLAGE, SCOLAIRE, SPORT                     │      │
│  │  • INFORMATIQUE, CUISINE, JARDINAGE               │      │
│  │  • MUSIQUE, LANGUES, ART, AUTRE                   │      │
│  └──────────────────────────────────────────────────┘      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow Diagrams

### 1. Create Skill Flow

```
User                    UI                  Service              Backend
 │                      │                      │                    │
 │  Fill Form           │                      │                    │
 ├─────────────────────►│                      │                    │
 │                      │                      │                    │
 │  Tap "Publish"       │                      │                    │
 ├─────────────────────►│                      │                    │
 │                      │  Get Location        │                    │
 │                      ├─────────────────────►│                    │
 │                      │◄─────────────────────┤                    │
 │                      │  Location Data       │                    │
 │                      │                      │                    │
 │                      │  createSkill()       │                    │
 │                      ├─────────────────────►│                    │
 │                      │                      │  POST /api/skills  │
 │                      │                      ├───────────────────►│
 │                      │                      │                    │
 │                      │                      │  Skill Created     │
 │                      │                      │◄───────────────────┤
 │                      │  SkillModel          │                    │
 │                      │◄─────────────────────┤                    │
 │  Success Message     │                      │                    │
 │◄─────────────────────┤                      │                    │
 │                      │                      │                    │
 │  Navigate Back       │                      │                    │
 │◄─────────────────────┤                      │                    │
```

### 2. Explore Skills Flow

```
User                    UI                  Service              Backend
 │                      │                      │                    │
 │  Open Explore        │                      │                    │
 ├─────────────────────►│                      │                    │
 │                      │  Get Location        │                    │
 │                      ├─────────────────────►│                    │
 │                      │◄─────────────────────┤                    │
 │                      │  Location Data       │                    │
 │                      │                      │                    │
 │                      │  getSkillsNear()     │                    │
 │                      ├─────────────────────►│                    │
 │                      │                      │  GET /api/skills/  │
 │                      │                      │  near?lat=X&lng=Y  │
 │                      │                      ├───────────────────►│
 │                      │                      │                    │
 │                      │                      │  Skills + Distance │
 │                      │                      │◄───────────────────┤
 │                      │  List<SkillModel>    │                    │
 │                      │◄─────────────────────┤                    │
 │  Display Skills      │                      │                    │
 │◄─────────────────────┤                      │                    │
 │                      │                      │                    │
 │  Apply Filter        │                      │                    │
 ├─────────────────────►│                      │                    │
 │                      │  getSkillsNear()     │                    │
 │                      │  (with filters)      │                    │
 │                      ├─────────────────────►│                    │
 │                      │                      │  GET /api/skills/  │
 │                      │                      │  near?category=X   │
 │                      │                      ├───────────────────►│
 │                      │                      │◄───────────────────┤
 │                      │◄─────────────────────┤                    │
 │  Updated Results     │                      │                    │
 │◄─────────────────────┤                      │                    │
```

### 3. Manage Skill Flow

```
User                    UI                  Service              Backend
 │                      │                      │                    │
 │  View My Skills      │                      │                    │
 ├─────────────────────►│                      │                    │
 │                      │  getSkillsByUser()   │                    │
 │                      ├─────────────────────►│                    │
 │                      │                      │  GET /api/skills/  │
 │                      │                      │  user/{userId}     │
 │                      │                      ├───────────────────►│
 │                      │                      │◄───────────────────┤
 │                      │◄─────────────────────┤                    │
 │  Display Skills      │                      │                    │
 │◄─────────────────────┤                      │                    │
 │                      │                      │                    │
 │  Tap Skill           │                      │                    │
 ├─────────────────────►│                      │                    │
 │  View Details        │                      │                    │
 │◄─────────────────────┤                      │                    │
 │                      │                      │                    │
 │  Toggle Active       │                      │                    │
 ├─────────────────────►│                      │                    │
 │                      │  updateSkill()       │                    │
 │                      ├─────────────────────►│                    │
 │                      │                      │  PUT /api/skills/  │
 │                      │                      │  {skillId}         │
 │                      │                      ├───────────────────►│
 │                      │                      │◄───────────────────┤
 │                      │◄─────────────────────┤                    │
 │  Success Message     │                      │                    │
 │◄─────────────────────┤                      │                    │
```

## 🗺️ Navigation Map

```
                    ┌─────────────┐
                    │  Home Page  │
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           │               │               │
    ┌──────▼──────┐ ┌─────▼──────┐ ┌─────▼──────┐
    │   Drawer    │ │Quick Action│ │Quick Action│
    │   Menu      │ │  Publish   │ │  Explore   │
    └──────┬──────┘ └─────┬──────┘ └─────┬──────┘
           │               │               │
    ┌──────▼──────┐       │               │
    │  My Skills  │◄──────┘               │
    └──────┬──────┘                       │
           │                               │
    ┌──────▼──────┐                ┌──────▼──────┐
    │   Create    │                │   Explore   │
    │   Skill     │                │   Skills    │
    └──────┬──────┘                └──────┬──────┘
           │                               │
           │         ┌─────────────────────┘
           │         │
    ┌──────▼─────────▼──────┐
    │   Skill Detail Page   │
    │                       │
    │  • View Info          │
    │  • Toggle Active      │
    │  • Delete Skill       │
    └───────────────────────┘
```

## 🔐 Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Layer 1: Device Permissions                                │
│  ┌────────────────────────────────────────────────┐        │
│  │  • Location Permission (Runtime)                │        │
│  │  • Internet Permission                          │        │
│  └────────────────────────────────────────────────┘        │
│                                                              │
│  Layer 2: Authentication                                    │
│  ┌────────────────────────────────────────────────┐        │
│  │  • Firebase Authentication                      │        │
│  │  • User ID Token                                │        │
│  │  • X-User-Id Header                             │        │
│  └────────────────────────────────────────────────┘        │
│                                                              │
│  Layer 3: Authorization                                     │
│  ┌────────────────────────────────────────────────┐        │
│  │  • Owner-only actions (update/delete)           │        │
│  │  • Backend validation                           │        │
│  └────────────────────────────────────────────────┘        │
│                                                              │
│  Layer 4: Data Validation                                   │
│  ┌────────────────────────────────────────────────┐        │
│  │  • Client-side form validation                  │        │
│  │  • Server-side validation                       │        │
│  │  • Input sanitization                           │        │
│  └────────────────────────────────────────────────┘        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 📊 State Management

```
┌─────────────────────────────────────────────────────────────┐
│                      STATE TYPES                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Loading States                                             │
│  ┌────────────────────────────────────────────────┐        │
│  │  • Initial data loading                         │        │
│  │  • Location detection                           │        │
│  │  • API requests                                 │        │
│  │  • Pull-to-refresh                              │        │
│  └────────────────────────────────────────────────┘        │
│                                                              │
│  Data States                                                │
│  ┌────────────────────────────────────────────────┐        │
│  │  • Skills list                                  │        │
│  │  • Current position                             │        │
│  │  • Selected category                            │        │
│  │  • Search radius                                │        │
│  └────────────────────────────────────────────────┘        │
│                                                              │
│  Error States                                               │
│  ┌────────────────────────────────────────────────┐        │
│  │  • Network errors                               │        │
│  │  • Permission errors                            │        │
│  │  • API errors                                   │        │
│  │  • Validation errors                            │        │
│  └────────────────────────────────────────────────┘        │
│                                                              │
│  UI States                                                  │
│  ┌────────────────────────────────────────────────┐        │
│  │  • Empty states                                 │        │
│  │  • Success messages                             │        │
│  │  • Confirmation dialogs                         │        │
│  └────────────────────────────────────────────────┘        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 🌐 Geolocation Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  GEOLOCATION FLOW                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Permission Check                                        │
│     ┌──────────────────────────────────────┐              │
│     │  Geolocator.checkPermission()        │              │
│     └──────────────┬───────────────────────┘              │
│                    │                                        │
│                    ▼                                        │
│  2. Request Permission (if needed)                         │
│     ┌──────────────────────────────────────┐              │
│     │  Geolocator.requestPermission()      │              │
│     └──────────────┬───────────────────────┘              │
│                    │                                        │
│                    ▼                                        │
│  3. Get Current Position                                   │
│     ┌──────────────────────────────────────┐              │
│     │  Geolocator.getCurrentPosition()     │              │
│     │  • desiredAccuracy: high             │              │
│     └──────────────┬───────────────────────┘              │
│                    │                                        │
│                    ▼                                        │
│  4. Store Position                                         │
│     ┌──────────────────────────────────────┐              │
│     │  Position(latitude, longitude)       │              │
│     └──────────────┬───────────────────────┘              │
│                    │                                        │
│                    ▼                                        │
│  5. Use in API Calls                                       │
│     ┌──────────────────────────────────────┐              │
│     │  • Create skill with location        │              │
│     │  • Search nearby skills              │              │
│     │  • Calculate distances               │              │
│     └──────────────────────────────────────┘              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Backend Integration

```
┌─────────────────────────────────────────────────────────────┐
│              BACKEND SERVICE ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Skill Service (Spring Boot)                                │
│  ┌────────────────────────────────────────────────┐        │
│  │                                                 │        │
│  │  Controllers                                    │        │
│  │  ├── SkillController                            │        │
│  │  │   ├── POST /api/skills                       │        │
│  │  │   ├── GET /api/skills/near                   │        │
│  │  │   ├── GET /api/skills/user/{userId}          │        │
│  │  │   ├── GET /api/skills/{skillId}              │        │
│  │  │   ├── PUT /api/skills/{skillId}              │        │
│  │  │   └── DELETE /api/skills/{skillId}           │        │
│  │  │                                               │        │
│  │  Services                                       │        │
│  │  ├── SkillService                               │        │
│  │  │   ├── createSkill()                          │        │
│  │  │   ├── findSkillsNear()                       │        │
│  │  │   ├── findByOwnerId()                        │        │
│  │  │   ├── findById()                             │        │
│  │  │   ├── updateSkill()                          │        │
│  │  │   └── deleteSkill()                          │        │
│  │  │                                               │        │
│  │  Repositories                                   │        │
│  │  ├── SkillRepository (MongoDB)                  │        │
│  │  │   ├── findByGeoPointNear()                   │        │
│  │  │   ├── findByOwnerId()                        │        │
│  │  │   └── Custom geospatial queries              │        │
│  │  │                                               │        │
│  │  Models                                         │        │
│  │  ├── Skill (Entity)                             │        │
│  │  │   ├── @GeoSpatialIndexed geoPoint            │        │
│  │  │   ├── @Indexed ownerId                       │        │
│  │  │   └── @Indexed category                      │        │
│  │  │                                               │        │
│  │  DTOs                                           │        │
│  │  ├── CreateSkillRequest                         │        │
│  │  ├── UpdateSkillRequest                         │        │
│  │  └── SkillResponse                              │        │
│  │                                                 │        │
│  └────────────────────────────────────────────────┘        │
│                          │                                   │
│                          ▼                                   │
│  MongoDB                                                    │
│  ┌────────────────────────────────────────────────┐        │
│  │  Collection: skills                             │        │
│  │  ┌──────────────────────────────────────────┐  │        │
│  │  │  Indexes:                                 │  │        │
│  │  │  • geoPoint (2dsphere)                    │  │        │
│  │  │  • ownerId (ascending)                    │  │        │
│  │  │  • category (ascending)                   │  │        │
│  │  └──────────────────────────────────────────┘  │        │
│  └────────────────────────────────────────────────┘        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 📈 Performance Considerations

### Optimization Strategies

1. **Geospatial Indexing**
   - MongoDB 2dsphere index for fast location queries
   - Indexed ownerId for user skill lookups
   - Indexed category for filtering

2. **Caching** (Future)
   - Cache nearby skills for 5 minutes
   - Cache user's own skills
   - Invalidate on create/update/delete

3. **Pagination** (Future)
   - Limit results to 50 skills per request
   - Implement infinite scroll
   - Load more on demand

4. **Image Optimization** (Future)
   - Compress skill images
   - Use thumbnails for lists
   - Lazy load images

## 🎯 Summary

This architecture provides:
- ✅ Clean separation of concerns
- ✅ Scalable microservices backend
- ✅ Efficient geospatial queries
- ✅ Secure authentication/authorization
- ✅ Responsive mobile UI
- ✅ Error handling at all layers
- ✅ Future-proof design

---

**Architecture Version:** 1.0.0  
**Last Updated:** January 23, 2026  
**Status:** ✅ Implemented & Documented
