# Bible App Testing Guide

This guide explains how to build the Bible app APK and run Appium tests on Windows.

## Prerequisites

1. Install required software:
   - [Node.js](https://nodejs.org/) (LTS version)
   - [Flutter SDK](https://flutter.dev/docs/get-started/install/windows)
   - [Android Studio](https://developer.android.com/studio)
   - [Java Development Kit (JDK)](https://adoptium.net/)
   - [Git](https://git-scm.com/downloads)

2. Set up environment variables:
   ```powershell
   # Add these to your System Environment Variables
   ANDROID_HOME = C:\Users\<YourUsername>\AppData\Local\Android\Sdk
   JAVA_HOME = C:\Program Files\Java\jdk-xxx
   Path += %ANDROID_HOME%\platform-tools
   ```

## Building the Bible App

1. Clone the repository:
   ```powershell
   git clone <repository-url>
   cd bible_app
   ```

2. Get Flutter dependencies:
   ```powershell
   flutter pub get
   ```

3. Build the APK:
   ```powershell
   flutter build apk
   ```
   The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## Setting Up Appium Tests

1. Install Appium and required drivers globally:
   ```powershell
   npm install -g appium
   npm install -g appium-uiautomator2-driver
   ```

2. Install Appium driver:
   ```powershell
   appium driver install uiautomator2
   ```

3. Navigate to the test directory:
   ```powershell
   cd test/appium
   ```

4. Install test dependencies:
   ```powershell
   npm install
   ```

## Running Tests

1. Start an Android emulator or connect a physical device:
   ```powershell
   # List available emulators
   flutter emulators
   
   # Start an emulator
   flutter emulators --launch <emulator-id>
   
   # Verify device connection
   flutter devices
   ```

2. Start the Appium server (in a new terminal):
   ```powershell
   cd test/appium
   npx appium
   ```

3. Run the tests (in another terminal):
   ```powershell
   cd test/appium
   npm test
   ```

## Troubleshooting

1. If Appium is not recognized:
   - Make sure Node.js is installed correctly
   - Try running with npx: `npx appium`
   - Check if Appium is in your PATH

2. If Android device is not found:
   - Check `adb devices` command output
   - Verify USB debugging is enabled on physical devices
   - Make sure emulator is running

3. If tests fail:
   - Check if the app is built correctly
   - Verify the app path in `wdio.conf.js`
   - Make sure all drivers are installed: `appium driver list --installed`

## Project Structure

```
bible_app/
├── lib/                    # Flutter app source code
├── test/                   # Test files
│   ├── widget_test.dart    # Flutter widget tests
│   └── appium/            # Appium tests
│       ├── specs/         # Test specifications
│       ├── package.json   # Node.js dependencies
│       └── wdio.conf.js   # WebdriverIO configuration
└── build/                 # Built applications
    └── app/outputs/flutter-apk/
        └── app-release.apk
```

## Common Commands

```powershell
# Build APK
flutter build apk

# Install Appium
npm install -g appium

# Install Appium driver
appium driver install uiautomator2

# Start Appium server
npx appium

# Run tests
npm test

# Check Appium setup
npm run doctor
```

## Notes

- Always build the app before running tests
- Keep Android SDK and Flutter up to date
- Make sure the emulator/device has the correct Android version
- The app-release.apk path in wdio.conf.js should match your actual build path
