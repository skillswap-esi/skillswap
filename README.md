# SkillSwap Platform

A comprehensive skill-sharing platform that connects people to exchange skills and knowledge. Built with microservices architecture, featuring a Flutter mobile app for users and an Angular admin panel for management.

## 🌟 Features

### For Users (Mobile App)
- **Skill Discovery**: Browse and search skills by category and location
- **Interactive Map**: Find skills near you with real-time geolocation
- **Mission System**: Request skills, accept missions, and complete exchanges
- **Real-time Chat**: Communicate with skill providers before and during missions
- **OTP Verification**: Secure mission completion with one-time passwords
- **Phone Verification**: Verify your account with Firebase OTP
- **Credits System**: Earn and spend credits for skill exchanges
- **Push Notifications**: Stay updated on mission requests and messages
- **Profile Management**: Manage your skills, missions, and account

### For Admins (Backoffice)
- **User Management**: View and manage user accounts
- **Dispute Resolution**: Handle conflicts between users
- **Analytics Dashboard**: Monitor platform activity and metrics
- **Partner Places**: Manage meeting locations for skill exchanges

## 📁 Project Structure

```
SkillSwap/
├── skillswap-backend/          # Java Spring Boot Microservices
│   ├── skillswap-api-gateway/      # API Gateway (Port 8080)
│   ├── skillswap-service-user/     # User Service (Port 8081)
│   ├── skillswap-service-skill/    # Skill Service (Port 8082)
│   ├── skillswap-service-mission/  # Mission Service (Port 8083)
│   ├── skillswap-service-notification/ # Notification Service (Port 8084)
│   ├── skillswap-common/           # Shared utilities
│   └── docker-compose.yml          # Infrastructure setup
├── skillswap_front_mobile/     # Flutter Mobile App
│   ├── lib/                        # Application code
│   ├── android/                    # Android configuration
│   ├── ios/                        # iOS configuration
│   └── pubspec.yaml                # Dependencies
├── skillswap-backoffice/       # Angular Admin Panel
│   ├── src/                        # Application code
│   └── angular.json                # Angular configuration
└── skillswap-deployment/       # Kubernetes Deployment
    └── kubernetes/                 # K8s manifests
```

## 🚀 Quick Start

### Prerequisites
- **Java 17+** (for backend services)
- **Maven 3.8+** (for building backend)
- **Node.js 18+** (for backoffice)
- **Flutter 3.x** (for mobile app)
- **Docker & Docker Compose** (for infrastructure)
- **MongoDB** (database for skills and missions)
- **PostgreSQL** (database for users)
- **Kafka & Zookeeper** (event streaming)
- **Redis** (caching)
- **Firebase Account** (authentication, Firestore, FCM)

### 1. Clone the Repository
```bash
git clone <repository-url>
cd SkillSwap
```

### 2. Configure Firebase
1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication (Email/Password and Phone)
3. Enable Firestore Database
4. Enable Cloud Messaging (FCM)
5. Download service account JSON files:
   - Place in `skillswap-backend/skillswap-service-user/src/main/resources/firebase-service-account.json`
   - Place in `skillswap-backend/skillswap-service-notification/src/main/resources/firebase-service-account.json`
6. Download `google-services.json` for Android and place in `skillswap_front_mobile/android/app/`
7. Download `GoogleService-Info.plist` for iOS and place in `skillswap_front_mobile/ios/Runner/`

### 3. Start Infrastructure Services
```bash
cd skillswap-backend
docker-compose up -d
```

This starts:
- MongoDB (Port 27017)
- PostgreSQL (Port 5432)
- Kafka (Port 9092)
- Zookeeper (Port 2181)
- Redis (Port 6379)

### 4. Configure Environment Variables

Create `.env` files in each service directory (see `.env.example` files):

**User Service** (`skillswap-service-user/.env`):
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=skillswap_users
DB_USERNAME=postgres
DB_PASSWORD=postgres
JWT_SECRET=your-secret-key
FIREBASE_PROJECT_ID=your-project-id
```

**Skill Service** (`skillswap-service-skill/.env`):
```env
MONGODB_URI=mongodb://localhost:27017/skillswap_skills
```

**Mission Service** (`skillswap-service-mission/.env`):
```env
MONGODB_URI=mongodb://localhost:27017/skillswap_missions
KAFKA_BOOTSTRAP_SERVERS=localhost:9092
SKILL_SERVICE_URL=http://localhost:8082
```

### 5. Build and Start Backend Services

**Option A: Using Maven (Development)**
```bash
# Terminal 1 - User Service
cd skillswap-backend/skillswap-service-user
mvn clean install
mvn spring-boot:run

# Terminal 2 - Skill Service
cd skillswap-backend/skillswap-service-skill
mvn clean install
mvn spring-boot:run

# Terminal 3 - Mission Service
cd skillswap-backend/skillswap-service-mission
mvn clean install
mvn spring-boot:run

# Terminal 4 - Notification Service
cd skillswap-backend/skillswap-service-notification
mvn clean install
mvn spring-boot:run

