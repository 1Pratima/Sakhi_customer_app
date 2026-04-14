import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shg_customer_app/providers/auth_provider.dart';
import 'package:shg_customer_app/providers/user_provider.dart';
import 'package:shg_customer_app/utils/theme.dart';
import 'package:shg_customer_app/utils/formatters.dart';
import 'package:shg_customer_app/widgets/common_widgets.dart';
import 'package:shg_customer_app/screens/notifications_screen.dart';
import 'package:shg_customer_app/screens/help_support_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: userProfile.when(
        data: (user) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Premium Profile Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                          ),
                        ],
                        image: DecorationImage(
                          image: (user.base64Image != null && user.base64Image!.contains('base64,'))
                             ? MemoryImage(base64Decode(user.base64Image!.split('base64,').last.replaceAll(RegExp(r'\s+'), '')))
                             : NetworkImage(user.profileImage) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.memberType,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile Sections
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SectionHeader(title: 'Personal Information'),
                  CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildProfileItem(
                            Icons.person_outline, 'Full Name', user.name),
                        const Divider(height: 1),
                        _buildProfileItem(
                            Icons.email_outlined, 'Email', user.email),
                        const Divider(height: 1),
                        _buildProfileItem(
                            Icons.phone_android_rounded, 'Phone', user.phone),
                        const Divider(height: 1),
                        _buildProfileItem(Icons.numbers_rounded,
                            'Account No', user.accountNumber),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user.sakhiName != null) ...[
                    const SectionHeader(title: 'Community Support'),
                    CustomCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _buildProfileItem(
                            Icons.support_agent_rounded,
                            'Your Sakhi',
                            user.sakhiName!,
                          ),
                          const Divider(height: 1),
                          _buildProfileItem(
                            Icons.phone_rounded,
                            'Sakhi Contact',
                            user.sakhiPhone ?? 'Not Provided',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SectionHeader(title: 'Settings'),
                  CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildSettingItem(
                          context,
                          Icons.notifications_active_outlined,
                          'Notifications',
                          'Manage your alert preferences',
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const NotificationsScreen()),
                          ),
                        ),
                        _buildSettingItem(
                          context,
                          Icons.help_center_outlined,
                          'Help & Support',
                          'FAQs and direct support',
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const HelpSupportScreen()),
                          ),
                        ),
                        const Divider(height: 1),
                        _buildSettingItem(
                          context,
                          Icons.info_outline_rounded,
                          'About App',
                          'Version 1.0.0 (Build 12)',
                          () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Logout',
                    onPressed: () =>
                        ref.read(authStateProvider.notifier).logout(),
                    isSecondary: true,
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
        loading: () => const LoadingWidget(),
        error: (err, _) => AppErrorWidget(message: err.toString()),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textLight),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textLight,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.divider, size: 20),
    );
  }
}

