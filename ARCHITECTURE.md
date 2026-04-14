# Architecture Guide

## Overview

This Flutter application follows a clean architecture pattern with clear separation of concerns:

```
Presentation Layer (UI) ↔ Domain Layer (Business Logic) ↔ Data Layer (API & Storage)
         ↓                          ↓                           ↓
      Screens                    Providers               Services & Models
      Widgets                    State                   API Calls
```

## Layer Responsibilities

### 1. Presentation Layer (`lib/screens`, `lib/widgets`)

**Responsibility**: Display UI and handle user interactions

- **Screens**: Full page widgets
  - `LoginScreen` - Authentication
  - `HomeScreen` - Dashboard
  - `TransactionHistoryScreen` - Transaction list
  - `SavingsAccountDetailScreen` - Account details
  - `LoanDetailsScreen` - Loan information
  - `NotificationsScreen` - Notifications
  - `ProfileScreen` - User profile

- **Widgets**: Reusable UI components
  - `common_widgets.dart` - Generic components (buttons, headers, loaders)
  - `account_widgets.dart` - Domain-specific components (cards, transactions)

**Key Principles**:
- Keep screens focused on UI
- Extract reusable components to widgets
- Delegate business logic to providers
- Minimal state management in widgets

### 2. Domain/State Management Layer (`lib/providers`)

**Responsibility**: Manage application state using Riverpod

#### Provider Types:

**Service Providers** (`service_providers.dart`):
```dart
final apiServiceProvider = Provider((ref) => ApiService());
```
- Singleton services
- Used across the app
- Lazy initialized

**State Providers** (`auth_provider.dart`):
```dart
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);
```
- Mutable state with notifiers
- Handle authentication flow
- State changes trigger rebuilds

**Data Providers** (`user_provider.dart`, `account_provider.dart`):
```dart
final userProfileProvider = FutureProvider<User>((ref) async {...});
```
- Fetch data from services
- Automatic caching
- Error handling

#### Data Flow:
```
Widget → Riverpod Provider → Service → API/Storage → Response → Widget
```

### 3. Data Layer (`lib/services`, `lib/models`)

**Responsibility**: Handle all data operations

#### Services:

**ApiService** (`lib/services/api_service.dart`):
- HTTP client configuration with Dio
- Token management and refresh
- API endpoints
- Error handling and retry logic

**FirebaseService** (`lib/services/firebase_service.dart`):
- Push notifications
- FCM token management
- Analytics tracking

**SecureStorageService** (`lib/services/secure_storage_service.dart`):
- Secure credential storage
- Encryption handling

#### Models:

**Data Classes** (`lib/models/`):
- `User` - User profile
- `SavingsAccount` - Savings account data
- `LoanAccount` - Loan data
- `Transaction` - Transaction record
- `AuthResponse` - Authentication response

**Serialization**:
- JSON serialization using `json_annotation`
- Code generation with `build_runner`
- Type-safe data handling

## State Management Flow

### Example: User Login

```dart
// 1. Widget calls provider action
await ref.read(authStateProvider.notifier).login(email, password);

// 2. Notifier calls service
final apiService = ref.read(apiServiceProvider);
final response = await apiService.login(email, password);

// 3. Service makes HTTP request
Future<Response> login(String email, String password) {
  return _dio.post('/auth/login', data: {...});
}

// 4. Response returned and state updated
state = state.copyWith(
  isAuthenticated: true,
  authResponse: authResponse,
);

// 5. Widget rebuilds with new state
final authState = ref.watch(authStateProvider);
if (authState.isAuthenticated) {
  // Navigate to home
}
```

## Dependency Injection

All dependencies are injected through Riverpod providers:

```dart
// Services are provided to other providers
final userProvider = Provider((ref) {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getProfile();
});

// Widgets consume providers
final userProfile = ref.watch(userProfileProvider);
```

## Error Handling

### Global Error Strategy:

1. **API Errors**: Caught in services and returned in state
2. **State Errors**: Stored in provider state for UI display
3. **UI Display**: Widgets check for errors and show appropriate UI

