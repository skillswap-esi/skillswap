# Deploy Firestore Security Rules

## Steps to Deploy

### 1. Install Firebase CLI (if not already installed)
```bash
npm install -g firebase-tools
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Navigate to project directory
```bash
cd skillswap_front_mobile
```

### 4. Initialize Firebase (if not done)
```bash
firebase init firestore
```
- Select your project: `skillswap-e6565`
- Use existing `firestore.rules` file
- Don't overwrite the file

### 5. Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

## Alternative: Manual Deployment via Firebase Console

If you prefer to deploy manually:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `skillswap-e6565`
3. Go to **Firestore Database** → **Rules** tab
4. Copy the content from `firestore.rules` file
5. Paste it in the rules editor
6. Click **Publish**

## Firestore Rules Summary

The rules allow:
- ✅ Authenticated users to create chat threads
- ✅ Participants to read/write messages in their threads
- ✅ Automatic addition of Firebase UIDs when users join threads
- ✅ Users to manage their own notifications

## Testing After Deployment

1. Hot restart your Flutter app
2. Try to open a chat from mission detail page
3. Check logs for successful thread creation
4. Send a test message

## Troubleshooting

If you still get permission denied:
1. Check Firebase Console → Firestore → Rules tab
2. Verify rules are published
3. Check the "Rules playground" to test specific operations
4. Ensure your Firebase Auth user is properly authenticated
