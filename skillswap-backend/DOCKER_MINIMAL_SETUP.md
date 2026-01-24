# Minimal Docker Setup Guide - Step by Step

This guide shows how to install and run only the essential Docker services for SkillSwap (Kafka + Redis).

## What You Need

**Only 3 Docker containers:**
1. **Redis** (~5MB) - For OTP codes
2. **Zookeeper** (~50MB) - Required by Kafka
3. **Kafka** (~100MB) - For event streaming

**Total: ~155MB** (much lighter than full setup)

**Note:** MongoDB is in the cloud (MongoDB Atlas), so no Docker needed for database.

---

## Step 1: Install Docker Desktop

### Windows
1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop
2. Run the installer
3. Restart your computer
4. Open Docker Desktop
5. Wait for "Docker Desktop is running" message

### Verify Installation
Open Command Prompt (cmd) and run:
```cmd
docker --version
docker-compose --version
```

You should see version numbers like:
```
Docker version 24.0.x
Docker Compose version v2.x.x
```

---

## Step 2: Navigate to Project Directory

Open Command Prompt and go to your project:
```cmd
cd path\to\skillswap-backend
```

Example:
```cmd
cd C:\Users\YourName\Projects\skillswap-backend
```

---

## Step 3: Start Docker Services

Run this single command:
```cmd
docker-compose up -d
```

**What happens:**
- `-d` means "detached mode" (runs in background)
- Docker will download images (first time only, ~5-10 minutes)
- Creates 3 containers: redis, zookeeper, kafka

**Expected output:**
```
[+] Running 3/3
 ✔ Container skillswap-redis      Started
 ✔ Container skillswap-zookeeper  Started
 ✔ Container skillswap-kafka      Started
```

---

## Step 4: Verify Services are Running

Check if containers are running:
```cmd
docker-compose ps
```

**Expected output:**
```
NAME                   STATUS    PORTS
skillswap-kafka        Up        0.0.0.0:9092->9092/tcp
skillswap-redis        Up        0.0.0.0:6379->6379/tcp
skillswap-zookeeper    Up        0.0.0.0:2181->2181/tcp
```

All should show "Up" status.

---

## Step 5: Test Connections

### Test Redis
```cmd
docker exec skillswap-redis redis-cli ping
```
**Expected:** `PONG`

### Test Kafka
```cmd
docker exec skillswap-kafka kafka-topics --list --bootstrap-server localhost:9092
```
**Expected:** Empty list or existing topics (no errors)

---

## Managing Docker Services

### Stop Services (keeps data)
```cmd
docker-compose stop
```

### Start Services Again
```cmd
docker-compose start
```

### Restart Services
```cmd
docker-compose restart
```

### Stop and Remove Services (keeps data)
```cmd
docker-compose down
```

### Stop and Remove Everything (deletes data)
```cmd
docker-compose down -v
```

### View Logs
```cmd
docker-compose logs -f
```
Press `Ctrl+C` to exit logs.

### View Logs for Specific Service
```cmd
docker-compose logs -f redis
docker-compose logs -f kafka
```

---

## Troubleshooting

### Problem: "Port already in use"

**Solution 1:** Stop the service using that port
```cmd
netstat -ano | findstr :9092
netstat -ano | findstr :6379
```
Find the PID (last column) and kill it:
```cmd
taskkill /PID <process_id> /F
```

**Solution 2:** Change ports in docker-compose.yml
```yaml
ports:
  - "9093:9092"  # Use 9093 instead of 9092
```

### Problem: "Cannot connect to Docker daemon"

**Solution:** Start Docker Desktop application

### Problem: Kafka not starting

**Solution:** Wait 30 seconds, Kafka needs time to connect to Zookeeper
```cmd
docker-compose logs kafka
```

### Problem: Out of disk space

**Solution:** Clean up Docker
```cmd
docker system prune -a
```

---

## Resource Usage

**Minimal setup uses:**
- RAM: ~500MB
- CPU: Low (only when processing events)
- Disk: ~200MB (images + data)

**To reduce further:**
- Stop services when not developing: `docker-compose stop`
- Remove unused Docker images: `docker image prune -a`

---

## What Each Service Does

### Redis (Port 6379)
- Stores OTP codes temporarily (5 minutes)
- Used by Mission Service
- Very lightweight and fast

### Kafka (Port 9092)
- Sends events between services
- Mission Service publishes events
- Notification Service consumes events
- Auto-creates topics when needed

### Zookeeper (Port 2181)
- Manages Kafka cluster
- Required by Kafka
- Runs in background

---

## Optional: Monitoring Tools

If you want to see what's happening inside Kafka/Redis, you can add monitoring tools.

### Add Kafka UI (Optional)

Edit `docker-compose.yml` and add:
```yaml
  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    container_name: skillswap-kafka-ui
    depends_on:
      - kafka
    ports:
      - "8090:8080"
    environment:
      KAFKA_CLUSTERS_0_NAME: skillswap
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:9092
      KAFKA_CLUSTERS_0_ZOOKEEPER: zookeeper:2181
    networks:
      - skillswap-network
```

Then restart:
```cmd
docker-compose up -d
```

Access at: http://localhost:8090

---

## Next Steps After Docker is Running

1. **Configure MongoDB Atlas** (cloud database)
   - See: DOCKER_SETUP_GUIDE.md (MongoDB Atlas section)

2. **Start Spring Boot Services**
   ```cmd
   cd skillswap-api-gateway
   mvnw spring-boot:run
   ```
   Repeat for each service (user, skill, mission, notification)

3. **Run Mobile App**
   ```cmd
   cd skillswap_front_mobile
   flutter run
   ```

---

## Quick Reference Commands

```cmd
# Start everything
docker-compose up -d

# Stop everything
docker-compose stop

# View status
docker-compose ps

# View logs
docker-compose logs -f

# Restart
docker-compose restart

# Clean up
docker-compose down

# Test Redis
docker exec skillswap-redis redis-cli ping

# Test Kafka
docker exec skillswap-kafka kafka-topics --list --bootstrap-server localhost:9092
```

---

## When to Restart Docker Services

Restart when:
- Services not responding
- After computer restart
- After changing docker-compose.yml
- After Docker Desktop update

**Don't need to restart when:**
- Starting/stopping Spring Boot services
- Running mobile app
- Changing application.yml files

---

## Disk Space Management

### Check Docker disk usage
```cmd
docker system df
```

### Clean up unused data
```cmd
docker system prune
```

### Remove all stopped containers
```cmd
docker container prune
```

### Remove unused images
```cmd
docker image prune -a
```

---

## Summary

**To start developing:**
1. Open Docker Desktop
2. Run: `docker-compose up -d`
3. Wait 30 seconds
4. Verify: `docker-compose ps`
5. Start your Spring Boot services
6. Start mobile app

**To stop developing:**
1. Stop Spring Boot services (Ctrl+C)
2. Run: `docker-compose stop`
3. Close Docker Desktop (optional)

**That's it!** Your minimal Docker setup is ready. 🚀
