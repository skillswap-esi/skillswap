# SkillSwap Quick Start Guide

Get SkillSwap running in 5 steps!

## Prerequisites

- ✅ Java 17 installed
- ✅ Maven installed
- ✅ Docker Desktop installed
- ✅ Flutter installed (for mobile)
- ✅ MongoDB Atlas account (free tier)

---

## Step 1: Start Docker Services (2 minutes)

```cmd
cd skillswap-backend
docker-compose up -d
```

Wait for:
```
✔ Container skillswap-redis      Started
✔ Container skillswap-zookeeper  Started
✔ Container skillswap-kafka      Started
```

**Verify:**
```cmd
docker-compose ps
```

All should show "Up" status.

---

## Step 2: Configure MongoDB Atlas (5 minutes)

### A. Create Free Cluster
1. Go to: https://cloud.mongodb.com
2. Sign up / Login
3. Create free cluster (M0)
4. Choose region closest to you

### B. Create Database User
1. Go to "Database Access"
2. Add new user:
   - Username: `skillswap-user`
   - Password: `YourPassword123`
   - Role: Read and write to any database

### C. Whitelist IP
1. Go to "Network Access"
2. Add IP: `0.0.0.0/0` (allow from anywhere)

### D. Get Connection String
1. Click "Connect" on your cluster
2. Choose "Connect your application"
3. Copy connection string:
   ```
   mongodb+srv://skillswap-user:YourPassword123@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```

### E. Update Service Configurations

**User Service:** `skillswap-service-user/src/main/resources/application.yml`
```yaml
spring:
  data:
    mongodb:
      uri: mongodb+srv://skillswap-user:YourPassword123@cluster0.xxxxx.mongodb.net/skillswap-users?retryWrites=true&w=majority
```

**Skill Service:** `skillswap-service-skill/src/main/resources/application.yml`
```yaml
spring:
  data:
    mongodb:
      uri: mongodb+srv://skillswap-user:YourPassword123@cluster0.xxxxx.mongodb.net/skillswap-skills?retryWrites=true&w=majority
```

**Mission Service:** `skillswap-service-mission/src/main/resources/application.yml`
```yaml
spring:
  data:
    mongodb:
      uri: mongodb+srv://skillswap-user:YourPassword123@cluster0.xxxxx.mongodb.net/skillswap-missions?retryWrites=true&w=majority
```

**Notification Service:** `skillswap-service-notification/src/main/resources/application.yml`
```yaml
spring:
  data:
    mongodb:
      uri: mongodb+srv://skillswap-user:YourPassword123@cluster0.xxxxx.mongodb.net/skillswap-notifications?retryWrites=true&w=majority
```

---

## Step 3: Start Backend Services (5 minutes)

Open 5 separate Command Prompt windows:

### Window 1: API Gateway
```cmd
cd skillswap-backend\skillswap-api-gateway
mvnw spring-boot:run
```
Wait for: `Started ApiGatewayApplication on port 8080`

### Window 2: User Service
```cmd
cd skillswap-backend\skillswap-service-user
mvnw spring-boot:run
```
Wait for: `Started UserServiceApplication on port 8081`

### Window 3: Skill Service
```cmd
cd skillswap-backend\skillswap-service-skill
mvnw spring-boot:run
```
Wait for: `Started SkillServiceApplication on port 8082`

### Window 4: Mission Service
```cmd
cd skillswap-backend\skillswap-service-mission
mvnw spring-boot:run
```
Wait for: `Started MissionServiceApplication on port 8083`

### Window 5: Notification Service
```cmd
cd skillswap-backend\skillswap-service-notification
mvnw spring-boot:run
```
Wait for: `Started NotificationServiceApplication on port 8084`

**All services should start without errors!**

---

## Step 4: Configure Mobile App (1 minute)

Edit: `skillswap_front_mobile/lib/core/api_config.dart`

**For Android Emulator:**
```dart
static const String _androidEmulatorUrl = 'http://10.0.2.2:8080';
```

**For iOS Simulator:**
```dart
static const String _webUrl = 'http://localhost:8080';
```

**For Physical Device:**
```dart
static const String _webUrl = 'http://YOUR_COMPUTER_IP:8080';
```

To find your IP:
```cmd
ipconfig
```
Look for "IPv4 Address" (e.g., 192.168.1.100)

---

## Step 5: Run Mobile App (2 minutes)

```cmd
cd skillswap_front_mobile
flutter run
```

