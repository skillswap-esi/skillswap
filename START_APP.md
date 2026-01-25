# 🚀 Quick Start Guide - Run SkillSwap

## Prerequisites Check

Before starting, ensure you have:
- ✅ Java 17 installed
- ✅ Maven installed
- ✅ Docker Desktop running
- ✅ Flutter SDK installed
- ✅ Android Studio / Xcode (for mobile)
- ✅ MongoDB Atlas account created

## 🎯 Step-by-Step Startup

### Step 1: Start Docker Services (1 minute)

```cmd
cd skillswap-backend
docker-compose up -d
```

Wait 30 seconds for Kafka to fully start.

**Verify:**
```cmd
docker ps
```
You should see: `skillswap-redis`, `skillswap-kafka`, `skillswap-zookeeper`

### Step 2: Start Backend Services (2 minutes)

Open **5 separate terminals** and run:

**Terminal 1 - API Gateway:**
```cmd
cd skillswap-backend\skillswap-api-gateway
mvnw spring-boot:run
```
Wait for: `Started ApiGatewayApplication` on port 8080

**Terminal 2 - User Service:**
```cmd
cd skillswap-backend\skillswap-service-user
mvnw spring-boot:run
```
Wait for: `Started UserServiceApplication` on port 8081

**Terminal 3 - Skill Service:**
```cmd
cd skillswap-backend\skillswap-service-skill
mvnw spring-boot:run
```
Wait for: `Started SkillServiceApplication` on port 8082

**Terminal 4 - Mission Service:**
```cmd
cd skillswap-backend\skillswap-service-mission
mvnw spring-boot:run
```
Wait for: `Started MissionServiceApplication` on port 8083

**Terminal 5 - Notification Service:**
```cmd
cd skillswap-backend\skillswap-service-notification
mvnw spring-boot:run
```
Wait for: `Started NotificationServiceApplication` on port 8084

### Step 3: Verify Backend (30 seconds)

Open browser and check health endpoints:
- http://localhost:8080/actuator/health (API Gateway)
- http://localhost:8081/actuator/health (User Service)
- http://localhost:8082/actuator/health (Skill Service)
- http://localhost:8083/actuator/health (Mission Service)
- http://localhost:8084/actuator/health (Notification Service)

All should return: `{"status":"UP"}`

### Step 4: Start Mobile App (1 minute)

**Terminal 6 - Flutter App:**
```cmd
cd skillswap_front_mobile
flutter pub get
flutter run
```

Select device:
- [1] Android Emulator
- [2] iOS Simulator
- [3] Chrome (for testing)

## 🎮 Test the Complete Flow

### 1. Register Two Users

**User A (Provider):**
- Email: `provider@test.com`
- Password: `Test123!`
- Phone: `+1234567890`
- Name: `John Provider`

**User B (Requester):**
- Email: `requester@test.com`
- Password: `Test123!`
- Phone: `+0987654321`
- Name: `Jane Requester`

### 2. Provider Publishes Skill

Login as User A:
1. Navigate to "My Skills"
2. Click "+" button
3. Fill form:
   - Title: `Guitar Lessons`
   - Description: `Learn guitar basics in 1 hour`
   - Category: `Music`
4. GPS location captured automatically
5. Click "Publish"

### 3. Requester Searches and Requests

Login as User B:
1. Navigate to "Explore Skills"
2. See "Guitar Lessons" in results
3. Click on skill
4. Click "Request Mission"
5. **Chat with provider** (optional)
6. **Select meeting point on map**:
   - Option A: Select "Café Central" from partner places
   - Option B: Tap custom location on map
7. Fill details:
   - Date: Tomorrow
   - Time: 2:00 PM
   - Duration: 60 minutes
   - Credits: 10
8. Click "Create Mission"

### 4. Provider Accepts Mission

Login as User A:
1. Receive notification
2. Navigate to "Missions" → "Helping" tab
3. Click on pending mission
4. View meeting point on map
5. Click "Accept"

### 5. Meet and Validate

**On Meeting Day:**

**Provider (User A):**
1. Open mission
2. Click "Start Mission"
3. Click "Generate OTP"
4. Show 6-digit code to requester

**Requester (User B):**
1. Open mission
2. Enter OTP code
3. Click "Validate"

