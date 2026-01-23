# 🗄️ Initialize MongoDB Collections

## Why Collections Don't Exist Yet

**MongoDB collections are created ONLY when you insert the first document.**

Unlike SQL databases where you create tables with schema upfront, MongoDB is schema-less and creates collections on-demand when you first write data.

## Current Status

✅ Services are running  
✅ MongoDB connections are configured  
✅ `auto-index-creation: true` is enabled  
❌ Collections don't exist yet (no data inserted)  

## How to Create Collections

### Option 1: Use the Mobile App (Recommended)

1. **Start the mobile app**
2. **Register a user** → Creates `users` collection in `skillswap-users` database
3. **Login**
4. **Create a skill** → Creates `skills` collection in `skillswap-skills` database

### Option 2: Use cURL Commands

#### Step 1: Create a User (creates `users` collection)

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "phoneNumber": "+33612345678",
    "fullName": "Test User"
  }'
```

**Response** (save the token):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "email": "test@example.com",
  "fullName": "Test User"
}
```

#### Step 2: Create a Skill (creates `skills` collection)

Replace `YOUR_JWT_TOKEN` with the token from Step 1:

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

### Option 3: Use Postman

1. Import the Postman collection: `SkillSwap-Complete-Integration.postman_collection.json`
2. Run "Register User" request
3. Copy the JWT token from response
4. Set it as a variable
5. Run "Create Skill" request

## What Gets Created

### After User Registration

**Database**: `skillswap-users`
- **Collection**: `users`
- **Indexes**:
  - `_id` (default)
  - `email` (unique)
  - `phoneNumber` (unique)

**Document Example**:
```json
{
  "_id": "123e4567-e89b-12d3-a456-426614174000",
  "email": "test@example.com",
  "phoneNumber": "+33612345678",
  "fullName": "Test User",
  "phoneVerified": false,
  "creditsBalance": 0,
  "helperScore": 0.0,
  "roles": ["USER"],
  "fcmTokens": [],
  "createdAt": "2026-01-22T18:00:00Z",
  "updatedAt": "2026-01-22T18:00:00Z",
  "_class": "com.skillswap.user.model.User"
}
```

### After Skill Creation

**Database**: `skillswap-skills`
- **Collection**: `skills`
- **Indexes**:
  - `_id` (default)
  - `ownerId`
  - `category`
  - `geoPoint` (2dsphere - for geospatial queries)

**Document Example**:
```json
{
  "_id": "456e7890-e89b-12d3-a456-426614174001",
  "ownerId": "123e4567-e89b-12d3-a456-426614174000",
  "title": "Cours de guitare",
  "description": "Cours de guitare pour débutants",
  "category": "MUSIQUE",
  "geoPoint": {
    "type": "Point",
    "coordinates": [2.3522, 48.8566]
  },
  "active": true,
  "createdAt": "2026-01-22T18:00:00Z",
  "updatedAt": "2026-01-22T18:00:00Z",
  "_class": "com.skillswap.skill.model.Skill"
}
```

## Verify in MongoDB Atlas

1. Go to [MongoDB Atlas](https://cloud.mongodb.com/)
2. Click on your cluster
3. Click "Browse Collections"
4. You should see:
   - Database: `skillswap-users` → Collection: `users`
   - Database: `skillswap-skills` → Collection: `skills`

## Check Indexes

### For Users Collection

In MongoDB Atlas or MongoDB Compass:
```javascript
db.users.getIndexes()
```

Should show:
```json
[
  { "v": 2, "key": { "_id": 1 }, "name": "_id_" },
  { "v": 2, "key": { "email": 1 }, "name": "email", "unique": true },
  { "v": 2, "key": { "phoneNumber": 1 }, "name": "phoneNumber", "unique": true }
]
```

### For Skills Collection

```javascript
db.skills.getIndexes()
```

Should show:
```json
[
  { "v": 2, "key": { "_id": 1 }, "name": "_id_" },
  { "v": 2, "key": { "ownerId": 1 }, "name": "ownerId" },
  { "v": 2, "key": { "category": 1 }, "name": "category" },
  { 
    "v": 2, 
    "key": { "geoPoint": "2dsphere" }, 
    "name": "geoPoint",
    "2dsphereIndexVersion": 3
  }
]
```

## Important Notes

### 1. Collections Are Created Lazily

MongoDB doesn't create collections until you insert data. This is normal behavior.

### 2. Indexes Are Created Automatically

With `auto-index-creation: true`, Spring Data MongoDB will:
- Create indexes defined with `@Indexed` annotation
- Create geospatial indexes defined with `@GeoSpatialIndexed`
- Create unique indexes where specified

### 3. Database Names

Make sure your MongoDB URIs include the database name:
- User Service: `...mongodb.net/skillswap-users?...`
- Skill Service: `...mongodb.net/skillswap-skills?...`

### 4. First Insert Creates Everything

The first time you insert a document:
1. MongoDB creates the database (if it doesn't exist)
2. MongoDB creates the collection
3. Spring Data creates all indexes defined in the entity

## Troubleshooting

### Collections still not appearing?

**Check 1**: Verify services are connected to MongoDB
```bash
# Check User Service logs
# Should see: "Connected to MongoDB"

# Check Skill Service logs
# Should see: "Connected to MongoDB"
```

**Check 2**: Verify you're looking at the right database
- User data: Database `skillswap-users`, Collection `users`
- Skill data: Database `skillswap-skills`, Collection `skills`

**Check 3**: Try inserting data directly via MongoDB Compass
1. Connect to your MongoDB Atlas cluster
2. Create database manually: `skillswap-users`
3. Create collection manually: `users`
4. Try the API call again

### Indexes not created?

**Solution**: Set `auto-index-creation: true` in `application.yml` (already done)

If still not working, create indexes manually:
```javascript
// In MongoDB shell or Compass
use skillswap-users
db.users.createIndex({ "email": 1 }, { unique: true })
db.users.createIndex({ "phoneNumber": 1 }, { unique: true })

use skillswap-skills
db.skills.createIndex({ "ownerId": 1 })
db.skills.createIndex({ "category": 1 })
db.skills.createIndex({ "geoPoint": "2dsphere" })
```

## Quick Test Script

Run this to create both collections:

```bash
# Windows
create-collections-test.bat

# Or manually with cURL (see Option 2 above)
```

---

**Summary**: Collections are created automatically when you insert the first document. Just register a user and create a skill, and everything will be set up!
