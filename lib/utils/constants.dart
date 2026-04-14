class AppConstants {
  // App info
  static const String appName = 'SHG Customer';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://api.shgcustomer.com/api';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Shared preferences keys
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefUserEmail = 'user_email';
  static const String prefUserId = 'user_id';

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
}