# Terminal 5 - API Gateway
cd skillswap-backend/skillswap-api-gateway
mvn clean install
mvn spring-boot:run
```

**Option B: Using Docker Compose (Production)**
```bash
cd skillswap-backend
docker-compose up --build
```

### 6. Start Mobile App

**Configure API endpoint** in `skillswap_front_mobile/lib/core/api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:8080'; // Use your machine's IP
```

**Run the app**:
```bash
cd skillswap_front_mobile
flutter pub get
flutter run
```

### 7. Start Backoffice (Optional)
```bash
cd skillswap-backoffice
npm install
npm start
```

Access at: http://localhost:4200

## 📚 Documentation

- **Backend**: [skillswap-backend/README.md](skillswap-backend/README.md)
- **Mobile**: [skillswap_front_mobile/README.md](skillswap_front_mobile/README.md)
- **Backoffice**: [skillswap-backoffice/README.md](skillswap-backoffice/README.md)

## 🔗 API Documentation (Swagger)

Once services are running, access interactive API documentation:

- **User Service**: http://localhost:8081/swagger-ui.html
- **Skill Service**: http://localhost:8082/swagger-ui.html
- **Mission Service**: http://localhost:8083/swagger-ui.html
- **Notification Service**: http://localhost:8084/swagger-ui.html

Each Swagger UI provides:
- Complete endpoint documentation
- Request/response schemas with examples
- Try-it-out functionality for testing
- Model definitions
- Authentication requirements

## 🏗️ Architecture

### System Overview
```
┌─────────────────┐
│  Mobile App     │
│  (Flutter)      │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  API Gateway    │ ← JWT Authentication
│  (Port 8080)    │
└────────┬────────┘
         │
    ┌────┴────┬────────┬────────┐
    ↓         ↓        ↓        ↓
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│ User   │ │ Skill  │ │Mission │ │Notif.  │
│Service │ │Service │ │Service │ │Service │
│ :8081  │ │ :8082  │ │ :8083  │ │ :8084  │
└───┬────┘ └───┬────┘ └───┬────┘ └───┬────┘
    │          │          │          │
    ↓          ↓          ↓          ↓
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│Postgres│ │MongoDB │ │MongoDB │ │Firebase│
│        │ │        │ │ Kafka  │ │  FCM   │
└────────┘ └────────┘ └────────┘ └────────┘
```

### Microservices

#### API Gateway (Port 8080)
- Routes all client requests to appropriate services
- JWT token validation and authentication
- Request/response logging
- CORS configuration

#### User Service (Port 8081)
- User registration and authentication
- Profile management
- Credits system (earn/spend)
- Phone verification
- PostgreSQL database

#### Skill Service (Port 8082)
- Skill CRUD operations
- Geolocation-based search
- Category filtering
- Skill ownership management
- MongoDB database

#### Mission Service (Port 8083)
- Mission lifecycle management (PENDING → ACCEPTED → IN_PROGRESS → COMPLETED)
- OTP generation and validation
- Mission requests and acceptance
- Partner places management
- Kafka event publishing
- MongoDB database

#### Notification Service (Port 8084)
- Push notifications via Firebase Cloud Messaging
- Mission event listeners (Kafka)
- Real-time notifications for mission updates

### Mobile App Architecture

```
┌─────────────────────────────────────┐
│           Presentation              │
│  ┌──────────┐  ┌──────────┐        │
│  │  Pages   │  │ Widgets  │        │
│  └──────────┘  └──────────┘        │
├─────────────────────────────────────┤
│            Business Logic           │
│  ┌──────────┐  ┌──────────┐        │
│  │Providers │  │ Services │        │
│  └──────────┘  └──────────┘        │
├─────────────────────────────────────┤
│              Data Layer             │
│  ┌──────────┐  ┌──────────┐        │
│  │  Models  │  │   API    │        │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘
```

**Key Features:**
- **State Management**: Provider pattern
- **Authentication**: Firebase Auth with JWT
- **Real-time Chat**: Firestore
- **Push Notifications**: FCM
- **Maps**: OpenStreetMap with flutter_map
- **HTTP Client**: Custom service layer with error handling

## 🔧 Technology Stack

### Backend
- **Framework**: Spring Boot 3.3.4, Java 17
- **Databases**: 
  - PostgreSQL (User data)
  - MongoDB (Skills, Missions)
  - Redis (Caching)
- **Messaging**: Apache Kafka, Zookeeper
- **Authentication**: JWT, Firebase Admin SDK
- **API Documentation**: Swagger/OpenAPI 3.0
- **Build Tool**: Maven 3.8+
- **Containerization**: Docker, Docker Compose

### Mobile App
- **Framework**: Flutter 3.x, Dart 3.x
- **State Management**: Provider
- **Authentication**: Firebase Auth
- **Database**: Firestore (real-time chat)
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Maps**: flutter_map, OpenStreetMap
- **HTTP Client**: http package
- **Geolocation**: geolocator
- **Platforms**: Android, iOS

### Backoffice
- **Framework**: Angular 20
- **Language**: TypeScript 5.x
- **Architecture**: Standalone Components
- **HTTP**: HttpClient, RxJS
- **Routing**: Angular Router
- **Build Tool**: Angular CLI

### DevOps & Deployment
- **Containerization**: Docker
- **Orchestration**: Kubernetes (optional)
- **CI/CD**: Docker Compose
- **Monitoring**: Spring Boot Actuator
- **Logging**: SLF4J, Logback

## 🔐 Security

### Authentication Flow
1. User registers/logs in via mobile app
2. Firebase Authentication validates credentials
3. Backend receives Firebase ID token
4. Backend validates token with Firebase Admin SDK
5. Backend generates JWT for API access
6. JWT included in all subsequent API requests

### Authorization
- **JWT Tokens**: Secure API access
- **Firebase Rules**: Firestore security
- **Role-based Access**: Admin vs User permissions
- **OTP Verification**: Secure mission completion

## 📱 User Flow

### Complete Mission Flow
1. **Discover**: User browses skills on map or list
2. **Chat**: User chats with skill owner before requesting
3. **Request**: User creates mission request with details
4. **Accept**: Skill owner reviews and accepts/rejects
5. **Start**: Both parties start the mission
6. **Complete**: 
   - Provider generates OTP
   - Requester validates OTP
   - Mission marked as completed
   - Credits transferred

### Chat Flow
- Users can chat BEFORE creating a mission
- Chat continues during mission
- Real-time messaging via Firestore
- Message history preserved

## 🛠️ Development

### Backend Development
```bash
# Build all services
cd skillswap-backend
mvn clean install

