# Quick Start Guide - SHG Customer App

## Prerequisites

Before you begin, ensure you have installed:
- Flutter SDK 3.0+
- Dart SDK
- Android Studio or Xcode
- Git (optional)

## Step 1: Setup Flutter

1. Download Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extract and add Flutter to your PATH
3. Verify installation:
   ```bash
   flutter doctor
   ```

## Step 2: Clone/Setup Project

```bash
# Clone the repository (if applicable)
git clone <repository-url>

# Navigate to project directory
cd Navajyoti_Customer_App

# Get all dependencies
flutter pub get
```

## Step 3: Generate Code

The project uses JSON serialization. Generate code with:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Step 4: Configure Firebase (Important!)

### Android Setup:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select existing
3. Add Android app
4. Download `google-services.json`
5. Place in `android/app/`

### iOS Setup:
1. Add iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Open `ios/Runner.xcworkspace` in Xcode
4. Drag & drop `GoogleService-Info.plist` into Xcode

## Step 5: Configure API Endpoint

Edit `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://your-api-url/api';
```

## Step 6: Run the App

### For Android:
```bash
flutter run -d android
```

### For iOS:
```bash
flutter run -d ios
```

### For Web (Beta):
```bash
flutter run -d web
```

## Step 7: Build Release APK/IPA

### Android APK:
```bash
flutter build apk --release
```

### Android App Bundle:
```bash
flutter build appbundle --release
```

### iOS:
```bash
flutter build ios --release
```

## Common Issues & Solutions

### Issue: "Doctor found issues"
**Solution:**
```bash
flutter doctor --android-licenses
# Accept all licenses
```

### Issue: "Could not find the Android SDK"
**Solution:**
- Set `ANDROID_HOME` environment variable to your Android SDK location
- On Windows: `C:\Users\YourUsername\AppData\Local\Android\sdk`
- On macOS: `~/Library/Android/sdk`

### Issue: Pods not found (iOS)
**Solution:**
```bash
cd ios
pod install --repo-update
cd ..
```

### Issue: Build slow or out of memory
**Solution:**
```bash
# Clean and try again
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build
```

### Issue: Firebase configuration error
**Solution:**
- Ensure `google-services.json` (Android) is in correct location
- Ensure `GoogleService-Info.plist` (iOS) is added to Xcode project
- Rebuild the app

## Project Directory Structure

```
Navajyoti_Customer_App/
├── lib/                          # Source code
│   ├── main.dart                # Entry point
│   ├── models/                  # Data models
│   ├── services/                # API and business logic
│   ├── providers/               # State management
│   ├── screens/                 # UI Screens
│   ├── widgets/                 # Reusable components
│   └── utils/                   # Helper utilities
├── android/                     # Android-specific code
├── ios/                         # iOS-specific code
├── test/                        # Unit and widget tests
├── pubspec.yaml                # Dependencies
├── analysis_options.yaml        # Linting rules
├── README.md                    # Full documentation
└── QUICKSTART.md               # This file
```

## Testing

Run tests with:
```bash
flutter test
```

Run a specific test:
```bash
flutter test test/widget_test.dart
```

## Development Workflow

1. Create a new branch: `git checkout -b feature/feature-name`
2. Make changes and test
3. Format code: `flutter format lib/`
4. Analyze code: `flutter analyze`
5. Commit changes: `git commit -m "Add feature"`
6. Push and create PR

## Useful Commands

```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format lib/ test/

# Check dependencies
flutter pub outdated

# Update dependencies
flutter pub upgrade

# Clear cache and rebuild
flutter clean && flutter pub get

# Run with verbose logging
flutter run -v

# Generate coverage report
flutter test --coverage
```

## Debugging

### Debug Build Variables:
```bash
# Print debug info
flutter run --dart-define MY_VAR=value
```

### Debugger:
- Set breakpoints in VS Code
- Use `Debug` > `Start Debugging` (F5)
- Use Chrome DevTools for web

### Logs:
```bash
# Filter logs
flutter logs | grep "Your filter"

# Save logs to file
flutter logs > app.log
```

## Performance Optimization

1. Use `const` constructors where possible
2. Minimize rebuilds with Riverpod selection
3. Lazy load images and content
4. Use `ListView.builder` for large lists
5. Profile with Flutter DevTools

## Next Steps

1. Review the API endpoints in `lib/services/api_service.dart`
2. Customize theme in `lib/utils/theme.dart`
3. Add more screens as needed
4. Test on real devices
5. Deploy to app stores

## Support & Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material Design 3](https://m3.material.io)

## Troubleshooting Checklist

- [ ] Flutter doctor shows no errors
- [ ] Dependencies installed with `flutter pub get`
- [ ] Code generated with `flutter pub run build_runner build`
- [ ] Firebase configuration complete
- [ ] API endpoint configured
- [ ] App runs without errors
- [ ] Tested on actual device

Happy coding! 🚀
