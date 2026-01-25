# SkillSwap - Getting Started Guide

## 📚 Documentation Structure

This project has **4 main documentation files**:

1. **`GETTING_STARTED.md`** (this file) - Start here!
2. **`skillswap-backend/README.md`** - Complete backend documentation
3. **`skillswap_front_mobile/README.md`** - Mobile app documentation
4. **`skillswap-backoffice/README.md`** - Admin panel documentation
5. **`REFACTORING_GUIDE.md`** - helperId → providerId refactoring

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- Java 17
- Maven
- Docker Desktop
- Flutter 3.x
- MongoDB Atlas account (free)

### Step 1: Start Docker (1 min)
```cmd
cd skillswap-backend
docker-compose up -d
```

### Step 2: Configure MongoDB (2 min)
1. Go to https://cloud.mongodb.com
2. Create free cluster
3. Get connection string
4. Update `application.yml` in each service

### Step 3: Start Backend (1 min)
Open 5 terminals:
```cmd
cd skillswap-api-gateway && mvnw spring-boot:run
cd skillswap-service-user && mvnw spring-boot:run
cd skillswap-service-skill && mvnw spring-boot:run
cd skillswap-service-mission && mvnw spring-boot:run
cd skillswap-service-notification && mvnw spring-boot:run
```

### Step 4: Run Mobile App (1 min)
```cmd
cd skillswap_front_mobile
flutter pub get
flutter run
```

## 📖 What is SkillSwap?

SkillSwap is a **skill exchange platform** where users can:
- **Offer skills** (teaching, helping, services)
- **Request skills** from others nearby
- **Meet in public places** for skill exchange
- **Validate missions** with OTP codes
- **Earn/spend credits** for services

### Key Features
✅ Geolocation-based skill search (15km radius)  
✅ Mission lifecycle management  
✅ OTP validation for trust  
✅ Credit-based economy  
✅ Real-time notifications  
✅ Chat via Firebase  
✅ Helper Score (reputation)  

## 🏗️ Architecture Overview

```
Mobile App (Flutter)
        ↓
API Gateway (8080)
        ↓
┌───────┴───────┬───────────┬────────────┐
│               │           │            │
User Service  Skill      Mission    Notification
  (8081)     Service    Service      Service
             (8082)     (8083)       (8084)
                ↓          ↓            ↓
            MongoDB    Redis/Kafka   Kafka
            (Atlas)    (Docker)     (Docker)
```

## 🎯 Complete User Journey

### 1. Registration (S1)
- User enters email, phone, password
- Receives OTP via SMS
- Validates OTP
- Gets 20 credits bonus
- Account activated

### 2. Publish Skill (S3)
- Provider creates skill
- GPS location captured
- Skill visible in search

### 3. Search Skills (S4)
- Requester searches nearby
- Results sorted by score & distance
- Views on map or list

### 4. View Skill & Chat (S5-S6)
- Requester views skill details
- Opens chat with provider
- Real-time messaging via Firestore
- Discusses mission details

### 5. Request Mission with Meeting Point (S7-S8)
- Requester clicks "Request Mission"
- Opens map picker to select meeting point
- **Option A**: Select partner place (café, coworking space)
- **Option B**: Tap custom location on map
- Fills mission details (date, time, duration, cost)
- Can chat with provider during creation
- Credits debited
- Provider notified

### 6. Accept Mission (S9)
- Provider receives notification
- Reviews mission details
- Views meeting point on map
- Accepts or rejects
- Requester notified

### 7. Meet & Validate (S10-S11)
- Both navigate to meeting point
- Provider generates 6-digit OTP
- Requester enters OTP
- Mission completed

### 8. Credit Transfer (S12)
- Credits transferred automatically
- Helper Score updated
- Both users notified
- Transaction recorded

## 🔧 Development Workflow

### Backend Development
1. Make changes in service
2. Compile: `mvn clean install`
3. Restart service
4. Test with Postman or mobile app

### Mobile Development
1. Make changes in Flutter
2. Hot reload: `r` in terminal
3. Full restart: `R` in terminal
4. Test on emulator/device

### Database Changes
1. Update model class
2. Spring Data MongoDB auto-creates collections
3. Add indexes if needed
4. Test queries

## 📊 Monitoring & Debugging

### Check Service Health
```bash
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
curl http://localhost:8083/actuator/health
curl http://localhost:8084/actuator/health
```

### Check Docker Services
```bash
docker-compose ps
docker-compose logs -f kafka
docker-compose logs -f redis
```

### Check Kafka Topics
```bash
docker exec skillswap-kafka kafka-topics --list --bootstrap-server localhost:9092
```

### Check Redis Keys
```bash
docker exec skillswap-redis redis-cli KEYS "*"
```

### View MongoDB Data
1. Go to MongoDB Atlas
2. Browse Collections
3. View documents

## 🐛 Common Issues & Solutions

### Issue: Port 8080 already in use
```bash
netstat -ano | findstr :8080
taskkill /PID <process_id> /F
```

### Issue: Cannot connect to MongoDB
- Check connection string
- Verify IP whitelist (0.0.0.0/0)
- Check internet connection

### Issue: Kafka not starting
- Wait 30 seconds
- Check logs: `docker-compose logs kafka`
- Restart: `docker-compose restart kafka`

### Issue: Mobile app can't connect
- Android emulator: Use `10.0.2.2:8080`
- iOS simulator: Use `localhost:8080`
- Physical device: Use computer's IP

