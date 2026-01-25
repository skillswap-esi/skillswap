# SkillSwap Backoffice - Admin Panel Documentation

## Overview

Angular PWA for SkillSwap platform administration - manage users, skills, missions, partner places, and resolve disputes.

## Admin Features

### 👤 User Management
- View all registered users
- Search users by name, email, phone
- View user details:
  - Profile information
  - Credit balance
  - Helper Score
  - Phone verification status
  - Registration date
- Manage user accounts:
  - Suspend/Activate accounts
  - Reset passwords
  - Adjust credit balance
  - View transaction history
- Export user data

### 🎯 Skill Management
- View all published skills
- Search skills by:
  - Title
  - Category
  - Owner
  - Location
- Moderate skills:
  - Approve/Reject new skills
  - Deactivate inappropriate skills
  - Edit skill details
  - View skill statistics
- Skill analytics:
  - Most popular categories
  - Geographic distribution
  - Active vs inactive skills

### 📋 Mission Management
- View all missions
- Filter by status:
  - PENDING
  - ACCEPTED
  - IN_PROGRESS
  - COMPLETED
  - CANCELLED
  - REJECTED
  - DISPUTED
- Mission details:
  - Requester and provider info
  - Skill details
  - Timeline (created, accepted, completed)
  - Credit amount
  - Meeting point
  - OTP validation status
- Mission analytics:
  - Completion rate
  - Average duration
  - Popular skills
  - Revenue (credits transferred)

### 🏢 Partner Places Management
- Add new partner places:
  - Name
  - Address
  - GPS coordinates
  - Category (café, workspace, library, etc.)
  - Contact information
  - Opening hours
  - Amenities
- Edit existing places
- Activate/Deactivate places
- View place usage statistics
- Map view of all partner places
- Export places list

### ⚖️ Dispute Resolution
- View disputed missions
- Dispute details:
  - Mission information
  - Requester complaint
  - Provider response
  - Chat history
  - Evidence (screenshots, messages)
- Resolution actions:
  - Refund requester
  - Credit provider
  - Split credits
  - Suspend user
  - Close dispute
- Dispute history and outcomes

### 📊 Analytics Dashboard
- Platform statistics:
  - Total users
  - Active users (last 30 days)
  - Total skills published
  - Total missions completed
  - Total credits in circulation
- Charts and graphs:
  - User growth over time
  - Mission completion trends
  - Popular skill categories
  - Geographic heat map
  - Revenue trends
- Export reports (PDF, Excel)

### 🔔 Notification Management
- Send broadcast notifications
- Schedule announcements
- View notification history
- Notification templates
- Target specific user groups

### ⚙️ System Configuration
- Platform settings:
  - Credit pricing
  - OTP expiration time
  - Search radius limits
  - Minimum credit balance
  - Helper Score algorithm
- Feature flags:
  - Enable/disable features
  - Maintenance mode
  - Beta features
- API rate limits
- Email templates

## User Scenarios for Admin

### A1 - Manage Partner Places
**Actor:** Admin  
**Objective:** Add and manage public meeting places

**Flow:**
1. Admin logs into backoffice
2. Navigates to "Partner Places"
3. Clicks "Add New Place"
4. Fills form:
   - Name: "Café Central"
   - Address: "123 Main St, City"
   - Category: "Café"
   - GPS: Click on map or enter coordinates
   - Contact: phone, email
   - Hours: "8:00 - 22:00"
   - Amenities: WiFi, Parking, Accessible
5. Uploads photos
6. Clicks "Save"
7. Place appears in mobile app for users

**Result:** Users can select this place for missions

### A2 - Resolve Dispute
**Actor:** Admin  
**Objective:** Resolve mission dispute fairly

**Flow:**
1. Admin receives dispute notification
2. Opens "Disputes" section
3. Views disputed mission:
   - Requester claims: "Service not provided"
   - Provider claims: "Requester didn't show up"
4. Reviews evidence:
   - Chat messages
   - GPS check-in data
   - OTP validation attempts
5. Makes decision:
   - Option A: Refund requester (100%)
   - Option B: Credit provider (100%)
   - Option C: Split 50/50
   - Option D: No refund (both at fault)
