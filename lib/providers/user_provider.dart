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
    
    String? base64Image;
    final clientId = json['id']?.toString() ?? json['clientId']?.toString();
    if (clientId != null) {
      // Trigger background device registration once we have the clientId
      final firebaseService = ref.read(firebaseServiceProvider);
      firebaseService.registerDevice(
        clientId: clientId,
        appUserId: authState.authResponse?.userId ?? '0',
      ).catchError((_) {}); // Run in background

      try {
        final imageResponse = await apiService.getClientImage(clientId);
        final rawData = imageResponse.data?.toString();
        // Sanitize immediately to prevent FormatException
        base64Image = rawData?.replaceAll(RegExp(r'\s+'), '');
      } catch (_) {}
    }

    User user = User.fromJson(json, base64Image: base64Image);

    // If sakhiId is present (numeric staff ID), fetch their mobile number specifically
    // Note: Fineract staff IDs are numeric. If it's a username (fallback), this might fail gracefully.
    if (user.sakhiId != null && user.sakhiId!.isNotEmpty && int.tryParse(user.sakhiId!) != null) {
      try {
        final staffResponse = await apiService.getStaffDetails(user.sakhiId!);
        final staffData = staffResponse.data;
        final staffMobile = staffData?['mobileNo']?.toString();
        if (staffMobile != null) {
          user = user.copyWith(sakhiPhone: staffMobile);
        }
      } catch (staffError) {
        print('>>> ERROR FETCHING SAKHI DETAILS: $staffError <<<');
      }
    }

    return user;
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