### Issue: Skills not saving
- Clean MongoDB (see backend README)
- Drop "geoPoint" index
- Restart Skill Service

## 📱 Testing the Complete Flow

### Test Scenario: Guitar Lessons

**Setup:**
- User A: Provider (has guitar skill)
- User B: Requester (wants to learn)

**Steps:**
1. User A registers → Gets 20 credits
2. User A publishes "Guitar Lessons" skill
3. User B registers → Gets 20 credits
4. User B searches skills → Finds guitar
5. User B requests mission (10 credits)
6. User A receives notification
7. User A accepts mission
8. User B receives acceptance notification
9. Both navigate to meeting point
10. User A generates OTP: "123456"
11. User B enters OTP: "123456"
12. Mission completed!
13. User A receives 10 credits (total: 30)
14. User B has 10 credits left
15. Both receive completion notifications

## 🔐 Security Notes

### Authentication
- Firebase handles user auth
- JWT tokens for API access
- Tokens expire after 24 hours
- API Gateway validates all requests

### Authorization
- Only skill owner can accept missions
- Only provider can generate OTP
- Only requester can validate OTP
- Users can only access their own data

### Data Privacy
- Exact location never shared
- Only approximate distance shown
- Phone numbers not displayed
- Email addresses private

## 🚀 Deployment

### Backend (Production)
1. Build JARs: `mvn clean package`
2. Deploy to cloud (AWS, Azure, GCP)
3. Use environment variables for secrets
4. Enable HTTPS
5. Configure load balancer
6. Set up monitoring

### Mobile (Production)
1. Build APK: `flutter build apk --release`
2. Build iOS: `flutter build ios --release`
3. Upload to Play Store / App Store
4. Configure Firebase for production
5. Update API URLs

### Database (Production)
1. Use MongoDB Atlas production cluster
2. Enable backup
3. Configure alerts
4. Use dedicated users per service
5. Enable encryption at rest

## 📈 Next Steps

### For Developers
1. Read `skillswap-backend/README.md`
2. Read `skillswap_front_mobile/README.md`
3. Set up development environment
4. Run the complete flow
5. Start building features!

### For Admins
1. Read `skillswap-backoffice/README.md`
2. Set up admin panel
3. Configure partner places
4. Monitor platform health
5. Handle disputes

### For Refactoring
1. Read `REFACTORING_GUIDE.md`
2. Execute find & replace operations
3. Test thoroughly
4. Deploy changes

## 📞 Support

### Documentation
- Backend: `skillswap-backend/README.md`
- Mobile: `skillswap_front_mobile/README.md`
- Admin: `skillswap-backoffice/README.md`
- Refactoring: `REFACTORING_GUIDE.md`

### Troubleshooting
1. Check service logs
2. Verify Docker is running
3. Test MongoDB connection
4. Check API endpoints
5. Review error messages

### Resources
- MongoDB Atlas: https://cloud.mongodb.com
- Firebase Console: https://console.firebase.google.com
- Docker Hub: https://hub.docker.com
- Flutter Docs: https://flutter.dev/docs

## 🎉 Success Criteria

You're ready when:
- [ ] All 5 backend services running
- [ ] Docker services (Kafka, Redis) running
- [ ] MongoDB Atlas connected
- [ ] Mobile app connects to backend
- [ ] Can register new user
- [ ] Can create skill
- [ ] Can search skills
- [ ] Can request mission
- [ ] Can accept mission
- [ ] Can generate/validate OTP
- [ ] Notifications working
- [ ] Credits transferring

## 📝 Project Status

**Backend:** ✅ Production Ready  
**Mobile:** ✅ Production Ready  
**Admin Panel:** 🚧 In Development  
**Documentation:** ✅ Complete  

**Version:** 1.0.0  
**Last Updated:** January 24, 2026

### ✅ Completed Features

**Backend Services:**
- ✅ API Gateway with JWT authentication
- ✅ User Service with credit operations (debit/credit endpoints)
- ✅ Skill Service with geolocation search
- ✅ Mission Service with OTP validation
- ✅ Notification Service with Kafka integration
- ✅ All services compile successfully
- ✅ providerId terminology aligned with PlantUML diagrams

**Infrastructure:**
- ✅ Docker Compose (Kafka + Redis)
- ✅ MongoDB Atlas integration (User, Skill, Mission services only)
- ✅ Redis OTP storage (5-minute expiration)
- ✅ Kafka event streaming (mission-events topic)
- ✅ Firestore for chat and notification history

**Key Features:**
- ✅ Phone verification with 50 credits bonus
- ✅ Mission lifecycle (PENDING → ACCEPTED → IN_PROGRESS → COMPLETED)
- ✅ OTP generation and validation
- ✅ Credit debit/credit operations
- ✅ Ledger transaction history
- ✅ Real-time notifications via Kafka + FCM
- ✅ Meeting point support (lat, lng, partnerPlaceId)
- ✅ Helper Score tracking
- ✅ **Real-time chat via Firestore**
- ✅ **Interactive map picker for meeting points**
- ✅ **Partner place selection (cafés, coworking spaces)**
- ✅ **Chat integration during mission creation**
- ✅ **Simplified notification service (no MongoDB)**  

---

**Welcome to SkillSwap!** 🎓🤝💡

Start with this guide, then dive into the specific documentation for your area of interest. Happy coding!
