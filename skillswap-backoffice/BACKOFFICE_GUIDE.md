# SkillSwap Backoffice Guide

Angular-based admin panel for managing SkillSwap platform.

## Features

- 🔐 **Admin Login** - Secure authentication for administrators
- 👥 **User Management** - View all registered users with stats
- 📍 **Partner Places** - Add, edit, and manage partner meeting locations

## Quick Start

### Prerequisites

- Node.js 18+ and npm
- Backend services running (API Gateway on port 8080)

### Installation

```bash
cd skillswap-backoffice
npm install
```

### Development Server

```bash
npm start
```

Navigate to `http://localhost:4200`

### Build for Production

```bash
npm run build
```

## Admin Credentials

**Email**: `admin@skillswap.com`  
**Password**: `Admin123!`

## Pages

### 1. Login Page
- Simple authentication form
- Demo credentials displayed
- Redirects to dashboard on success

### 2. Dashboard
- Navigation sidebar
- User management
- Partner places management

### 3. Users Page
- View all registered users
- Display user statistics:
  - Total users
  - Total credits in system
  - Average helper score
- User details table with:
  - Name, email, phone
  - Credits balance
  - Helper score
  - Role

### 4. Partner Places Page
- View all partner meeting locations
- Add new partner places
- Edit existing places
- Delete places
- Form fields:
  - Name, type, address, city
  - Latitude, longitude
  - Phone number, description
  - Active status

## API Integration

The backoffice connects to:

- **User Service**: `GET /api/users` - Fetch all users
- **Mission Service**: 
  - `GET /api/missions/partner-places` - List places
  - `POST /api/missions/partner-places` - Create place
  - `PUT /api/missions/partner-places/{id}` - Update place
  - `DELETE /api/missions/partner-places/{id}` - Delete place

## Architecture

```
src/
├── app/
│   ├── guards/
│   │   └── auth.guard.ts          # Route protection
│   ├── pages/
│   │   ├── login/                 # Login page
│   │   ├── dashboard/             # Main dashboard
│   │   ├── users/                 # Users management
│   │   └── partner-places/        # Partner places management
│   ├── services/
│   │   ├── auth.service.ts        # Authentication logic
│   │   └── api.service.ts         # Backend API calls
│   ├── app.routes.ts              # Route configuration
│   └── app.config.ts              # App configuration
```

## Screenshots

### Login Page
- Clean, modern design
- Gradient background
- Demo credentials shown

### Users Dashboard
- Statistics cards
- Sortable table
- Real-time data

### Partner Places
- Grid layout
- Add/Edit forms
- Active status badges

## Development

### Add New Page

1. Create component in `src/app/pages/`
2. Add route in `app.routes.ts`
3. Add navigation link in dashboard

### Add New API Endpoint

1. Add method in `api.service.ts`
2. Define interface for data model
3. Use in component with RxJS observables

## Production Deployment

1. Update API URL in `api.service.ts`
2. Build: `npm run build`
3. Deploy `dist/` folder to web server
4. Configure CORS on backend

## Security Notes

- Change admin credentials in production
- Implement proper JWT authentication
- Add role-based access control
- Enable HTTPS
- Implement rate limiting

## Troubleshooting

### Cannot connect to backend
- Ensure backend services are running
- Check API URL in `api.service.ts`
- Verify CORS configuration

### Login not working
- Check credentials match `auth.service.ts`
- Clear localStorage
- Check browser console for errors

### Data not loading
- Verify backend is running on port 8080
- Check network tab in browser DevTools
- Ensure API endpoints are correct

---

**Version**: 1.0.0  
**Last Updated**: January 24, 2026
