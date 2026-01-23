# Docker Setup Guide - Kafka & Redis

This guide explains how to run Kafka and Redis using Docker while using MongoDB Atlas for cloud database.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Local Development                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │  Kafka   │  │  Redis   │  │ Services │             │
│  │  Docker  │  │  Docker  │  │  Local   │             │
│  │  :9092   │  │  :6379   │  │  :808x   │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                                          │
└─────────────────────────────────────────────────────────┘
                        │
                        │ Internet
                        ▼
            ┌───────────────────────┐
            │   MongoDB Atlas       │
            │   (Cloud Database)    │
            └───────────────────────┘
```

## Prerequisites

- Docker Desktop installed
- Docker Compose installed
- Internet connection (for MongoDB Atlas)

## Docker Compose Configuration

Create `docker-compose.yml` in `skillswap-backend/` directory:

```yaml
version: '3.8'

services:
  # Zookeeper - Required for Kafka
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    container_name: skillswap-zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2181:2181"
    networks:
      - skillswap-network
    volumes:
      - zookeeper-data:/var/lib/zookeeper/data
      - zookeeper-logs:/var/lib/zookeeper/log

  # Kafka - Event Streaming
  kafka:
    image: confluentinc/cp-kafka:7.5.0
    container_name: skillswap-kafka
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
      - "9093:9093"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092,PLAINTEXT_INTERNAL://kafka:9093
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_INTERNAL:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT_INTERNAL
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'true'
    networks:
      - skillswap-network
    volumes:
      - kafka-data:/var/lib/kafka/data
    healthcheck:
      test: ["CMD", "kafka-broker-api-versions", "--bootstrap-server", "localhost:9092"]
      interval: 10s
      timeout: 10s
      retries: 5

  # Redis - OTP Storage
  redis:
    image: redis:7-alpine
    container_name: skillswap-redis
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    networks:
      - skillswap-network
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Kafka UI (Optional - for monitoring)
  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    container_name: skillswap-kafka-ui
    depends_on:
      - kafka
    ports:
      - "8090:8080"
    environment:
      KAFKA_CLUSTERS_0_NAME: skillswap
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:9093
      KAFKA_CLUSTERS_0_ZOOKEEPER: zookeeper:2181
    networks:
      - skillswap-network

  # Redis Commander (Optional - for monitoring)
  redis-commander:
    image: rediscommander/redis-commander:latest
    container_name: skillswap-redis-commander
    depends_on:
      - redis
    ports:
      - "8091:8081"
    environment:
      REDIS_HOSTS: local:redis:6379
    networks:
      - skillswap-network

networks:
  skillswap-network:
    driver: bridge

volumes:
  zookeeper-data:
  zookeeper-logs:
  kafka-data:
  redis-data:
```

## Quick Start

### 1. Start All Services

```bash
cd skillswap-backend
docker-compose up -d
```

### 2. Verify Services are Running

```bash
docker-compose ps
```

Expected output:
```
NAME                      STATUS    PORTS
skillswap-kafka           Up        0.0.0.0:9092->9092/tcp
skillswap-redis           Up        0.0.0.0:6379->6379/tcp
skillswap-zookeeper       Up        0.0.0.0:2181->2181/tcp
skillswap-kafka-ui        Up        0.0.0.0:8090->8080/tcp
skillswap-redis-commander Up        0.0.0.0:8091->8081/tcp
```

### 3. Check Service Health

```bash
# Check Kafka
docker exec skillswap-kafka kafka-topics --list --bootstrap-server localhost:9092

# Check Redis
docker exec skillswap-redis redis-cli ping
# Should return: PONG
```

## Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Kafka | localhost:9092 | Event streaming |
| Redis | localhost:6379 | OTP storage |
| Kafka UI | http://localhost:8090 | Monitor Kafka topics |
| Redis Commander | http://localhost:8091 | Monitor Redis data |

## MongoDB Atlas Configuration

### 1. Create MongoDB Atlas Account
- Go to https://www.mongodb.com/cloud/atlas
- Sign up for free tier

### 2. Create Cluster
- Choose free tier (M0)
- Select region closest to you
- Name: skillswap

### 3. Create Databases
Create 4 databases:
- `skillswap-users`
- `skillswap-skills`
- `skillswap-missions`
- `skillswap-notifications`

### 4. Create Database Users
For each service, create a user:

```
User: skillswap-user
Password: userPassword123
Database: skillswap-users

User: skillswap-skill
Password: skillPassword123
Database: skillswap-skills

User: skillswap-mission
Password: missionPassword123
Database: skillswap-missions

User: skillswap-notification
Password: notificationPassword123
Database: skillswap-notifications
```

### 5. Whitelist IP Address
- Go to Network Access
- Add IP Address: 0.0.0.0/0 (allow from anywhere)
- Or add your specific IP

### 6. Get Connection Strings
For each database:
```
mongodb+srv://<username>:<password>@skillswap.xxxxx.mongodb.net/<database>?retryWrites=true&w=majority
```

### 7. Update application.yml Files

**User Service:**
```yaml
spring:
  data:
    mongodb:
      uri: mongodb+srv://skillswap-user:userPassword123@skillswap.xxxxx.mongodb.net/skillswap-users?retryWrites=true&w=majority
