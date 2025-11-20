# 📱 Bill Scanner Dashboard - Flutter App

A beautiful, native Flutter mobile application for tracking the Bill Scanner project development progress. Features real-time sync with Firebase, offline support, and a modern Material 3 design.

---

## ✨ Features

- **📊 Real-time Sync** - Automatically syncs with web dashboard via Firebase
- **🎨 Beautiful UI** - Material 3 dark theme with gradient accents
- **📡 Offline Support** - Works without internet, syncs when connected
- **📈 Analytics** - Detailed statistics and progress tracking
- **🚀 Fast & Responsive** - Optimized performance with lazy loading
- **🔄 Pull-to-Refresh** - Manual sync trigger
- **📱 Cross-platform** - Works on Android and iOS

---

## 🏗️ Architecture

```
lib/
├── main.dart                      # App entry point
├── models/
│   └── project_data.dart          # Data models (ProjectData, Phase, Task)
├── services/
│   ├── firebase_service.dart      # Firebase Realtime Database service
│   └── local_storage_service.dart # Local caching with Hive
├── providers/
│   └── dashboard_provider.dart    # State management with Provider
├── screens/
│   ├── home_screen.dart           # Main dashboard
│   ├── analytics_screen.dart      # Statistics & charts
│   └── phase_detail_screen.dart   # Individual phase details
├── widgets/
│   ├── stat_card.dart             # Statistics card widget
│   ├── phase_card.dart            # Phase summary card
│   ├── task_item.dart             # Task list item
│   └── connection_banner.dart     # Online/offline indicator
└── utils/
    └── app_theme.dart             # Theme configuration
```

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart 3.0 or higher
- Android Studio / Xcode
- Firebase account

### Installation

1. **Navigate to project directory**
   ```bash
   cd Bills_Scanner/dashboard_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase (creates firebase_options.dart)
   flutterfire configure
   ```

4. **Update main.dart**
   - Replace the placeholder Firebase config with generated config
   - Import the generated `firebase_options.dart`

5. **Run the app**
   ```bash
   # On Android
   flutter run
   
   # On iOS (Mac only)
   flutter run -d ios
   ```

---

## 🔥 Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name: `bill-scanner-dashboard`
4. Follow the setup wizard

### Step 2: Enable Realtime Database

1. In Firebase Console, go to "Build" → "Realtime Database"
2. Click "Create Database"
3. Choose location (e.g., `us-central1`)
4. Start in **Test Mode** (for development)
5. Click "Enable"

### Step 3: Set Security Rules

In the Realtime Database, go to "Rules" tab and paste:

```json
{
  "rules": {
    "billScanner": {
      "progress": {
        ".read": true,
        ".write": true
      }
    }
  }
}
```

**Note:** For production, implement proper authentication rules.

### Step 4: Add Apps

#### For Android:
1. Click Android icon in Project Overview
2. Package name: `com.billscanner.dashboard_app`
3. Download `google-services.json`
4. Place in `android/app/`

#### For iOS:
1. Click iOS icon in Project Overview
2. Bundle ID: `com.billscanner.dashboardApp`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/`

### Step 5: Configure FlutterFire

```bash
flutterfire configure
```

This will:
- Create `lib/firebase_options.dart`
- Configure Android and iOS automatically

---

## ⚙️ Configuration

### Android Setup

1. **Update `android/app/build.gradle`:**
   ```gradle
   android {
       compileSdkVersion 34
       
       defaultConfig {
           applicationId "com.billscanner.dashboard_app"
           minSdkVersion 21  // Required for Firebase
           targetSdkVersion 34
           versionCode 1
           versionName "1.0"
           multiDexEnabled true
       }
   }
   ```

2. **Add Internet Permission**

   In `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <manifest>
       <uses-permission android:name="android.permission.INTERNET"/>
       <application>
           ...
       </application>
   </manifest>
   ```

### iOS Setup

1. **Open in Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure signing**
   - Select your development team
   - Ensure Bundle ID matches Firebase

3. **Install CocoaPods:**
   ```bash
   cd ios
   pod install
   ```

---

## 📱 Building

### Android

#### Debug APK
```bash
flutter build apk
```

#### Release APK
```bash
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

#### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS

#### Debug
```bash
flutter build ios
```

#### Release (requires Apple Developer account)
```bash
flutter build ios --release
open ios/Runner.xcworkspace
```

Then archive and distribute via Xcode.

---

## 🎨 Features

### Home Screen
- **Statistics Cards** - Overall progress, tasks completed, current phase
- **Timeline** - Days elapsed, tasks per day, active phases
- **Phase List** - All phases with progress bars
- **Pull to Refresh** - Manual sync trigger
- **Connection Banner** - Shows online/offline status

### Analytics Screen
- **Detailed Statistics** - All metrics in one place
- **Phase Breakdown** - Individual phase progress
- **Timeline Info** - Project timeline details
- **Visual Progress** - Charts and graphs

### Phase Detail Screen
- **Phase Information** - Description, status, timeline
- **Task List** - All tasks with checkboxes
- **Task Toggle** - Tap to mark complete/incomplete
- **Progress Tracking** - Real-time progress updates

---

## 🔄 Real-time Sync

The app automatically syncs with Firebase:

**Web Dashboard** ↔️ **Firebase** ↔️ **Flutter App**

### How it Works:

1. **User updates task** in web or mobile
2. **Change saved to Firebase** instantly
3. **All connected devices update** automatically
4. **Offline changes sync** when connection returns

### Optimistic Updates:

Changes appear immediately in the UI, then sync in the background.

---

## 🎯 State Management

Uses **Provider** pattern for state management:

```dart
// Access provider
final provider = context.watch<DashboardProvider>();

// Use data
final stats = provider.getStatistics();

// Trigger actions
provider.toggleTask(phaseId, taskIndex);
```

---

## 🐛 Troubleshooting

### Firebase not connecting
- Verify Firebase config in `main.dart`
- Check `google-services.json` is in correct location
- Ensure Realtime Database is enabled

### Build errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter doctor

# Fix common issues
flutter doctor --android-licenses
```

### Android issues
- Update Android SDK to latest
- Check `minSdkVersion` is 21+
- Enable MultiDex if needed

### iOS issues
- Run `pod install` in `ios/` folder
- Update CocoaPods: `sudo gem install cocoapods`
- Clean Xcode build: Product → Clean Build Folder

---

## 📦 Dependencies

```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_database: ^10.4.0
  
  # State Management
  provider: ^6.1.1
  
  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  
  # UI
  google_fonts: ^6.1.0
  fl_chart: ^0.66.0
  
  # Utilities
  intl: ^0.19.0
  connectivity_plus: ^5.0.2
```

---

## 🚀 Performance

- **Fast Initial Load** - Cached data loads instantly
- **Lazy Loading** - Only loads visible items
- **Optimized Images** - No heavy assets
- **Real-time Updates** - Instant sync without polling
- **Efficient Rendering** - Uses Flutter's rendering engine

---

## 🔐 Security

### Current Setup (Development)
- Open read/write access to Firebase
- No authentication required
- Suitable for development only

### Production Recommendations
1. **Add Authentication** - Firebase Auth
2. **Secure Rules** - User-based access control
3. **Enable SSL Pinning** - Prevent MITM attacks
4. **Obfuscate Code** - Protect business logic

---

## 📝 License

This project is part of the Bill Scanner development toolkit.

---

## 🤝 Contributing

This is an internal development tool. For questions or issues, refer to project documentation.

---

## 📱 Screenshots

*Add screenshots here once app is built*

---

## 🎉 Next Steps

1. ✅ **Configure Firebase** - Set up your Firebase project
2. ✅ **Run `flutterfire configure`** - Auto-configure Firebase
3. ✅ **Test on device** - Run `flutter run`
4. ✅ **Sync with web dashboard** - Update tasks and watch sync!
5. ✅ **Build APK** - Create release build

---

**Made with ❤️ using Flutter**

*Last Updated: October 21, 2025*
