# SkillSwap Backoffice - Admin Panel

## 📋 Overview

SkillSwap Backoffice is an Angular-based Progressive Web Application (PWA) designed for platform administrators to manage users, skills, missions, partner places, and resolve disputes. The application provides comprehensive analytics, moderation tools, and system configuration capabilities.

## 🏗️ Architecture

### Application Architecture Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                   Angular Backoffice App                      │
│                                                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Pages     │  │  Services   │  │   Guards    │         │
│  │             │  │             │  │             │         │
│  │ - Dashboard │  │ - Auth      │  │ - Admin     │         │
│  │ - Users     │  │ - API       │  │ - Auth      │         │
│  │ - Skills    │  │ - WebSocket │  │             │         │
│  │ - Missions  │  │             │  │             │         │
│  │ - Disputes  │  │             │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│         │                │                 │                 │
│         └────────────────┴─────────────────┘                 │
│                          │                                   │
│                          ▼                                   │
│               ┌────────────────────┐                        │
│               │   HTTP Interceptor │                        │
│               │   (JWT Injection)  │                        │
│               └────────────────────┘                        │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
                ┌──────────────┐
                │ API Gateway  │
                │   :8080      │
                │  (Backend)   │
                └──────────────┘
```

### Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │Dashboard │  │  Users   │  │ Missions │  │ Disputes │   │
│  │Component │  │Component │  │Component │  │Component │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                         │
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Auth   │  │   API    │  │WebSocket │  │  State   │   │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                         │
┌─────────────────────────────────────────────────────────────┐
│                      HTTP Layer                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │   HTTP   │  │   JWT    │  │  Error   │                  │
│  │  Client  │  │Interceptor│  │ Handler  │                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Features

### 👤 User Management
**Purpose**: Manage platform users and their accounts

**Capabilities**:
- View all registered users with pagination
- Search users by name, email, phone number
- Filter users by:
  - Registration date
  - Phone verification status
  - Credit balance range
  - Helper Score range
  - Account status (active/suspended)
- View detailed user profile:
  - Personal information
  - Credit balance and transaction history
  - Helper Score and completed missions
  - Skills published
  - FCM tokens
  - Account creation date
- User actions:
  - Suspend/Activate account
  - Reset password
  - Adjust credit balance (with reason)
  - View transaction ledger
  - Send notification to user
- Export user data (CSV, Excel, JSON)
- GDPR compliance tools

### 🎯 Skill Management
**Purpose**: Moderate and manage published skills

**Capabilities**:
- View all published skills
- Search skills by title, category, owner
- Filter by:
  - Category
  - Active/Inactive status
  - Creation date
  - Geographic region
- Skill moderation:
  - Approve new skills
  - Reject inappropriate skills
  - Deactivate policy-violating skills
  - Edit skill details
  - Delete skills
- View skill statistics:
  - Total views
  - Mission requests
  - Completion rate
  - Average rating
- Geographic distribution map
- Category analytics
- Export skills data

### 📋 Mission Management
**Purpose**: Monitor and manage mission lifecycle

**Capabilities**:
- View all missions with status
- Filter by:
  - Status (PENDING, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED, REJECTED, DISPUTED)
  - Date range
  - Credit amount
  - Requester/Provider
- Mission details:
  - Requester and provider information
  - Skill details
  - Timeline (created, accepted, started, completed)
  - Credit amount
  - Meeting point
  - OTP validation status
  - Cancellation/rejection reason
- Mission actions:
  - Cancel mission (with refund)
  - Mark as disputed
  - View chat history
  - Export mission data
- Mission analytics:
  - Completion rate by category
  - Average mission duration
  - Popular skills
  - Revenue trends (credits transferred)
  - Geographic heat map

### 🏢 Partner Places Management
**Purpose**: Manage verified meeting locations

**Capabilities**:
- View all partner places
- Add new partner place:
  - Name and description
  - Address
  - GPS coordinates (map picker)
  - Category (café, workspace, library, park, etc.)
  - Contact information (phone, email)
  - Opening hours
  - Amenities (WiFi, parking, accessible, etc.)
  - Photos
- Edit existing places
- Activate/Deactivate places
- View place usage statistics:
  - Number of missions held
  - User ratings
  - Popular times
- Map view of all partner places
- Export places list
- Integration with mobile app

### ⚖️ Dispute Resolution
**Purpose**: Resolve conflicts between users

**Capabilities**:
- View all disputed missions
- Dispute details:
  - Mission information
  - Requester complaint
  - Provider response
  - Evidence (screenshots, messages)
  - Chat history
  - Timeline of events
- Resolution actions:
  - Refund requester (100%)
  - Credit provider (100%)
  - Split credits (50/50 or custom)
  - No refund (both at fault)
  - Suspend user (if policy violation)
  - Close dispute
- Add resolution notes
- Dispute history and outcomes
- Analytics:
  - Dispute rate by category
  - Common dispute reasons
  - Resolution time
  - User dispute history

### 📊 Analytics Dashboard
**Purpose**: Monitor platform health and performance

**Metrics**:
- **User Metrics**:
  - Total users
  - Active users (last 7/30 days)
  - New registrations (daily/weekly/monthly)
  - Phone verification rate
  - Average Helper Score
- **Skill Metrics**:
  - Total skills published
  - Active skills
  - Skills by category
  - Geographic distribution
  - Average skills per user
- **Mission Metrics**:
  - Total missions
  - Missions by status
  - Completion rate
  - Average mission duration
  - Average credit cost
  - Revenue (total credits transferred)
- **Platform Health**:
  - API response times
  - Error rates
  - Service uptime
  - Database performance

**Visualizations**:
- Line charts (user growth, revenue trends)
- Bar charts (missions by category, skills by region)
- Pie charts (mission status distribution)
- Heat maps (geographic activity)
- Tables (top users, popular skills)

**Export Options**:
- PDF reports
- Excel spreadsheets
- CSV data
- JSON data

### 🔔 Notification Management
**Purpose**: Send notifications to users

**Capabilities**:
- Send broadcast notifications:
  - Title and message
  - Target audience (all users, specific segment)
  - Schedule (immediate or future)
  - Priority (high, normal, low)
- Notification templates:
  - Welcome message
  - Feature announcement
  - Maintenance notice
  - Policy update
- View notification history:
  - Sent notifications
  - Delivery status
  - Open rate
  - Click-through rate
- Target specific user groups:
  - By location
  - By Helper Score
  - By credit balance
  - By activity level

### ⚙️ System Configuration
**Purpose**: Configure platform settings

**Settings**:
- **Credit System**:
  - Phone verification bonus
  - Minimum credit balance
  - Maximum credit per mission
  - Credit pricing (if monetized)
- **Mission Settings**:
  - OTP expiration time
  - Maximum mission duration
  - Cancellation policy
  - Auto-cancel timeout
- **Search Settings**:
  - Default search radius
  - Maximum search radius
  - Results per page
- **Helper Score Algorithm**:
  - Completion weight
  - Rating weight
  - Response time weight
  - Decay factor
- **Feature Flags**:
  - Enable/disable features
  - Beta features
  - Maintenance mode
- **API Rate Limits**:
  - Requests per minute
  - Burst limit
  - IP whitelist/blacklist
- **Email Templates**:
  - Welcome email
  - Password reset
  - Mission notifications

## 🛠️ Technology Stack

### Core Technologies
- **Angular**: 20.x (latest)
- **TypeScript**: 5.x
- **Node.js**: 18+
- **npm**: 9+

### Angular Features
- **Standalone Components**: No NgModules
- **Signals**: Reactive state management
- **Dependency Injection**: Service-based architecture
- **Routing**: Angular Router with guards
- **Forms**: Reactive Forms with validation

### UI Framework
- **Angular Material**: Material Design components
- **Flex Layout**: Responsive layout system
- **Custom Theming**: Brand colors and styles

### Data Visualization
- **Chart.js**: Charts and graphs
- **ngx-charts**: Angular chart components
- **Google Maps API**: Geographic visualization

### HTTP & State
- **HttpClient**: REST API communication
- **RxJS**: Reactive programming
- **Observables**: Async data streams
- **Interceptors**: JWT injection, error handling

### Development Tools
- **Angular CLI**: Project scaffolding and build
- **TypeScript Compiler**: Type checking
- **ESLint**: Code linting
- **Prettier**: Code formatting

## 📁 Project Structure

```
src/
├── app/
│   ├── core/                          # Core services and guards
│   │   ├── services/
│   │   │   ├── auth.service.ts       # Authentication service
│   │   │   ├── api.service.ts        # HTTP client wrapper
│   │   │   └── websocket.service.ts  # Real-time updates
│   │   ├── guards/
│   │   │   ├── auth.guard.ts         # Route protection
│   │   │   └── admin.guard.ts        # Admin role check
│   │   └── interceptors/
│   │       ├── jwt.interceptor.ts    # JWT token injection
│   │       └── error.interceptor.ts  # Error handling
│   │
│   ├── pages/                         # Feature pages
│   │   ├── login/
│   │   │   └── login.component.ts    # Admin login
│   │   ├── dashboard/
│   │   │   └── dashboard.component.ts # Analytics dashboard
│   │   ├── users/
│   │   │   └── users.component.ts    # User management
│   │   ├── skills/
│   │   │   └── skills.component.ts   # Skill moderation
│   │   ├── missions/
│   │   │   └── missions.component.ts # Mission monitoring
│   │   ├── partner-places/
│   │   │   └── partner-places.component.ts # Places management
│   │   ├── disputes/
│   │   │   └── disputes.component.ts # Dispute resolution
│   │   ├── notifications/
│   │   │   └── notifications.component.ts # Notification center
│   │   ├── settings/
│   │   │   └── settings.component.ts # System configuration
│   │   └── overview/
│   │       └── overview.component.ts # Platform overview
│   │
│   ├── shared/                        # Shared components
│   │   ├── components/
│   │   │   ├── header/
│   │   │   ├── sidebar/
│   │   │   ├── table/
│   │   │   ├── chart/
│   │   │   └── dialog/
│   │   ├── pipes/
│   │   │   ├── date-format.pipe.ts
│   │   │   └── currency.pipe.ts
│   │   └── models/
│   │       ├── user.model.ts
│   │       ├── skill.model.ts
│   │       ├── mission.model.ts
│   │       └── dispute.model.ts
│   │
│   ├── app.ts                         # Root component
│   ├── app.html                       # Root template
│   ├── app.css                        # Root styles
│   ├── app.routes.ts                  # Route configuration
│   └── app.config.ts                  # App configuration
│
├── assets/                            # Static assets
│   ├── images/
│   ├── icons/
│   └── styles/
│
├── environments/                      # Environment configs
│   ├── environment.ts                # Development
│   └── environment.prod.ts           # Production
│
├── index.html                         # HTML entry point
├── main.ts                            # TypeScript entry point
├── styles.css                         # Global styles
└── server.ts                          # SSR server (optional)
```

## 🔄 Data Flow

### Authentication Flow
```
1. Admin enters credentials
2. AuthService calls /api/auth/admin/login
3. Backend validates admin role
4. JWT token returned
5. Token stored in localStorage
6. JwtInterceptor adds token to all requests
7. AuthGuard protects admin routes
8. Navigate to Dashboard
```

### User Management Flow
```
1. Admin opens Users page
2. ApiService calls /api/admin/users
3. Backend returns paginated user list
4. Display users in table
5. Admin clicks "Suspend User"
6. Confirmation dialog shown
7. ApiService calls /api/admin/users/{id}/suspend
8. Backend updates user status
9. Table refreshes
10. Success notification shown
```

### Dispute Resolution Flow
```
1. Admin opens Disputes page
2. ApiService calls /api/admin/disputes
3. Display disputed missions
4. Admin clicks dispute to view details
5. Review evidence and chat history
6. Admin selects resolution action
7. ApiService calls /api/admin/disputes/{id}/resolve
8. Backend processes resolution:
   - Adjust credits
   - Update mission status
   - Send notifications