```

**Skill Service:**
```yaml
spring:
  data:
    mongodb:
      uri: mongodb+srv://skillswap-skill:skillPassword123@skillswap.xxxxx.mongodb.net/skillswap-skills?retryWrites=true&w=majority
```

**Mission Service:**
```yaml
spring:
  data:
    mongodb:
      uri: mongodb+srv://skillswap-mission:missionPassword123@skillswap.xxxxx.mongodb.net/skillswap-missions?retryWrites=true&w=majority
```

**Notification Service:**
```yaml
spring:
  data:
    mongodb:
      uri: mongodb+srv://skillswap-notification:notificationPassword123@skillswap.xxxxx.mongodb.net/skillswap-notifications?retryWrites=true&w=majority
```

## Testing Connections

### Test Kafka

```bash
# Create a test topic
docker exec skillswap-kafka kafka-topics --create \
  --topic test-topic \
  --bootstrap-server localhost:9092 \
  --partitions 1 \
  --replication-factor 1

# List topics
docker exec skillswap-kafka kafka-topics --list \
  --bootstrap-server localhost:9092

# Delete test topic
docker exec skillswap-kafka kafka-topics --delete \
  --topic test-topic \
  --bootstrap-server localhost:9092
```

### Test Redis

```bash
# Set a key
docker exec skillswap-redis redis-cli SET test-key "Hello Redis"

# Get the key
docker exec skillswap-redis redis-cli GET test-key

# Delete the key
docker exec skillswap-redis redis-cli DEL test-key

# Check all keys
docker exec skillswap-redis redis-cli KEYS "*"
```

### Test MongoDB Atlas

From your Spring Boot service logs, you should see:
```
INFO org.mongodb.driver.cluster : Discovered replica set primary
INFO org.mongodb.driver.cluster : Cluster created with settings
```

## Managing Docker Services

### Stop All Services
```bash
docker-compose stop
```

### Start All Services
```bash
docker-compose start
```

### Restart All Services
```bash
docker-compose restart
```

### Stop and Remove All Services
```bash
docker-compose down
```

### Stop and Remove All Services + Volumes (Clean Slate)
```bash
docker-compose down -v
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f kafka
docker-compose logs -f redis
```

## Monitoring

### Kafka UI (http://localhost:8090)
- View topics
- View messages
- View consumer groups
- Monitor lag

### Redis Commander (http://localhost:8091)
- View all keys
- View key values
- Delete keys
- Monitor memory usage

## Troubleshooting

### Kafka Not Starting
```bash
# Check Zookeeper is running
docker-compose ps zookeeper

# Check Kafka logs
docker-compose logs kafka

# Restart Kafka
docker-compose restart kafka
```

### Redis Connection Refused
```bash
# Check Redis is running
docker-compose ps redis

# Check Redis logs
docker-compose logs redis

# Test connection
docker exec skillswap-redis redis-cli ping
```

### MongoDB Atlas Connection Issues
- Verify IP is whitelisted
- Check username/password
- Verify database name in connection string
- Check internet connection

### Port Already in Use
```bash
# Find process using port
netstat -ano | findstr :9092
netstat -ano | findstr :6379

# Kill process (Windows)
taskkill /PID <process_id> /F
```

## Data Persistence

Data is persisted in Docker volumes:
- `zookeeper-data`: Zookeeper data
- `zookeeper-logs`: Zookeeper logs
- `kafka-data`: Kafka messages
- `redis-data`: Redis data (with AOF persistence)

To backup data:
```bash
docker run --rm -v kafka-data:/data -v $(pwd):/backup alpine tar czf /backup/kafka-backup.tar.gz /data
```

## Production Considerations

### Kafka
- Increase replication factor to 3
- Use multiple brokers
- Configure retention policies
- Enable authentication (SASL)
- Use SSL/TLS

### Redis
- Enable password authentication
- Configure maxmemory policy
- Use Redis Sentinel for HA
- Enable SSL/TLS

### MongoDB Atlas
- Use dedicated cluster (not free tier)
- Enable backup
- Configure alerts
- Use VPC peering
- Enable encryption at rest

## Resource Requirements

Minimum:
- RAM: 4GB
- CPU: 2 cores
- Disk: 10GB

Recommended:
- RAM: 8GB
- CPU: 4 cores
- Disk: 20GB

## Next Steps

1. Start Docker services: `docker-compose up -d`
2. Configure MongoDB Atlas connection strings
3. Start Spring Boot services
4. Verify Kafka topics are created automatically
5. Test OTP generation (should appear in Redis)
6. Test mission events (should appear in Kafka UI)
7. Monitor services using Kafka UI and Redis Commander
