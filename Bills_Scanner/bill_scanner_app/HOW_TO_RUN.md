# 🚀 How to Run the App

## ✅ Available Devices

You have **3 devices** available:
1. ✅ **Chrome (web)** - Ready to use! ⭐ **Easiest option**
2. ✅ **Edge (web)** - Ready to use!
3. ⚠️ **Windows (desktop)** - Needs Visual Studio

---

## 🌐 Option 1: Run on Chrome (Recommended - Easiest)

### Quick Command:
```bash
cd "D:\VN SANJAY\VNSanjay\Projects\BILL_SCANNER\Bills_Scanner\bill_scanner_app"
C:\flutter\bin\flutter.bat run -d chrome
```

### What happens:
- Opens Chrome browser
- App runs in the browser
- Hot reload enabled (save files = instant update)
- Press `r` in terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

---

## 🌐 Option 2: Run on Edge

```bash
cd "D:\VN SANJAY\VNSanjay\Projects\BILL_SCANNER\Bills_Scanner\bill_scanner_app"
C:\flutter\bin\flutter.bat run -d edge
```

---

## 📱 Option 3: Run on Android (Requires Setup)

### Prerequisites:
1. Install **Android Studio**: https://developer.android.com/studio
2. Set up Android SDK
3. Create/Start Android Emulator

### Then run:
```bash
C:\flutter\bin\flutter.bat run
```

---

## 💻 Option 4: Run on Windows Desktop (Requires Visual Studio)

### Prerequisites:
1. Install **Visual Studio**: https://visualstudio.microsoft.com/downloads/
2. Install "Desktop development with C++" workload

### Then run:
```bash
C:\flutter\bin\flutter.bat run -d windows
```

---

## 🎯 Quick Start (Chrome - Easiest)

### Step 1: Navigate to project
```bash
cd "D:\VN SANJAY\VNSanjay\Projects\BILL_SCANNER\Bills_Scanner\bill_scanner_app"
```

### Step 2: Run on Chrome
```bash
C:\flutter\bin\flutter.bat run -d chrome
```

### Step 3: Wait for build
- First time: Takes 2-5 minutes (compiling)
- Chrome will open automatically
- App will appear in browser

### Step 4: Test the app
- You'll see the Welcome Onboarding screen
- Click "Create an Account" → Goes to Sign Up screen
- Click "Log In" → Goes to Login screen
- Use back button to navigate

---

## 🔥 Hot Reload (While App is Running)

While the app is running in terminal:
- Press `r` = Hot reload (fast, keeps state)
- Press `R` = Hot restart (full restart)
- Press `q` = Quit app

Or save any `.dart` file in your IDE = Auto hot reload!

---

## 🐛 Troubleshooting

### If Chrome doesn't open:
```bash
# Check if Chrome is available
C:\flutter\bin\flutter.bat devices

# Try running again
C:\flutter\bin\flutter.bat run -d chrome
```

### If build fails:
```bash
# Clean and rebuild
C:\flutter\bin\flutter.bat clean
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat run -d chrome
```

### If you see errors:
- Check terminal output for specific error messages
- Make sure all dependencies are installed: `flutter pub get`

---

## 📝 Quick Reference

| Command | Description |
|---------|-------------|
| `flutter run -d chrome` | Run on Chrome |
| `flutter run -d edge` | Run on Edge |
| `flutter run` | Run on default device |
| `flutter devices` | List available devices |
| `flutter doctor` | Check setup status |

---

## ✅ Recommended: Start with Chrome

**Easiest way to test your app right now:**

```bash
cd "D:\VN SANJAY\VNSanjay\Projects\BILL_SCANNER\Bills_Scanner\bill_scanner_app"
C:\flutter\bin\flutter.bat run -d chrome
```

**That's it!** Chrome will open and show your app! 🎉

---

**Need help?** Check the terminal output for any error messages.