# Run specific service
cd skillswap-service-user
mvn spring-boot:run

# Run tests
mvn test

# Package for deployment
mvn package -DskipTests
```

### Mobile Development
```bash
# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Run tests
flutter test
```

### Backoffice Development
```bash
# Install dependencies
npm install

# Start dev server
npm start

# Build for production
npm run build

# Run tests
npm test
```

## 🐛 Troubleshooting

### Common Issues

#### Backend Services Won't Start
- **Check ports**: Ensure 8080-8084 are available
- **Check databases**: Verify MongoDB and PostgreSQL are running
- **Check Kafka**: Ensure Kafka and Zookeeper are running
- **Check logs**: Look for errors in console output

#### Mobile App Can't Connect
- **Check API URL**: Update `api_config.dart` with correct IP
- **Check network**: Ensure device/emulator can reach backend
- **Check Firebase**: Verify Firebase configuration files are present
- **Check permissions**: Ensure location and notification permissions granted

#### Firestore Index Missing
- Click the link in the error message to create index
- Or deploy indexes: `firebase deploy --only firestore:indexes`
- Wait 5-10 minutes for index to build

#### Mission Accept Fails
- **Verify skill exists**: Check MongoDB skills collection
- **Verify ownership**: Ensure user owns the skill
- **Check logs**: Look for detailed error in mission service logs
- **Clean data**: Delete orphaned missions and recreate

### Database Cleanup
```bash
# MongoDB - Clean orphaned missions
mongo
use skillswap_missions
db.missions.deleteMany({ status: "PENDING" })

# MongoDB - Clean all missions
db.missions.deleteMany({})

# MongoDB - Clean all skills
use skillswap_skills
db.skills.deleteMany({})
```

## 📊 Monitoring & Logs

### Service Health Checks
- User Service: http://localhost:8081/actuator/health
- Skill Service: http://localhost:8082/actuator/health
- Mission Service: http://localhost:8083/actuator/health
- Notification Service: http://localhost:8084/actuator/health

### Logs Location
- **Backend**: Console output or `logs/` directory
- **Mobile**: Flutter console or device logs
- **Docker**: `docker-compose logs -f <service-name>`

## 🚢 Deployment

### Docker Compose (Recommended for Development)
```bash
cd skillswap-backend
docker-compose up --build -d
```

### Kubernetes (Production)
```bash
cd skillswap-deployment/kubernetes
./deploy-all.sh
```

See [skillswap-deployment/kubernetes/README.md](skillswap-deployment/kubernetes/README.md) for details.

## 📈 Performance Optimization

- **Redis Caching**: Frequently accessed data cached
- **Database Indexing**: Geospatial indexes for location queries
- **Lazy Loading**: Mobile app loads data on demand
- **Image Optimization**: Compressed images for faster loading
- **Connection Pooling**: Efficient database connections

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 Additional Documentation

- **Backend API**: [skillswap-backend/README.md](skillswap-backend/README.md)
- **Mobile App**: [skillswap_front_mobile/README.md](skillswap_front_mobile/README.md)
- **Backoffice**: [skillswap-backoffice/README.md](skillswap-backoffice/README.md)
- **Kubernetes**: [skillswap-deployment/kubernetes/README.md](skillswap-deployment/kubernetes/README.md)
- **Mission Flow**: [MISSIONS_AND_OTP_FLOW_UPDATE.md](MISSIONS_AND_OTP_FLOW_UPDATE.md)
- **Recent Fixes**: [FIXES_SUMMARY.md](FIXES_SUMMARY.md)

## 📝 License

Private Project - All Rights Reserved

---

**Built with ❤️ by the SkillSwap Team**