9. Dispute marked as resolved
10. Analytics updated
```

## 🔐 Security

### Authentication
- **Admin Login**: Separate endpoint from user login
- **Role-Based Access**: Only users with `ROLE_ADMIN` can access
- **JWT Tokens**: Secure token-based authentication
- **Token Expiration**: 1-hour session timeout
- **Refresh Tokens**: Automatic token refresh

### Authorization
- **Route Guards**: Protect all admin routes
- **Role Validation**: Backend validates admin role on every request
- **Action Logging**: All admin actions logged with timestamp and IP
- **Audit Trail**: Complete history of admin operations

### Data Protection
- **HTTPS Only**: All communication over TLS
- **CORS Configuration**: Restricted to admin domain
- **Input Validation**: Client and server-side validation
- **XSS Protection**: Angular's built-in sanitization
- **CSRF Protection**: Token-based CSRF prevention

### Two-Factor Authentication (Recommended)
- **TOTP**: Time-based one-time passwords
- **SMS**: Backup authentication method
- **Recovery Codes**: Emergency access

## 🚀 Setup & Installation

### Prerequisites
- Node.js 18+
- npm 9+
- Angular CLI 20+
- Backend services running

### 1. Install Angular CLI
```bash
npm install -g @angular/cli@20
```

### 2. Install Dependencies
```bash
cd skillswap-backoffice
npm install
```

### 3. Configure Environment

Edit `src/environments/environment.ts`:

```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api',
  googleMapsApiKey: 'YOUR_GOOGLE_MAPS_API_KEY',
  wsUrl: 'ws://localhost:8080/ws'
};
```

Edit `src/environments/environment.prod.ts`:

```typescript
export const environment = {
  production: true,
  apiUrl: 'https://api.skillswap.com/api',
  googleMapsApiKey: 'YOUR_GOOGLE_MAPS_API_KEY',
  wsUrl: 'wss://api.skillswap.com/ws'
};
```

### 4. Run Development Server
```bash
ng serve
```

Navigate to `http://localhost:4200`

