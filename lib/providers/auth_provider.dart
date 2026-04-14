import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shg_customer_app/models/auth_response.dart';
import 'package:shg_customer_app/providers/service_providers.dart';

// Auth state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final AuthResponse? authResponse;
  final String? error;
  final bool otpSent;
  final String? mobileNumber;
  final bool otpVerified;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.authResponse,
    this.error,
    this.otpSent = false,
    this.mobileNumber,
    this.otpVerified = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    AuthResponse? authResponse,
    String? error,
    bool? otpSent,
    String? mobileNumber,
    bool? otpVerified,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      authResponse: authResponse ?? this.authResponse,
      error: error ?? this.error,
      otpSent: otpSent ?? this.otpSent,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      otpVerified: otpVerified ?? this.otpVerified,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState());

  // Request OTP for mobile number
  Future<bool> requestOTP(String mobileNumber) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final apiService = ref.read(apiServiceProvider);
      // Call OTP request endpoint
      try {
        print('Attempting to request OTP for $mobileNumber');
        final response = await apiService.requestOTP(mobileNumber);
        print('OTP Request Response CODE: ${response.statusCode}');
        print('OTP Request Response BODY: ${response.data}');

        if (response.statusCode == 200) {
          // If 200, assume success for now to debug why SMS isn't triggering/verifying
          state = state.copyWith(
            isLoading: false,
            otpSent: true,
            mobileNumber: mobileNumber,
          );
          return true;
        } else {
          state = state.copyWith(
            isLoading: false,
            error: response.data['message'] ?? 'Failed to send OTP',
          );
          return false;
        }
      } catch (apiError) {
        String errorMessage = 'Connection failed';
        if (apiError is DioException) {
          final data = apiError.response?.data;
          print('OTP Request API Error Data: $data');
          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'];
          } else if (apiError.response?.statusCode != null) {
            errorMessage = 'Server Error: ${apiError.response?.statusCode}';
          } else {
            errorMessage = apiError.message ?? 'Network Error';
          }
        }
        
        print('OTP Request API Error: $apiError');
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to request OTP: $e',
      );
      return false;
    }
  }

  // Verify OTP and login
  Future<bool> verifyOTP(String mobileNumber, String otp) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final apiService = ref.read(apiServiceProvider);
      try {
        final response = await apiService.verifyOTP(mobileNumber, otp);

        final data = response.data;
        final verification = data['verification'] ?? '';
        
        if (verification.toString().contains('successfully')) {
          // Success! Create a local auth response since the API provides a success string
          final authResponse = AuthResponse(
            token: 'fineract_session_${DateTime.now().millisecondsSinceEpoch}',
            refreshToken: 'refresh_${DateTime.now().millisecondsSinceEpoch}',
            userName: 'SHG Member',
            userId: mobileNumber,
            email: 'member@shg.com',
          );
          
          await apiService.saveToken(
            authResponse.token,
            authResponse.refreshToken,
          );

          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            authResponse: authResponse,
            otpVerified: true,
            otpSent: false,
          );
          return true;
        } else {
          state = state.copyWith(
            isLoading: false,
            error: verification ?? 'Invalid OTP',
          );
          return false;
        }
      } catch (apiError) {
        String errorMsg = 'OTP verification failed';
        if (apiError is DioException) {
          errorMsg = apiError.response?.data?.toString() ?? apiError.message ?? errorMsg;
        }
        state = state.copyWith(
          isLoading: false,
          error: errorMsg,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'OTP verification failed: $e',
      );
      return false;
    }
  }

  // Legacy login method - now delegates to OTP flow
  Future<bool> login(String mobileNumber, String otp) async {
    return verifyOTP(mobileNumber, otp);
  }

  Future<void> logout() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.logout();
      apiService.clearToken();
    } catch (e) {
      // Handle logout error
    } finally {
      state = AuthState();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetOTPFlow() {
    state = state.copyWith(
      otpSent: false,
      mobileNumber: null,
      otpVerified: false,
    );
  }
}
