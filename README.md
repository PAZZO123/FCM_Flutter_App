# Lab 6 – Push Notifications with Firebase Cloud Messaging (FCM)
**Year 3 CSE | Flutter**

---

## Project Structure

```
fcm_app/
├── lib/
│   ├── main.dart                  # App entry point + Firebase init
│   ├── firebase_options.dart      # ⚠️ Replace with your own (see Step 3)
│   ├── screens/
│   │   └── home_screen.dart       # Main UI: token display + notification log
│   └── services/
│       └── fcm_service.dart       # All FCM logic (permissions, handlers, local notifs)
├── android/
│   ├── app/
│   │   ├── build.gradle           # Google Services plugin
│   │   └── src/main/
│   │       └── AndroidManifest.xml
│   └── build.gradle               # Project-level Gradle
└── pubspec.yaml                   # Dependencies
```

---

## Setup Guide (follow in order)

### Step 1 – Flutter & Dependencies
```bash
flutter pub get
```

### Step 2 – Create a Firebase Project
1. Go to [https://console.firebase.google.com](https://console.firebase.google.com)
2. Click **Add project** → name it (e.g. `fcm-lab6`)
3. Disable Google Analytics (optional) → **Create project**
4. In the left sidebar go to **Build → Cloud Messaging**

### Step 3 – Connect Firebase to Flutter (FlutterFire CLI)
```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# In your project root:
flutterfire configure
```
- Select your Firebase project
- Select **android** and/or **ios**
- This auto-generates `lib/firebase_options.dart` – **replaces the placeholder file**
- For Android it also downloads `google-services.json` into `android/app/`

### Step 4 – Android: google-services.json
If not auto-placed, manually copy `google-services.json` into:
```
android/app/google-services.json
```

### Step 5 – iOS (if needed)
1. In Firebase Console add an iOS app with your Bundle ID
2. Download `GoogleService-Info.plist`
3. Open Xcode → drag the plist into `Runner/` (check "Copy items if needed")
4. In Xcode → **Signing & Capabilities** → add **Push Notifications** and **Background Modes** (enable *Remote notifications*)

### Step 6 – Run on a Real Device
FCM **does not work on emulators** for push notifications.
```bash
flutter run
```

### Step 7 – Send a Test Notification from Firebase Console
1. Firebase Console → **Cloud Messaging** → **Send your first message**
2. Enter **Notification title** and **Notification text**
3. Click **Send test message**
4. Paste your device's FCM token (copied from the app UI) → **Test**

---

## Features Implemented
| Requirement | Status |
|---|---|
| Request notification permission | ✅ |
| Receive notifications on device | ✅ |
| Display FCM token on screen | ✅ |
| Copy token to clipboard | ✅ |
| Show popup dialog when notification received | ✅ |
| Display received messages in app UI | ✅ |
| Handle foreground notifications | ✅ |
| Handle background notifications | ✅ |
| Handle terminated-state notifications | ✅ |

---

## Dependencies
| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialization |
| `firebase_messaging` | FCM push notifications |
| `flutter_local_notifications` | Show popup when app is in foreground |