6. Adds resolution notes
7. Clicks "Resolve"
8. Both users notified of decision

**Result:** Dispute closed, credits adjusted

### A3 - Moderate Inappropriate Skill
**Actor:** Admin  
**Objective:** Remove policy-violating skill

**Flow:**
1. Admin receives user report
2. Opens "Skills" → "Reported"
3. Views skill details
4. Determines violation:
   - Inappropriate content
   - Illegal service
   - Spam
5. Actions:
   - Deactivate skill
   - Send warning to owner
   - Suspend user (if repeat offender)
6. Adds moderation note
7. Clicks "Take Action"

**Result:** Skill removed, user notified

### A4 - Adjust User Credits
**Actor:** Admin  
**Objective:** Manually adjust credits for support case

**Flow:**
1. User contacts support about missing credits
2. Admin searches user by email
3. Views transaction history
4. Confirms issue (payment processed but credits not added)
5. Clicks "Adjust Credits"
6. Enters amount: +50
7. Adds reason: "Payment reconciliation"
8. Clicks "Apply"
9. User receives notification

**Result:** Credits corrected, user satisfied

### A5 - View Platform Analytics
**Actor:** Admin  
**Objective:** Monitor platform health

**Flow:**
1. Admin opens dashboard
2. Views key metrics:
   - 1,234 total users (+15% this month)
   - 567 active skills
   - 89 missions this week
   - 4.2 average Helper Score
3. Checks charts:
   - User growth trending up
   - "Informatique" most popular category
   - Peak usage: weekends
4. Identifies issues:
   - Low completion rate in "Jardinage"
   - High dispute rate in one region
5. Takes action:
   - Investigate regional issues
   - Promote underused categories

**Result:** Data-driven platform improvements

### A6 - Send Broadcast Notification
**Actor:** Admin  
**Objective:** Announce new feature

**Flow:**
1. Admin opens "Notifications"
2. Clicks "New Broadcast"
3. Fills form:
   - Title: "New Feature: Partner Places!"
   - Message: "You can now meet at verified cafés and workspaces"
   - Target: All users
   - Schedule: Immediate
4. Previews notification
5. Clicks "Send"
6. Notification sent to all users

**Result:** Users informed of new feature

### A7 - Export User Data (GDPR)
**Actor:** Admin  
**Objective:** Provide user data for GDPR request

**Flow:**
1. User requests data export
2. Admin searches user
3. Clicks "Export Data"
4. System generates:
   - Profile information
   - Skills published
   - Missions history
   - Chat messages
   - Transactions
5. Downloads ZIP file
6. Sends to user securely

**Result:** GDPR compliance

### A8 - Configure Platform Settings
**Actor:** Admin  
**Objective:** Update OTP expiration time

**Flow:**
1. Admin opens "Settings"
2. Navigates to "Mission Settings"
3. Finds "OTP Expiration"
4. Changes from 5 minutes to 10 minutes
5. Adds change reason
6. Clicks "Save"
7. System updates configuration
8. All services reload settings

**Result:** OTP now valid for 10 minutes

## Technical Stack

### Frontend
- **Framework:** Angular 17+
- **UI Library:** Angular Material
- **Charts:** Chart.js / ngx-charts
- **Maps:** Google Maps API
- **State Management:** RxJS
- **Forms:** Reactive Forms

### Backend Integration
- **API:** REST via API Gateway (port 8080)
- **Authentication:** JWT tokens
- **Real-time:** WebSocket for live updates
- **File Upload:** Multipart form data

## Project Structure

```
src/
├── app/
│   ├── core/
│   │   ├── services/
│   │   │   ├── auth.service.ts
│   │   │   ├── api.service.ts
│   │   │   └── websocket.service.ts
│   │   ├── guards/
│   │   │   └── admin.guard.ts
│   │   └── interceptors/
│   │       └── jwt.interceptor.ts
│   ├── features/
│   │   ├── dashboard/
│   │   ├── users/
│   │   ├── skills/
│   │   ├── missions/
│   │   ├── partner-places/
│   │   ├── disputes/
│   │   ├── notifications/
│   │   └── settings/
│   ├── shared/
│   │   ├── components/
│   │   ├── pipes/
│   │   └── models/
│   └── app.routes.ts
├── assets/
└── environments/
```

