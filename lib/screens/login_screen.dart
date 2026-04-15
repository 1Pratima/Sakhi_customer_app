import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shg_customer_app/providers/auth_provider.dart';
import 'package:shg_customer_app/utils/theme.dart';
import 'package:shg_customer_app/widgets/common_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _mobileController;
  late TextEditingController _otpController;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _requestOTP() {
    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty) {
      _showError('Please enter mobile number');
      return;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      _showError('Mobile number must be 10 digits');
      return;
    }
    ref.read(authStateProvider.notifier).requestOTP(mobile);
  }

  void _verifyOTP() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      _showError('Please enter valid 6-digit OTP');
      return;
    }
    final authState = ref.read(authStateProvider);
    if (authState.mobileNumber != null) {
      ref
          .read(authStateProvider.notifier)
          .verifyOTP(authState.mobileNumber!, otp);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }


  void _resendOTP() {
    final authState = ref.read(authStateProvider);
    if (authState.mobileNumber != null) {
      ref.read(authStateProvider.notifier).requestOTP(authState.mobileNumber!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Listen for errors and show SnackBar
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        _showError(next.error!);
        // Do NOT auto-clear here, let the user see it
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Logo or Icon
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/app_logo.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Animated Switcher for Mobile/OTP
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: !authState.otpSent
                      ? _buildMobileInput(authState)
                      : _buildOTPInput(authState),
                ),

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'SHG Customer Application v1.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileInput(AuthState authState) {
    return Column(
      key: const ValueKey('mobile_input'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Login',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Sign in to your SHG banking account',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 40),
        _buildTextField(
          controller: _mobileController,
          label: 'Mobile Number',
          hint: 'Enter your 10-digit number',
          icon: Icons.phone_android_rounded,
          prefix: '+91 ',
          inputType: TextInputType.phone,
          maxLength: 10,
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 40),
        CustomButton(
          text: 'Get Verification Code',
          isLoading: authState.isLoading,
          onPressed: _requestOTP,
          isSecondary: false,
        ),
      ],
    );
  }

  Widget _buildOTPInput(AuthState authState) {
    return Column(
      key: const ValueKey('otp_input'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => ref.read(authStateProvider.notifier).resetOTPFlow(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            ),
            const Text(
              'Verification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'We have sent a 6-digit code to',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
        ),
        Text(
          '+91 ${authState.mobileNumber}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 40),
        _buildTextField(
          controller: _otpController,
          label: 'OTP Code',
          hint: '000000',
          icon: Icons.lock_outline_rounded,
          inputType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          letterSpacing: 10,
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        const SizedBox(height: 40),
        CustomButton(
          text: 'Verify & Continue',
          isLoading: authState.isLoading,
          onPressed: _verifyOTP,
        ),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: _resendOTP,
            child: const Text(
              'Resend OTP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefix,
    TextInputType inputType = TextInputType.text,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    double? letterSpacing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            maxLength: maxLength,
            textAlign: textAlign,
            cursorColor: Colors.white,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
              letterSpacing: letterSpacing,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white70),
              prefixText: prefix,
              prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              filled: false,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}

