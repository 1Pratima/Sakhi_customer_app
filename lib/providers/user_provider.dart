import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shg_customer_app/models/user.dart';
import 'package:shg_customer_app/providers/service_providers.dart';
import 'package:shg_customer_app/providers/auth_provider.dart';

// User profile provider with error handling
final userProfileProvider = FutureProvider<User>((ref) async {
  try {
    final apiService = ref.read(apiServiceProvider);
    final authState = ref.watch(authStateProvider);
    final mobileNumber = authState.mobileNumber;
    
    if (mobileNumber == null || mobileNumber.isEmpty) {
      throw Exception('Not logged in');
    }
    
    final response = await apiService.getProfile(mobileNumber);
    final json = response.data as Map<String, dynamic>;
    return User.fromJson(json);
  } catch (e) {
    // Escalate backend error so UI accurately reflects data absence
    rethrow;
  }
});

// Refresh user profile
final refreshUserProfileProvider =
    FutureProvider.family<User, String>((ref, userId) async {
  ref.invalidate(userProfileProvider);
  return ref.watch(userProfileProvider.future);
});