## API Endpoints (Admin)

### Users
```
GET    /api/admin/users
GET    /api/admin/users/{id}
PUT    /api/admin/users/{id}/suspend
PUT    /api/admin/users/{id}/activate
POST   /api/admin/users/{id}/credits
GET    /api/admin/users/{id}/transactions
GET    /api/admin/users/export
```

### Skills
```
GET    /api/admin/skills
GET    /api/admin/skills/reported
PUT    /api/admin/skills/{id}/moderate
DELETE /api/admin/skills/{id}
GET    /api/admin/skills/analytics
```

### Missions
```
GET    /api/admin/missions
GET    /api/admin/missions/{id}
GET    /api/admin/missions/analytics
GET    /api/admin/missions/export
```

### Partner Places
```
GET    /api/admin/partner-places
POST   /api/admin/partner-places
PUT    /api/admin/partner-places/{id}
DELETE /api/admin/partner-places/{id}
GET    /api/admin/partner-places/{id}/stats
```

### Disputes
```
GET    /api/admin/disputes
GET    /api/admin/disputes/{id}
POST   /api/admin/disputes/{id}/resolve
GET    /api/admin/disputes/stats
```

### Notifications
```
POST   /api/admin/notifications/broadcast
GET    /api/admin/notifications/history
POST   /api/admin/notifications/schedule
```

### Analytics
```
GET    /api/admin/analytics/dashboard
GET    /api/admin/analytics/users
GET    /api/admin/analytics/missions
GET    /api/admin/analytics/revenue
GET    /api/admin/analytics/export
```

### Settings
```
GET    /api/admin/settings
PUT    /api/admin/settings
GET    /api/admin/settings/feature-flags
PUT    /api/admin/settings/feature-flags
```

## Setup & Development

### 1. Install Dependencies
```bash
cd skillswap-backoffice
npm install
```

### 2. Configure Environment
Edit `src/environments/environment.ts`:
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api',
  googleMapsApiKey: 'YOUR_API_KEY'
};
```

### 3. Run Development Server
```bash
ng serve
```
Navigate to `http://localhost:4200`

### 4. Build for Production
```bash
ng build --configuration production
```

## Security

### Admin Authentication
- Separate admin login endpoint
- Role-based access control (RBAC)
- Admin users have `ROLE_ADMIN`
- JWT tokens with admin claims
- Session timeout: 1 hour

### Authorization
- All admin endpoints require `ROLE_ADMIN`
- Audit log for all admin actions
- IP whitelist for admin access (optional)
- Two-factor authentication (2FA) recommended

### Data Protection
- Sensitive data masked in UI
- Secure file uploads
- HTTPS only in production
- CORS configured for admin domain

## Monitoring

### Admin Activity Log
- Track all admin actions:
  - User modifications
  - Skill moderation
  - Dispute resolutions
  - Credit adjustments
  - Setting changes
- Log includes:
  - Admin user ID
  - Action type
  - Timestamp
  - IP address
  - Changes made

### System Health
- Service status indicators
- API response times
- Error rates
- Database connection status
- Kafka/Redis status

## Future Features

### Phase 1
- [ ] Advanced analytics with ML insights
- [ ] Automated moderation with AI
- [ ] Bulk operations (mass email, credit adjustments)
- [ ] Custom report builder

### Phase 2
- [ ] Mobile admin app
- [ ] Real-time chat support
- [ ] Automated dispute resolution
- [ ] A/B testing framework

### Phase 3
- [ ] Multi-language admin panel
- [ ] White-label configuration
- [ ] API marketplace management
- [ ] Advanced fraud detection

## Support

For admin issues:
1. Check admin user has `ROLE_ADMIN`
2. Verify JWT token is valid
3. Check API Gateway logs
4. Review audit logs
5. Contact system administrator

---

**Version:** 1.0.0  
**Framework:** Angular 17+  
**Access:** Admin users only  
**Status:** In Development