```dart
final data = ref.watch(dataProvider);
data.when(
  data: (value) => DisplayWidget(value),
  loading: () => LoadingWidget(),
  error: (err, stack) => ErrorWidget(message: err.toString()),
);
```

## Data Caching

### Riverpod Caching:

- Automatic caching of `FutureProvider` results
- Cache invalidation:
  ```dart
  ref.invalidate(providerName);
  ref.refresh(providerName);
  ```

### Selective Invalidation:

```dart
// Refresh specific data after mutation
ref.invalidate(savingsAccountsProvider);
ref.invalidate(transactionHistoryProvider);
```

## Code Organization

### Naming Conventions:

```
Services:       *_service.dart      (api_service.dart)
Models:         *.dart              (user.dart)
Providers:      *_provider.dart     (auth_provider.dart)
Screens:        *_screen.dart       (home_screen.dart)
Widgets:        *.dart              (common_widgets.dart)
Utils:          *.dart              (formatters.dart)
```

### File Structure:

Each layer is independent but can depend on lower layers:

```
lib/
├── main.dart              (Entry point)
├── models/                (Data models)
├── services/              (External dependencies)
├── providers/             (State & business logic)
├── screens/               (UI - High level)
├── widgets/               (UI - Reusable)
└── utils/                 (Helpers & constants)
```

## Best Practices

### 1. Separation of Concerns
- Services handle data
- Providers handle logic
- Screens handle UI

### 2. Immutability
- Use `const` constructors
- Immutable state classes
- Immutable models

### 3. Type Safety
- Avoid `dynamic` types
- Use generics
- Strong typing for providers

### 4. Error Handling
- Always handle errors in FutureProvider
- Show user-friendly error messages
- Log errors for debugging

### 5. Performance
- Use `select` for selective watching
  ```dart
  final userName = ref.watch(
    userProfileProvider.select((user) => user.name)
  );
  ```
- Avoid unnecessary rebuilds
- Use `const` widgets

### 6. Testing
- Mock services for testing
- Test providers independently
- Test screens with mocked data

## Extending the Architecture

### Add New Feature:

1. **Create Model** (`lib/models/feature.dart`):
   ```dart
   @JsonSerializable()
   class Feature { ... }
   ```

2. **Add Service Methods** (`lib/services/api_service.dart`):
   ```dart
   Future<Response> getFeature() => _dio.get('/feature');
   ```

3. **Create Provider** (`lib/providers/feature_provider.dart`):
   ```dart
   final featureProvider = FutureProvider<Feature>((ref) async {...});
   ```

4. **Create Screen** (`lib/screens/feature_screen.dart`):
   ```dart
   final feature = ref.watch(featureProvider);
   ```

5. **Create Widgets** (`lib/widgets/feature_widgets.dart`):
   ```dart
   Widget buildFeatureCard(Feature feature) { ... }
   ```

## Performance Tips

1. **Use FutureProvider wisely**
   - Cache expensive operations
   - Invalidate selectively

2. **Minimize rebuilds**
   - Use `select` to watch specific properties
   - Use `Consumer` for partial rebuilds

3. **Optimize List Building**
   - Use `ListView.builder` for large lists
   - Use `const` items

4. **Image Optimization**
   - Cache images
   - Use network image with placeholder

## Testing Strategy

```dart
// Test providers with mock services
test('login returns success', () {
  final container = ProviderContainer(
    overrides: [
      apiServiceProvider.overrideWithValue(mockApiService),
    ],
  );
  // Test logic
});
```

## Security Considerations

1. **Token Storage**: Secure storage with `flutter_secure_storage`
2. **HTTPS**: All API calls use HTTPS
3. **Token Refresh**: Automatic token refresh on expiration
4. **Sensitive Data**: Never log sensitive information
5. **Input Validation**: Validate all user inputs

## Deployment

### Environment Configuration:
- Development: Debug logs, mock data
- Staging: Real API, Sentry logging
- Production: Optimized, analytics only

```dart
const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://api.dev.com',
);
```

## Monitoring & Analytics

- Firebase Analytics for user behavior
- Sentry for error tracking
- Custom logging for debugging
- Performance monitoring

## References

- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture](https://resocoder.com/flutter-clean-architecture)
