import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.navajyoti.app/utils/env.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:com.navajyoti.app/providers/auth_provider.dart';
import 'package:com.navajyoti.app/screens/login_screen.dart';
import 'package:com.navajyoti.app/screens/home_screen.dart';
import 'package:com.navajyoti.app/screens/transaction_history_screen.dart';
import 'package:com.navajyoti.app/screens/notifications_screen.dart';
import 'package:com.navajyoti.app/screens/profile_screen.dart';
import 'package:com.navajyoti.app/screens/savings_accounts_list_screen.dart';
import 'package:com.navajyoti.app/screens/loans_list_screen.dart';
import 'package:com.navajyoti.app/utils/theme.dart';
import 'package:com.navajyoti.app/utils/constants.dart';
import 'package:com.navajyoti.app/providers/service_providers.dart';
import 'package:com.navajyoti.app/providers/navigation_provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => Env.allowBadCerts;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue even if Firebase fails
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize Firebase Services early
    ref.watch(firebaseServiceProvider);

    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: authState.isAuthenticated
          ? const BottomNavigation()
          : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BottomNavigation extends ConsumerWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  static const List<Widget> _screens = [
    HomeScreen(),
    SavingsAccountsListScreen(),
    LoansListScreen(),
    TransactionHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[selectedIndex],
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) =>
                ref.read(navigationIndexProvider.notifier).state = index,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textLight.withOpacity(0.7),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            elevation: 0,
            items: [
              _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
              _buildNavItem(Icons.account_balance_wallet_rounded,
                  Icons.account_balance_wallet_outlined, 'Savings'),
              _buildNavItem(
                  Icons.payments_rounded, Icons.payments_outlined, 'Loans'),
              _buildNavItem(
                  Icons.history_rounded, Icons.history_outlined, 'History'),
              _buildNavItem(
                  Icons.person_rounded, Icons.person_outlined, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData activeIcon, IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(activeIcon, color: AppColors.primary),
      ),
      label: label,
    );
  }
}
