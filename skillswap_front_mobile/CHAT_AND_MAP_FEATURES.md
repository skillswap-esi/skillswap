# Chat & Map Picker Features - Implementation Guide

## 🎉 New Features Added

### 1. Real-Time Chat (Firestore)
- **Technology**: Firebase Cloud Firestore
- **Purpose**: Enable requester and provider to discuss mission details before booking
- **Features**:
  - Real-time messaging
  - Message history
  - Read receipts
  - Automatic thread creation
  - Unread message count

### 2. Interactive Map Picker (OpenStreetMap)
- **Technology**: Flutter Map with OpenStreetMap tiles (FREE, no API key required)
- **Purpose**: Select precise meeting points for missions
- **Features**:
  - Tap anywhere on map to select location
  - Current location button
  - Partner place selection (cafés, coworking spaces)
  - Visual markers for selected location
  - Coordinates display

### 3. Integrated Mission Creation
- **Purpose**: Streamlined mission request flow with chat and location
- **Features**:
  - Chat button in mission creation
  - Map picker for meeting point
  - Partner place suggestions
  - All mission details in one page

## 📦 Dependencies Used

```yaml
dependencies:
  cloud_firestore: ^6.1.0         # Firestore for chat
  flutter_map: ^7.0.2             # OpenStreetMap (FREE, no API key required)
  latlong2: ^0.9.1                # Lat/Lng utilities for flutter_map
  provider: ^6.1.2                # State management
  geolocator: ^13.0.2             # GPS location
```

## 🗂️ New Files Created

### Services
- `lib/services/chat_service.dart` - Firestore chat operations

### Models
- `lib/models/chat_model.dart` - Chat message and thread models

### Pages
- `lib/pages/chat_page.dart` - Real-time chat interface
- `lib/pages/map_picker_page.dart` - Interactive map for location selection
- `lib/pages/create_mission_page.dart` - Complete mission creation with chat & map

## 🔧 Setup Instructions

### 1. Install Dependencies
```bash
cd skillswap_front_mobile
flutter pub get
```

### 2. OpenStreetMap Configuration

**No API key required!** OpenStreetMap is free and open source.

The map is already configured in `lib/pages/map_picker_page.dart`:
```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.skillswap.mobile',
),
```

### 3. Configure Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Chat threads
    match /chat_threads/{threadId} {
      allow read: if request.auth != null && 
                     request.auth.uid in resource.data.participants;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
                       request.auth.uid in resource.data.participants;
      
      // Messages in thread
      match /messages/{messageId} {
        allow read: if request.auth != null && 
                       request.auth.uid in get(/databases/$(database)/documents/chat_threads/$(threadId)).data.participants;
        allow create: if request.auth != null && 
                         request.auth.uid in get(/databases/$(database)/documents/chat_threads/$(threadId)).data.participants;
        allow update: if request.auth != null && 
                         request.auth.uid in get(/databases/$(database)/documents/chat_threads/$(threadId)).data.participants;
      }
    }
  }
}
```

## 🎯 User Flow

### Scenario: Request a Mission with Chat & Map

1. **Browse Skills**
   - User searches for skills nearby
   - Finds "Guitar Lessons" skill

2. **View Skill Details**
   - Taps on skill to see details
   - Clicks "Request Mission"

3. **Create Mission Page Opens**
   - Pre-filled with skill information
   - Chat button available in app bar

4. **Chat with Provider (Optional)**
   - User taps chat icon
   - Opens real-time chat
   - Discusses availability, location preferences
   - Returns to mission creation

5. **Select Meeting Point**
   - Taps "Select Meeting Point" card
   - Map picker opens (OpenStreetMap)
   - **Option A**: Selects "Café Central" from partner places
   - **Option B**: Taps custom location on map
   - Confirms selection

6. **Fill Mission Details**
   - Selects date and time
   - Sets duration (60 minutes)
   - Sets credit cost (10 credits)
   - Adds description

7. **Create Mission**
   - Taps "Create Mission"
   - Credits debited
   - Provider receives notification
   - Mission created with meeting point

8. **Provider Accepts**
   - Provider sees meeting point on map
   - Accepts mission
   - Both can navigate to location

## 📱 UI Components

### Chat Page
- **Header**: Shows other user's name and skill title
- **Message List**: Scrollable, reverse chronological
- **Message Bubbles**: Different colors for sender/receiver
- **Input Field**: Text field with send button
- **Timestamps**: Relative time (e.g., "5m ago")

### Map Picker Page
- **OpenStreetMap**: Interactive, tap to select
- **Info Card**: Shows selected location details
- **Current Location Button**: FAB to get GPS position
- **Partner Places**: Expandable list at bottom
- **Confirm Button**: Check icon in app bar

### Create Mission Page
- **Skill Info Card**: Shows skill details
- **Form Fields**: Title, description, date, time, duration, cost
- **Meeting Point Card**: Shows selected location or prompt
- **Chat Button**: Opens chat with provider
- **Create Button**: Submits mission request

## 🔐 Security Considerations

### Firestore
- Only participants can read/write messages
- Authentication required for all operations
- Server-side timestamps prevent manipulation

### Location Privacy
- Exact provider location never shared
- Only meeting point coordinates stored
- Users choose public meeting places

## 🧪 Testing

### Test Chat
1. Create two test accounts
2. One publishes a skill
3. Other requests mission
4. Open chat and send messages
5. Verify real-time updates

### Test Map Picker
1. Open mission creation
2. Tap "Select Meeting Point"
3. Test current location button
4. Tap custom location on map
5. Select partner place
6. Verify coordinates saved

### Test Complete Flow
1. Browse skills
2. Request mission
3. Chat with provider
4. Select meeting point
5. Create mission
6. Verify backend receives meeting point data

## 🐛 Troubleshooting

### Chat Not Working
- Check Firestore rules are deployed
- Verify Firebase initialization
- Check internet connection
- Ensure user is authenticated

### Map Not Loading
- Check internet connection
- Ensure location permissions granted
- Verify the device has GPS capabilities

### Meeting Point Not Saving
- Verify backend accepts meetingPoint field
- Check Mission model includes lat, lng, partnerPlaceId
- Ensure coordinates are valid numbers

## 🚀 Future Enhancements

### Chat
- [ ] Image sharing
- [ ] Voice messages
- [ ] Push notifications for new messages
- [ ] Typing indicators
- [ ] Message reactions

### Map
- [ ] Route preview to meeting point
- [ ] Estimated travel time
- [ ] Nearby public transport
- [ ] Save favorite places

### Mission
- [ ] Multiple meeting point options
- [ ] Reschedule meeting
- [ ] Share location in real-time
- [ ] Check-in confirmation

## 📚 Resources

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter Map Package](https://pub.dev/packages/flutter_map)
- [OpenStreetMap](https://www.openstreetmap.org/)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

## ✅ Checklist

Before deploying to production:

- [x] Install all dependencies
- [x] Configure OpenStreetMap (no API key needed!)
- [ ] Deploy Firestore security rules
- [ ] Test chat functionality
- [ ] Test map picker
- [ ] Test complete mission flow
- [ ] Verify backend integration
- [ ] Test on both Android and iOS
- [ ] Add error handling
- [ ] Add loading states
- [ ] Test offline behavior

---

**Status**: ✅ Implementation Complete  
**Version**: 1.0.0  
**Map Provider**: OpenStreetMap (FREE)  
**Last Updated**: January 24, 2026