### 5. Build for Production
```bash
ng build --configuration production
```

Output in `dist/skillswap-backoffice/`

## 🧪 Testing

### Unit Tests
```bash
# Run unit tests
ng test

# Run with coverage
ng test --code-coverage

# Run in headless mode
ng test --browsers=ChromeHeadless
```

### End-to-End Tests
```bash
# Run e2e tests
ng e2e
```

### Linting
```bash
# Run ESLint
ng lint

# Fix linting errors
ng lint --fix
```

## 🐛 Troubleshooting

### Cannot Connect to Backend
**Problem**: API calls fail with CORS error

**Solutions**:
1. Verify backend is running
2. Check API URL in environment file
3. Ensure CORS is configured for admin domain
4. Check browser console for errors

### Authentication Fails
**Problem**: Admin login returns 401

**Solutions**:
1. Verify admin user exists in database
2. Check user has `ROLE_ADMIN` role
3. Verify JWT secret matches backend
4. Check token expiration time

### Charts Not Displaying
**Problem**: Dashboard charts are blank

**Solutions**:
1. Check Chart.js is installed
2. Verify API returns data in correct format
3. Check browser console for errors
4. Ensure data is not empty

## 📊 Performance Optimization

### Lazy Loading
- Load feature modules on demand
- Reduce initial bundle size
- Faster first page load

