import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.navajyoti.app/providers/transaction_provider.dart';
import 'package:com.navajyoti.app/providers/account_provider.dart';
import 'package:com.navajyoti.app/models/transaction.dart';
import 'package:com.navajyoti.app/utils/theme.dart';
import 'package:com.navajyoti.app/utils/formatters.dart';
import 'package:com.navajyoti.app/widgets/common_widgets.dart';
import 'package:com.navajyoti.app/widgets/account_widgets.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsAsync = ref.watch(savingsAccountsProvider);
    final loansAsync = ref.watch(loanAccountsProvider);
    final transactionsAsync = ref.watch(transactionHistoryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: transactionsAsync.when(
        data: (transactionList) {
          // Aggregate detailed totals from the dedicated account providers
          double totalSavings = savingsAsync.maybeWhen(
            data: (accounts) => accounts.fold(0.0, (sum, a) => sum + a.yourSavings),
            orElse: () => 0.0,
          );

          double principalOutstanding = 0;
          double interestOutstanding = 0;
          double totalLoanOutstanding = 0;
          double totalLoanRepaid = 0;
          double totalLoanExpected = 0;

          loansAsync.whenData((loans) {
            for (var l in loans) {
              principalOutstanding += l.principalOutstanding;
              interestOutstanding += l.interestOutstanding;
              totalLoanOutstanding += l.totalOutstanding;
              totalLoanRepaid += l.totalRepayment;
              totalLoanExpected += l.totalExpectedRepayment;
            }
          });

          final savingsList = transactionList.where((t) => t.type == TransactionType.savingsDeposit).toList();
          final loanList = transactionList.where((t) => t.type != TransactionType.savingsDeposit).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Icon(Icons.history_rounded, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 14),
                      Text(
                        'Transaction History',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSummaryItem('Savings', totalSavings, Colors.white),
                            _buildSummaryItem('Total Outstanding', totalLoanOutstanding, Colors.white),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.white.withOpacity(0.2), height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSummaryItem('Principal', principalOutstanding, Colors.white.withOpacity(0.9), small: true),
                            _buildSummaryItem('Interest', interestOutstanding, Colors.white.withOpacity(0.9), small: true),
                            _buildSummaryItem('Total Repaid', totalLoanRepaid, Colors.white.withOpacity(0.9), small: true),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: totalLoanExpected > 0 ? (totalLoanRepaid / totalLoanExpected).clamp(0.0, 1.0) : 0,
                            minHeight: 6,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (savingsList.isNotEmpty) ...[
                const SliverPadding(
                  padding: EdgeInsets.only(top: 32, bottom: 8),
                  sliver: SliverToBoxAdapter(
                    child: SectionHeader(title: 'Savings Transactions'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final t = savingsList[index];
                        final isCredit = t.type == TransactionType.savingsDeposit;
                        return TransactionCard(
                          icon: isCredit ? '💰' : '💸',
                          title: t.description,
                          date: DateTimeUtils.formatDateTime(t.date),
                          amount: t.amount,
                          isCredit: isCredit,
                        );
                      },
                      childCount: savingsList.length,
                    ),
                  ),
                ),
              ],

              if (loanList.isNotEmpty) ...[
                const SliverPadding(
                  padding: EdgeInsets.only(top: 32, bottom: 8),
                  sliver: SliverToBoxAdapter(
                    child: SectionHeader(title: 'Loan Transactions'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final t = loanList[index];
                        final isCredit = t.type == TransactionType.disbursement;
                        return TransactionCard(
                          icon: isCredit ? '🏦' : '💳',
                          title: t.description,
                          date: DateTimeUtils.formatDateTime(t.date),
                          amount: t.amount,
                          isCredit: isCredit,
                        );
                      },
                      childCount: loanList.length,
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (err, _) => AppErrorWidget(message: err.toString()),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color amountColor, {bool small = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: small ? 10 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateTimeUtils.formatCurrency(amount),
          style: TextStyle(
            color: amountColor,
            fontSize: small ? 14 : 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

