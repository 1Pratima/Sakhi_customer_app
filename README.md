# Flutter project configuration and setup

## SHG Customer Mobile Application

A fully functional Flutter mobile application for SHG (Self-Help Group) customers to manage savings, loans, and transactions.

### Features

- **User Authentication**: API-based authentication with secure token management
- **Dashboard**: Quick overview of savings, loans, and recent transactions
- **Savings Account**: View and manage savings with deposit history
- **Loan Management**: Track loan balance, EMI payments, and schedule
- **Transaction History**: View complete transaction history with filtering
- **Notifications**: Alerts for meetings, savings reminders, and loan updates
- **Profile Management**: User profile with account details
- **Push Notifications**: Firebase-based push notifications
- **Offline Support**: Local data caching with SQLite

### Technology Stack

- **Framework**: Flutter 3.0+
- **State Management**: Riverpod
- **API Client**: Dio with interceptors
- **Firebase**: Cloud Messaging for push notifications
- **Local Storage**: SQLite, Shared Preferences, Secure Storage
- **UI**: Material Design 3

### Project Structure

```
lib/
├── main.dart              # Application entry point
├── models/               # Data models
│   ├── user.dart
│   ├── account.dart
│   ├── loan.dart
│   ├── transaction.dart
│   └── auth_response.dart
├── services/             # Business logic and API calls
│   ├── api_service.dart
│   ├── firebase_service.dart
│   └── secure_storage_service.dart
├── providers/            # Riverpod state management
│   ├── service_providers.dart
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── account_provider.dart
│   └── transaction_provider.dart
├── screens/              # UI screens
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── transaction_history_screen.dart
│   ├── savings_account_detail_screen.dart
│   ├── loan_details_screen.dart
│   ├── notifications_screen.dart
│   └── profile_screen.dart
├── widgets/              # Reusable widgets
│   ├── common_widgets.dart
│   └── account_widgets.dart
└── utils/                # Utilities
    ├── theme.dart
    ├── formatters.dart
    └── constants.dart
```

### Environment Setup

#### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK
- Android Studio / Xcode
- Firebase account

#### Installation

1. **Clone the project** (if from Git):
   ```bash
   git clone <repository-url>
   cd Navajyoti_Customer_App
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code** (for JSON serialization):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Firebase**:
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Place them in the respective platform folders

5. **Update API Configuration**:
   - Update the `baseUrl` in `lib/services/api_service.dart`
   - Configure authentication endpoints

### Running the Application

#### Android
```bash
flutter run -d android
```

#### iOS
```bash
flutter run -d ios
```

#### Web
```bash
flutter run -d web
```

### API Integration

The app communicates with a backend API. Update the base URL and endpoints in:
- `lib/services/api_service.dart`

#### Required API Endpoints

- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `POST /auth/refresh` - Refresh token
- `GET /user/profile` - Get user profile
- `PUT /user/profile` - Update user profile
- `GET /accounts/savings` - Get savings accounts
- `GET /accounts/loans` - Get loan accounts
- `GET /accounts/deposits/{accountId}` - Get deposit history
- `GET /transactions` - Get transaction history
- `GET /notifications` - Get notifications

### Firebase Setup

1. **Create a Firebase project** in Firebase Console
2. **Enable Cloud Messaging**
3. **Add Android and iOS apps** to the project
4. **Download configuration files** and add to the project
5. **Update service workers** if using web

### Build & Release

#### Android Release Build
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS Release Build
```bash
flutter build ios --release
```

### Customization

#### Theme
Update colors and styles in `lib/utils/theme.dart`

#### API Base URL
Edit `baseUrl` constant in `lib/services/api_service.dart`

#### Features
Add new screens in `lib/screens/`
Add new state providers in `lib/providers/`

### Testing

To run tests:
```bash
flutter test
```

### Troubleshooting

#### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Firebase Issues
- Ensure `google-services.json` and `GoogleService-Info.plist` are properly configured
- Check Firebase console for app registration

#### API Connection Issues
- Verify backend API is running
- Check API endpoint URLs in `api_service.dart`
- Verify network connectivity

### Contributing

1. Create a feature branch
2. Make changes
3. Test thoroughly
4. Create a pull request

### License

This project is part of the SHG Customer Portal.

### Support

For issues or support:
- Contact: support@shgcustomer.com
- Email: help@shgcustomer.com

### Version History

- **v1.0.0** - Initial release with core features
  - Authentication
  - Dashboard
  - Savings & Loan Management
  - Transaction History
  - Notifications
  - User Profile