### Change Detection
- Use OnPush strategy
- Minimize unnecessary re-renders
- Optimize component tree

### HTTP Optimization
- Cache API responses
- Implement pagination
- Use HTTP interceptors
- Debounce search queries

### Build Optimization
```bash
# Production build with optimizations
ng build --configuration production --optimization --build-optimizer
```

## 🚢 Deployment

### Build for Production
```bash
ng build --configuration production
```

### Deploy to Nginx
```nginx
server {
    listen 80;
    server_name admin.skillswap.com;
    
    root /var/www/skillswap-backoffice;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://backend:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Deploy to Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
firebase init hosting

# Deploy
firebase deploy --only hosting
```

### Deploy to AWS S3 + CloudFront
```bash
# Build
ng build --configuration production

# Upload to S3
aws s3 sync dist/skillswap-backoffice/ s3://admin.skillswap.com

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/*"
```

## 📈 Future Enhancements

### Phase 1 (Q1 2026)
- [ ] Advanced analytics with ML insights
- [ ] Automated moderation with AI
- [ ] Bulk operations (mass email, credit adjustments)
- [ ] Custom report builder
- [ ] Real-time dashboard updates

### Phase 2 (Q2 2026)
- [ ] Mobile admin app (Flutter)
- [ ] Real-time chat support
- [ ] Automated dispute resolution
- [ ] A/B testing framework
- [ ] Advanced fraud detection

### Phase 3 (Q3 2026)
- [ ] Multi-language admin panel
- [ ] White-label configuration
- [ ] API marketplace management
- [ ] Advanced user segmentation
- [ ] Predictive analytics

## 📚 Resources

### Documentation
- [Angular Documentation](https://angular.io/docs)
- [Angular Material](https://material.angular.io)
- [RxJS Documentation](https://rxjs.dev)
- [TypeScript Handbook](https://www.typescriptlang.org/docs)

### Tutorials
- [Angular Tutorial](https://angular.io/tutorial)
- [Angular Material Getting Started](https://material.angular.io/guide/getting-started)
- [RxJS Operators](https://rxjs.dev/guide/operators)

## 🤝 Contributing

### Code Style
- Follow [Angular Style Guide](https://angular.io/guide/styleguide)
- Use TypeScript strict mode
- Write meaningful component names
- Add JSDoc comments for public APIs

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature

# Commit changes
git add .
git commit -m "feat: add new feature"

# Push to remote
git push origin feature/new-feature
```

## 📄 License

Private Project - All Rights Reserved

---

**Version**: 1.0.0  
**Framework**: Angular 20+  
**Access**: Admin users only  
**Status**: In Development  
**Last Updated**: January 2026