Choose your device:
- [1] Android Emulator
- [2] iOS Simulator
- [3] Chrome (web)

**App should launch successfully!**

---

## Test the Complete Flow

### 1. Register User
- Open app
- Click "Register"
- Fill form and submit
- Login with credentials

### 2. Create Skill
- Go to "My Skills"
- Click "+" button
- Fill skill details
- Submit

### 3. Browse Skills
- Go to "Explore Skills"
- See your skill and others
- Click on a skill

### 4. Request Mission
- On skill detail page
- Click "Request Mission"
- Fill mission details
- Submit

### 5. Accept Mission (as helper)
- Go to "My Missions" → "Helping" tab
- See pending mission
- Click mission → Accept

### 6. Complete Mission
- Start mission
- Helper generates OTP
- Requester validates OTP
- Mission completed!

### 7. Check Notifications
- Go to "Notifications"
- See all mission events
- Mark as read

---

## Verify Everything is Working

### Check Docker Services
```cmd
docker-compose ps
```
All should be "Up"

### Check Backend Services
Open in browser:
- http://localhost:8080/actuator/health (API Gateway)
- http://localhost:8081/actuator/health (User Service)
- http://localhost:8082/actuator/health (Skill Service)
- http://localhost:8083/actuator/health (Mission Service)
- http://localhost:8084/actuator/health (Notification Service)

All should return: `{"status":"UP"}`

### Check Kafka Topics
```cmd
docker exec skillswap-kafka kafka-topics --list --bootstrap-server localhost:9092
```
Should show: `mission-events`

### Check Redis
```cmd
docker exec skillswap-redis redis-cli ping
```
Should return: `PONG`

---

## Common Issues

### Issue: "Port 8080 already in use"
**Solution:** Another app is using port 8080
```cmd
netstat -ano | findstr :8080
taskkill /PID <process_id> /F
```

### Issue: "Cannot connect to MongoDB"
**Solution:** Check connection string in application.yml
- Verify username/password
- Verify IP is whitelisted (0.0.0.0/0)
- Check internet connection

### Issue: "Kafka not available"
**Solution:** Wait 30 seconds for Kafka to start
```cmd
docker-compose logs kafka
```

### Issue: Mobile app can't connect
**Solution:** Check API URL in api_config.dart
- Android emulator: Use 10.0.2.2
- iOS simulator: Use localhost
- Physical device: Use computer's IP

### Issue: Skills not saving (MongoDB index error)
**Solution:** Clean MongoDB Atlas
1. Go to MongoDB Atlas
2. Browse Collections → skillswap-skills → skills
3. Delete all documents
4. Go to Indexes tab
5. Drop "geoPoint" index
6. Restart Skill Service

---

## Stopping Everything

### Stop Backend Services
Press `Ctrl+C` in each Command Prompt window

### Stop Docker Services
```cmd
cd skillswap-backend
docker-compose stop
```

### Stop Mobile App
Press `Ctrl+C` in Flutter terminal

---

## Restarting After Computer Restart

1. Start Docker Desktop
2. Run: `docker-compose up -d`
3. Start backend services (5 windows)
4. Run mobile app

---

## Resource Usage

**Minimal setup:**
- Docker: ~500MB RAM
- Each Spring Boot service: ~300MB RAM
- Total: ~2GB RAM

**To reduce:**
- Run only services you're testing
- Stop Docker when not developing
- Close unused services

---

## Next Steps

### Add Firebase (Optional)
- Configure Firebase Cloud Messaging for push notifications
- See: skillswap-service-notification/README.md

### Production Deployment
- Use environment variables for secrets
- Configure proper MongoDB users per service
- Enable Kafka authentication
- Use Redis password
- Deploy to cloud (AWS, Azure, GCP)

---

## Getting Help

### Documentation
- `SYSTEM_ARCHITECTURE.md` - System overview
- `DOCKER_MINIMAL_SETUP.md` - Docker details
- `MOBILE_IMPLEMENTATION_SUMMARY.md` - Mobile features
- Each service has its own README.md

### Logs
```cmd
# Docker logs
docker-compose logs -f

# Spring Boot logs
Check the Command Prompt windows

# Mobile logs
Check Flutter console
```

---

## Success! 🎉

You now have:
- ✅ Docker services running (Kafka + Redis)
- ✅ MongoDB Atlas configured
- ✅ 5 microservices running
- ✅ Mobile app connected
- ✅ Complete mission flow working

**Happy coding!** 🚀
