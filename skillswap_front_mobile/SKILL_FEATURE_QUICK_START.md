# Skill Feature - Quick Start Guide

## 🚀 Quick Setup (5 minutes)

### 1. Install Dependencies ✅

```bash
cd skillswap_front_mobile
flutter pub get
```

**Status:** ✅ Already completed

### 2. Configure Location Permissions

#### For Android Testing

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Add these lines BEFORE <application> tag -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <application
        ...
    </application>
</manifest>
```

#### For iOS Testing

Edit `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Add these entries -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location to show nearby skills</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>We need your location to show nearby skills</string>
    
    <!-- Existing entries... -->
</dict>
```

### 3. Start Backend Services

Make sure these services are running:

```bash
# In skillswap-backend directory
cd skillswap-backend

# Start all services
start-all-services.bat
```

**Required Services:**
- ✅ API Gateway (Port 8080)
- ✅ User Service (Port 8081)
- ✅ Skill Service (Port 8082)
- ✅ MongoDB (Port 27017)

### 4. Run the App

```bash
# Start Android emulator or connect device
flutter run
```

## 📱 Testing the Feature

### Test 1: Publish Your First Skill

1. **Login** to the app
2. Open the **drawer menu** (hamburger icon)
3. Tap **"My Skills"**
4. Tap the **"Add Skill"** floating button
5. Fill in the form:
   - Title: "Guitar Lessons"
   - Description: "Beginner guitar lessons for all ages"
   - Category: 🎵 Musique
6. Wait for location to be detected
7. Tap **"Publish Skill"**

**Expected Result:** ✅ Skill created successfully, returns to My Skills page

### Test 2: View Your Skills

1. You should see your newly created skill in the list
2. Tap on the skill card
3. View the skill details

**Expected Result:** ✅ Skill details displayed with all information

### Test 3: Explore Nearby Skills

1. Open the **drawer menu**
2. Tap **"Explore Skills"**
3. Wait for location detection
4. View nearby skills (including your own)

**Expected Result:** ✅ Skills displayed with distance

### Test 4: Filter Skills

1. In Explore Skills page, tap **"Filter"** button
2. Select a category (e.g., 🎵 Musique)
3. Adjust radius slider (e.g., 20 km)
4. Tap **"Apply Filters"**

**Expected Result:** ✅ Filtered results displayed

### Test 5: Manage Your Skill

1. Go to **My Skills**
2. Tap on your skill
3. Tap the **menu icon** (three dots)
4. Select **"Deactivate"**

**Expected Result:** ✅ Skill status changed to Inactive

5. Tap menu again and select **"Delete"**
6. Confirm deletion

**Expected Result:** ✅ Skill deleted, returns to My Skills page

## 🎯 Quick Access Points

### From Home Page

**Quick Actions:**
- **"Publish Skill"** button → Create new skill
- **"Explore"** button → Browse nearby skills

### From Drawer Menu

- **"My Skills"** → Manage your skills
- **"Explore Skills"** → Discover nearby skills

## 🐛 Common Issues & Solutions

### Issue 1: Location Not Detected

**Symptoms:** "Location not detected" message

**Solutions:**
1. Enable location services on your device
2. Grant location permission when prompted
3. Tap "Get Location" button to retry
4. For emulator: Set location in emulator settings

### Issue 2: Cannot Create Skill

**Symptoms:** Error message when creating skill

**Solutions:**
1. Check all form fields are filled
2. Ensure location is detected
3. Verify backend services are running
4. Check API Gateway logs

### Issue 3: No Skills Found

**Symptoms:** Empty state in Explore Skills

**Solutions:**
1. Create some test skills first
2. Increase search radius
3. Remove category filter
4. Check if skills exist in database

### Issue 4: Backend Connection Error

**Symptoms:** "No internet connection" or API errors

**Solutions:**
1. Verify API Gateway is running: `http://localhost:8080`
2. Check Skill Service: `http://localhost:8082`
3. Test endpoint: `curl http://localhost:8080/api/skills/near?lat=48.8566&lng=2.3522&radius=10`
4. Check firewall settings

## 📊 Test Data

### Sample Skills to Create

1. **Programming Tutor**
   - Category: 💻 Informatique
   - Description: "Python and JavaScript lessons for beginners"

2. **Cooking Classes**
   - Category: 🍳 Cuisine
   - Description: "Learn to cook traditional French cuisine"

3. **Language Exchange**
   - Category: 🗣️ Langues
   - Description: "English-French language exchange"

4. **Guitar Lessons**
   - Category: 🎵 Musique
   - Description: "Acoustic guitar for all levels"

5. **Home Repair**
   - Category: 🔨 Bricolage
   - Description: "Basic home repair and maintenance"

## 🔍 Verification Checklist

After testing, verify:

- [ ] Can create skills with all categories
- [ ] Location is detected automatically
- [ ] Skills appear in "My Skills" list
- [ ] Can view skill details
- [ ] Can toggle skill active/inactive
- [ ] Can delete skills
- [ ] Explore page shows nearby skills
- [ ] Distance is calculated correctly
- [ ] Category filter works
- [ ] Radius filter works
- [ ] Pull-to-refresh works
- [ ] Empty states display correctly
- [ ] Error messages are clear

## 📸 Screenshots to Capture

For documentation:

1. Home page with quick actions
2. Create skill form
3. My Skills list
4. Skill detail page
5. Explore skills page
6. Filter modal
7. Empty states
8. Success messages

## 🎓 API Testing (Optional)

Test backend directly with curl:

```bash
# Get nearby skills
curl "http://localhost:8080/api/skills/near?lat=48.8566&lng=2.3522&radius=10"

# Create skill (replace USER_ID)
curl -X POST http://localhost:8080/api/skills \
  -H "Content-Type: application/json" \
  -H "X-User-Id: YOUR_USER_ID" \
  -d '{
    "title": "Test Skill",
    "description": "Test description",
    "category": "INFORMATIQUE",
    "latitude": 48.8566,
    "longitude": 2.3522
  }'

# Get user's skills (replace USER_ID)
curl "http://localhost:8080/api/skills/user/YOUR_USER_ID"
```

## ✅ Success Criteria

The feature is working correctly if:

1. ✅ Users can publish skills with geolocation
2. ✅ Skills are stored in MongoDB
3. ✅ Users can view their own skills
4. ✅ Users can explore nearby skills
5. ✅ Distance calculation is accurate
6. ✅ Filtering works correctly
7. ✅ Users can manage their skills
8. ✅ UI is responsive and intuitive
9. ✅ Error handling is graceful
10. ✅ Permissions are handled properly

## 🎉 Next Steps

After successful testing:

1. **Create more test data** for realistic testing
2. **Test on physical device** for accurate location
3. **Test with multiple users** for social features
4. **Implement mission creation** from skills
5. **Add skill matching algorithm**
6. **Implement notifications** for nearby skills

## 📞 Support

If you encounter issues:

1. Check the logs in Android Studio / Xcode
2. Review backend logs in terminal
3. Check MongoDB data: `mongosh skillswap-skills`
4. Review [SKILL_FEATURE_INTEGRATION.md](SKILL_FEATURE_INTEGRATION.md)
5. Check backend documentation in `skillswap-backend/skillswap-service-skill/`

---

**Ready to test?** Follow the steps above and start publishing skills! 🚀
