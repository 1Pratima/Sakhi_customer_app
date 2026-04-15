import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shg_customer_app/services/api_service.dart';
import 'package:shg_customer_app/services/firebase_service.dart';
import 'package:shg_customer_app/services/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Service providers
final apiServiceProvider = Provider((ref) => ApiService());

final firebaseServiceProvider = Provider((ref) {
  final service = FirebaseService();
  final apiService = ref.read(apiServiceProvider);
  service.setApiService(apiService);
  
  // Initialize Firebase in background
  Future.delayed(const Duration(milliseconds: 500), () {
    service.initialize().catchError((e) {
      // Handle Firebase initialization errors silently
    });
  });
  return service;
});

final secureStorageProvider = Provider((ref) {
  const storage = FlutterSecureStorage();
  return SecureStorageService(storage);
});