**Result:**
- ✅ Mission completed
- ✅ 10 credits transferred from B to A
- ✅ Both receive notifications
- ✅ Helper Score updated

## 🔍 Monitoring

### Check Kafka Events

```cmd
docker exec skillswap-kafka kafka-console-consumer ^
  --bootstrap-server localhost:9092 ^
  --topic mission-events ^
  --from-beginning
```

### Check Redis OTP

```cmd
docker exec skillswap-redis redis-cli KEYS "mission:otp:*"
docker exec skillswap-redis redis-cli GET "mission:otp:{missionId}"
```

### Check MongoDB

Go to MongoDB Atlas → Browse Collections:
- `skillswap-users` → users, ledger_transactions
- `skillswap-skills` → skills
- `skillswap-missions` → missions

### Check Firestore

Go to Firebase Console → Firestore:
- `chat_threads` → See chat messages
- `notifications` → See notification history

## 🐛 Troubleshooting

### Backend Won't Start

**Problem:** Port already in use
```cmd
netstat -ano | findstr :8080
taskkill /PID <process_id> /F
```

**Problem:** MongoDB connection failed
- Check connection string in `application.yml`
- Verify IP whitelist: 0.0.0.0/0
- Test internet connection

**Problem:** Kafka not ready
- Wait 30 seconds after `docker-compose up`
- Check logs: `docker-compose logs kafka`

### Mobile App Issues

**Problem:** Cannot connect to backend
- Android Emulator: Use `http://10.0.2.2:8080`
- iOS Simulator: Use `http://localhost:8080`
- Physical Device: Use `http://YOUR_IP:8080`

**Problem:** Map not loading
- Add Google Maps API key
- Enable Maps SDK in Google Cloud Console
- Check billing is enabled

**Problem:** Chat not working
- Check Firebase configuration
- Deploy Firestore security rules
- Verify internet connection

## 📊 System Status Dashboard

Create a simple status check:

```cmd
# Check all services
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
curl http://localhost:8083/actuator/health
curl http://localhost:8084/actuator/health

# Check Docker
docker ps

# Check Kafka topics
docker exec skillswap-kafka kafka-topics --list --bootstrap-server localhost:9092
```

## 🎉 Success Indicators

You know everything is working when:

1. ✅ All 5 backend services show "UP"
2. ✅ Docker shows 3 containers running
3. ✅ Mobile app connects and loads home page
4. ✅ Can register and login
5. ✅ Can create and search skills
6. ✅ Can chat in real-time
7. ✅ Can select meeting point on map
8. ✅ Can request and accept missions
9. ✅ Can generate and validate OTP
10. ✅ Credits transfer successfully

## 🚦 Quick Commands

### Start Everything
```cmd
# Terminal 1: Docker
cd skillswap-backend && docker-compose up -d

# Terminal 2-6: Backend services (run in separate terminals)
cd skillswap-backend\skillswap-api-gateway && mvnw spring-boot:run
cd skillswap-backend\skillswap-service-user && mvnw spring-boot:run
cd skillswap-backend\skillswap-service-skill && mvnw spring-boot:run
cd skillswap-backend\skillswap-service-mission && mvnw spring-boot:run
cd skillswap-backend\skillswap-service-notification && mvnw spring-boot:run

# Terminal 7: Mobile app
cd skillswap_front_mobile && flutter run
```

### Stop Everything
```cmd
# Stop backend services: Ctrl+C in each terminal

# Stop Docker
cd skillswap-backend
docker-compose down
```

## 📝 Notes

- First startup takes 2-3 minutes
- Subsequent startups are faster
- Keep all terminals open while testing
- Use hot reload in Flutter (press 'r')
- Check logs if something fails

## 🎓 Learning Path

1. **Day 1**: Setup and run the app
2. **Day 2**: Test complete user flow
3. **Day 3**: Explore chat and map features
4. **Day 4**: Understand backend architecture
5. **Day 5**: Customize and extend

## 🆘 Need Help?

1. Check this guide
2. Review `GETTING_STARTED.md`
3. Check service-specific READMEs
4. Review logs in terminals
5. Check Firebase Console
6. Verify MongoDB Atlas

---

**Ready to see the magic? Let's go! 🚀**

Run the commands above and watch SkillSwap come to life!
