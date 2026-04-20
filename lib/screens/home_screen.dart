import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.navajyoti.app/providers/account_provider.dart';
import 'package:com.navajyoti.app/providers/user_provider.dart';
import 'package:com.navajyoti.app/providers/transaction_provider.dart';
import 'package:com.navajyoti.app/models/transaction.dart';
import 'package:com.navajyoti.app/utils/theme.dart';
import 'package:com.navajyoti.app/utils/formatters.dart';
import 'package:com.navajyoti.app/widgets/common_widgets.dart';
import 'package:com.navajyoti.app/widgets/account_widgets.dart';
import 'package:com.navajyoti.app/screens/notifications_screen.dart';
import 'package:com.navajyoti.app/screens/loans_list_screen.dart';
import 'package:com.navajyoti.app/screens/savings_accounts_list_screen.dart';
import 'package:com.navajyoti.app/screens/transaction_history_screen.dart';
import 'package:com.navajyoti.app/providers/navigation_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final savingsAccounts = ref.watch(savingsAccountsProvider);
    final loanAccounts = ref.watch(loanAccountsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Branding Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/images/app_logo.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Navajyoti',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                        );
                      },
                      icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: userProfile.when(
                data: (user) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: (user.base64Image != null && user.base64Image!.contains('base64,'))
                          ? MemoryImage(base64Decode(user.base64Image!.split('base64,').last.replaceAll(RegExp(r'\s+'), '')))
                          : NetworkImage(user.profileImage) as ImageProvider,
                    ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (err, _) => const SizedBox.shrink(),
              ),
            ),
          ),

          // Dashboard Overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                    'Financial Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Savings Summary
                      Expanded(
                        child: savingsAccounts.when(
                          data: (accounts) {
                            double totalSavings = accounts.fold(0, (sum, item) => sum + item.yourSavings);
                            return _buildDashboardCard(
                              context,
                              title: 'Total Savings',
                              value: totalSavings,
                              icon: Icons.account_balance_wallet_rounded,
                              colors: AppColors.primaryGradient,
                              onTap: () => ref.read(navigationIndexProvider.notifier).state = 1,
                            );
                          },
                          loading: () => const _DashboardLoadingCard(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Loans Summary
                      Expanded(
                        child: loanAccounts.when(
                          data: (accounts) {
                            double totalLoan = accounts.fold(0, (sum, item) => sum + item.currentBalance);
                            double totalOverdue = accounts.fold(0, (sum, item) => sum + item.totalOverdue);
                            return _buildDashboardCard(
                              context,
                              title: 'Total Loans',
                              value: totalLoan,
                              overdue: totalOverdue > 0 ? totalOverdue : null,
                              icon: Icons.payments_rounded,
                              colors: AppColors.loanGradient,
                              onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
                            );
                          },
                          loading: () => const _DashboardLoadingCard(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: userProfile.when(
                data: (user) => user.sakhiName != null ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    const Text(
                      'Your Sakhi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.support_agent_rounded, color: AppColors.primary),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.sakhiName!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (user.sakhiId != null) ...[
                                const SizedBox(height: 1),
                                Text(
                                  'ID: ${user.sakhiId}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                'Community Leader',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (user.sakhiPhone != null && user.sakhiPhone!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  user.sakhiPhone!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary.withOpacity(0.05),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ) : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),


          SliverPadding(
            padding: const EdgeInsets.only(top: 32),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Recent Activity',
                actionText: 'See All',
                onActionPressed: () {
                  ref.read(navigationIndexProvider.notifier).state = 3;
                },
              ),
            ),
          ),

          // Recent Activity - live data
          ref.watch(transactionHistoryProvider).when(
            data: (txList) {
              final recent = txList.take(3).toList();
              if (recent.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == recent.length) {
                      return const SizedBox(height: 100);
                    }
                    final t = recent[index];
                    final isSavings = t.type == TransactionType.savingsDeposit;
                    return TransactionCard(
                      icon: t.type == TransactionType.savingsDeposit
                          ? '💰'
                          : t.type == TransactionType.disbursement
                              ? '🏦'
                              : '💳',
                      title: t.description,
                      date: DateTimeUtils.formatDate(t.date),
                      amount: t.amount,
                      isCredit: isSavings || t.type == TransactionType.disbursement,
                    );
                  },
                  childCount: recent.length + 1,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: LoadingWidget(),
              ),
            ),
            error: (_, __) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Could not load recent activity',
                  style: TextStyle(color: AppColors.textLight, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Action', style: TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required double value,
    double? overdue,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                if (overdue != null)
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Overdue',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                DateTimeUtils.formatCurrency(value),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (overdue != null) ...[
               const SizedBox(height: 4),
               Text(
                 'Arrears: ${DateTimeUtils.formatCurrency(overdue)}',
                 style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w700,
                 ),
               ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: Colors.white.withOpacity(0.8), size: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardLoadingCard extends StatelessWidget {
  const _DashboardLoadingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.divider.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

