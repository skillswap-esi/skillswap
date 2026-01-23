# 🚀 Quick Reference - SkillSwap Backend

## Start Services (3 Terminals)

### Terminal 1: User Service
```bash
cd skillswap-backend/skillswap-service-user
mvn spring-boot:run
```
Wait for: `Started UserServiceApplication`

### Terminal 2: Skill Service
```bash
cd skillswap-backend/skillswap-service-skill
mvn spring-boot:run
```
Wait for: `Started SkillServiceApplication`

### Terminal 3: API Gateway
```bash
cd skillswap-backend/skillswap-api-gateway
mvn spring-boot:run
```
Wait for: `Started ApiGatewayApplication`

## Quick Test Commands

### 1. Health Checks
```bash
curl http://localhost:8081/actuator/health  # User Service
curl http://localhost:8082/actuator/health  # Skill Service
curl http://localhost:8080/actuator/health  # API Gateway
```

### 2. Register User
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","phoneNumber":"+33612345678","fullName":"Test User"}'
```
**Save the JWT token from response!**

### 3. Create Skill (replace YOUR_JWT_TOKEN)
```bash
curl -X POST http://localhost:8080/api/skills \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"title":"Cours de guitare","description":"Cours pour débutants","category":"MUSIQUE","latitude":48.8566,"longitude":2.3522}'
```

### 4. Search Skills
```bash
curl "http://localhost:8080/api/skills/near?lat=48.8566&lng=2.3522&radius=10" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Ports
- **8080** - API Gateway (entry point)
- **8081** - User Service
- **8082** - Skill Service

## MongoDB Databases
- **skillswap-users** - User data
- **skillswap-skills** - Skill data

## Common Issues

### Port in use
```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Service won't start
1. Check MongoDB connection
2. Check port availability
3. Check logs for errors
4. Verify Java 17 is installed

### Unauthorized error
- Ensure JWT token is included
- Check token hasn't expired (24h validity)
- Verify format: `Authorization: Bearer TOKEN`

## Documentation
- `INTEGRATION_COMPLETE.md` - Full integration guide
- `START_SERVICES.md` - Detailed startup
- `FINAL_FIX_SUMMARY.md` - Latest fixes
- Service-specific READMEs in each service folder

## Status: ✅ READY TO RUN
