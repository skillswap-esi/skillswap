# Firebase Firestore Security Rules for SkillSwap

Copy these rules to your Firebase Console → Firestore Database → Rules tab.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ============================================
    // HELPER FUNCTIONS
    // ============================================
    
    // Check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Get the current user's ID
    function userId() {
      return request.auth.uid;
    }
    
    // ============================================
    // CHAT THREADS
    // ============================================
    
    match /chat_threads/{threadId} {
      // Allow read if user is authenticated and is a participant
      allow read: if isAuthenticated() && 
                     (userId() in resource.data.participants);
      
      // Allow create if user is authenticated
      allow create: if isAuthenticated();
      
      // Allow update if user is authenticated and is a participant
      allow update: if isAuthenticated() && 
                       (userId() in resource.data.participants);
      
      // Messages subcollection
      match /messages/{messageId} {
        // Allow read if user is a participant in the parent thread
        allow read: if isAuthenticated() && 
                       (userId() in get(/databases/$(database)/documents/chat_threads/$(threadId)).data.participants);
        
        // Allow create if user is a participant in the parent thread
        allow create: if isAuthenticated() && 
                         (userId() in get(/databases/$(database)/documents/chat_threads/$(threadId)).data.participants);
        
        // Allow update if user is a participant (for marking as read)
        allow update: if isAuthenticated() && 
                         (userId() in get(/databases/$(database)/documents/chat_threads/$(threadId)).data.participants);
      }
    }
    
    // ============================================
    // NOTIFICATIONS (in-app notifications)
    // ============================================
    
    match /notifications/{notificationUserId} {
      // User can only access their own notifications
      allow read, write: if isAuthenticated() && userId() == notificationUserId;
      
      // Notification items subcollection
      match /items/{itemId} {
        allow read, write: if isAuthenticated() && userId() == notificationUserId;
      }
    }
    
    // ============================================
    // USER PROFILES (optional - if storing extra data)
    // ============================================
    
    match /users/{profileUserId} {
      // Users can read any profile
      allow read: if isAuthenticated();
      
      // Users can only write their own profile
      allow write: if isAuthenticated() && userId() == profileUserId;
    }
    
    // ============================================
    // FCM TOKENS (for push notifications)
    // ============================================
    
    match /fcm_tokens/{tokenId} {
      allow read, write: if isAuthenticated() && 
                            resource.data.userId == userId();
      allow create: if isAuthenticated();
    }
    
    // ============================================
    // DEVELOPMENT: ALLOW ALL (USE ONLY FOR TESTING!)
    // ============================================
    // Uncomment the lines below for testing, then DELETE them for production!
    
    // match /{document=**} {
    //   allow read, write: if true;
    // }
  }
}
```

## How to Apply These Rules:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click **Firestore Database** in the left sidebar
4. Click the **Rules** tab
5. Replace ALL existing rules with the rules above
6. Click **Publish**

## Quick Test Rules (Development Only):

If you want to quickly test without restrictions, use these rules temporarily:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

⚠️ **WARNING**: Remove the test rules before going to production!

## Common Errors:

| Error | Cause | Fix |
|-------|-------|-----|
| `PERMISSION_DENIED` | Rules not published | Publish rules in Firebase Console |
| `Missing or insufficient permissions` | User not authenticated or not a participant | Check that user is logged in |
| `Cannot read property 'participants'` | Thread document doesn't exist | Create thread before accessing messages |
