# Notification Service

Manages push notifications and notification history using Firebase Cloud Messaging and Kafka event consumption.

## Port: 8084

## Features

- Kafka event consumption (mission events)
- Firebase Cloud Messaging (FCM) push notifications
- Notification history storage
- Read/unread tracking
- FCM token management
- Automatic notification sending on events

## Tech Stack

- Spring Boot 3.3.4
- MongoDB (notification history)
- Kafka (event consumption)
- Firebase Admin SDK (FCM)
- Spring Kafka

## Dependencies

- **MongoDB Atlas**: Notification storage
- **Kafka**: Event consumption
- **Firebase**: Push notifications

## Notification Types

- MISSION_CREATED
- MISSION_ACCEPTED
- MISSION_REJECTED
- MISSION_STARTED
- MISSION_COMPLETED
- MISSION_CANCELLED
- SKILL_CREATED
- CREDIT_RECEIVED
- CREDIT_SPENT

## API Endpoints

All endpoints require JWT authentication via API Gateway (X-User-Id header).

### Get Notifications
```
GET /api/notifications
Headers: X-User-Id: {userId}
Response: List of all notifications
```

### Get Unread Notifications
```
GET /api/notifications/unread
Headers: X-User-Id: {userId}
Response: List of unread notifications
```

### Get Unread Count
```
GET /api/notifications/unread/count
Headers: X-User-Id: {userId}
Response: { "count": 5 }
```

### Mark as Read
```
POST /api/notifications/{notificationId}/read
Headers: X-User-Id: {userId}
```

### Mark All as Read
```
POST /api/notifications/read-all
Headers: X-User-Id: {userId}
```

### Delete Notification
```
DELETE /api/notifications/{notificationId}
Headers: X-User-Id: {userId}
```

### Register FCM Token
```
POST /api/notifications/token
Headers: X-User-Id: {userId}
Body: {
  "token": "fcm-device-token",
  "deviceType": "android"  // android, ios, web
}
```

### Unregister FCM Token
```
DELETE /api/notifications/token
Headers: X-User-Id: {userId}
```

## Kafka Event Handling

### Consumed Topic
- `mission-events`

### Event Processing

**MISSION_CREATED**
- Notify skill owner about new mission request

**MISSION_ACCEPTED**
- Notify requester that mission was accepted

**MISSION_REJECTED**
- Notify requester with rejection reason

**MISSION_STARTED**
- Notify both requester and helper

**MISSION_COMPLETED**
- Notify requester about completion
- Notify helper about credits received

**MISSION_CANCELLED**
- Notify both parties with cancellation reason

## Data Models

### Notification
```java
{
  notificationId: UUID
  userId: UUID
  type: NotificationType
  title: String
  message: String
  data: Map<String, Object>
  read: Boolean
  sentAt: Date
  readAt: Date
  fcmSent: Boolean
  fcmMessageId: String
}
```

### FCM Token
```java
{
  id: UUID
  userId: UUID
  token: String
  deviceType: String
  active: Boolean
  createdAt: Date
  updatedAt: Date
}
```

## Firebase Configuration

### Setup FCM

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Go to Project Settings → Service Accounts
4. Click "Generate New Private Key"
5. Save as `firebase-service-account.json`
6. Place in `src/main/resources/`

### Enable FCM

Update `application.yml`:
```yaml
firebase:
  credentials-path: classpath:firebase-service-account.json
  enabled: true
```

### Without FCM

If FCM is not configured:
```yaml
firebase:
  enabled: false
```

Notifications will be stored in database but not sent via push.

## Configuration

### application.yml
```yaml
server:
  port: 8084

spring:
  data:
    mongodb:
      uri: mongodb+srv://...
  kafka:
    bootstrap-servers: localhost:9092
    consumer:
      group-id: notification-service

firebase:
  credentials-path: classpath:firebase-service-account.json
  enabled: false  # Set to true when FCM is configured
```

## Running the Service

### Prerequisites
- MongoDB running
- Kafka running
- Mission Service running (to publish events)

### Start Service
```bash
cd skillswap-service-notification
mvn spring-boot:run
```

### With Docker
```bash
docker-compose up -d mongodb kafka
mvn spring-boot:run
```

## Testing

### Test Kafka Consumer

1. Start Notification Service
2. Create a mission (Mission Service)
3. Check logs for event consumption
4. Check MongoDB for notification record

### Test FCM

1. Register FCM token from mobile app
2. Trigger an event (e.g., create mission)
3. Check mobile device for push notification
4. Check logs for FCM message ID

### Manual Notification Test

Use Kafka console producer:
```bash
docker exec -it skillswap-kafka kafka-console-producer \
  --topic mission-events \
  --bootstrap-server localhost:9092
```

Send test event:
```json
{
  "missionId": "uuid",
  "skillId": "uuid",
  "requesterId": "uuid",
  "helperId": "uuid",
  "eventType": "MISSION_CREATED",
  "missionTitle": "Test Mission",
  "creditAmount": 10,
  "timestamp": "2026-01-23T20:00:00Z"
}
```

## Error Handling

### Invalid FCM Token
- Token is automatically deactivated
- User needs to re-register token

### Kafka Consumer Failure
- Events are retried automatically
- Failed events logged for manual review

### MongoDB Connection Issues
- Service continues to consume events
- Notifications queued in memory (limited)

## Monitoring

### Kafka Consumer Lag
```bash
docker exec skillswap-kafka kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --describe \
  --group notification-service
```

### FCM Delivery Status
- Check `fcmSent` field in notifications
- Check `fcmMessageId` for tracking

### Health Check
```bash
curl http://localhost:8084/actuator/health
```

## Development

### Project Structure
```
src/main/java/com/skillswap/notification/
├── NotificationServiceApplication.java
├── model/
│   ├── Notification.java
│   └── FcmToken.java
├── dto/
│   ├── NotificationResponse.java
│   └── RegisterTokenRequest.java
├── enums/
│   ├── NotificationType.java
│   └── MissionEventType.java
├── repositories/
│   ├── NotificationRepository.java
│   └── FcmTokenRepository.java
├── services/
│   ├── NotificationService.java
│   └── FcmService.java
├── listeners/
│   └── MissionEventListener.java
├── controllers/
│   └── NotificationController.java
└── config/
    └── FirebaseConfig.java
```

## Security

- Authentication handled by API Gateway
- API Gateway adds X-User-Id header
- Service trusts X-User-Id header
- Users can only access their own notifications

## Future Enhancements

1. Email notifications
2. SMS notifications
3. Notification preferences (enable/disable types)
4. Notification scheduling
5. Rich notifications with images
6. Notification templates
7. Multi-language support
8. Notification analytics
