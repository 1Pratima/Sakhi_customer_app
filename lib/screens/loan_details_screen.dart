import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.navajyoti.app/providers/account_provider.dart';
import 'package:com.navajyoti.app/utils/theme.dart';
import 'package:com.navajyoti.app/utils/formatters.dart';
import 'package:com.navajyoti.app/widgets/common_widgets.dart';
import 'package:com.navajyoti.app/screens/loan_schedule_screen.dart';
import 'package:com.navajyoti.app/providers/transaction_provider.dart';

class LoanDetailsScreen extends ConsumerWidget {
  final String loanId;

  const LoanDetailsScreen({
    Key? key,
    required this.loanId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAccounts = ref.watch(loanAccountsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: loanAccounts.when(
        data: (accounts) {
          final loan = accounts.firstWhere((l) => l.loanId == loanId,
              orElse: () => accounts.first);

          final progress = loan.loanAmount > 0
              ? ((loan.loanAmount - loan.currentBalance) / loan.loanAmount).clamp(0.0, 1.0)
              : 0.0;
          final monthsRemaining = (loan.tenureMonths -
              (DateTime.now().difference(loan.disbursedDate).inDays / 30).ceil())
              .clamp(0, loan.tenureMonths);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.loanGradient,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.loanGradient.first.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Loan Details',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Loan ID badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.tag_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'Loan ID: $loanId',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Balance
                      Text(
                        'Outstanding Balance',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateTimeUtils.formatCurrency(loan.currentBalance),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}% repaid',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Loan Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Loan Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Loan Amount', DateTimeUtils.formatCurrency(loan.principalDisbursed)),
                        _buildDetailRow('Disbursed On', DateTimeUtils.formatDate(loan.disbursedDate)),
                        _buildDetailRow('Tenure', '${loan.tenureMonths} months'),
                        _buildDetailRow('Interest Rate (p.a.)', DateTimeUtils.formatPercentage(loan.interestRate)),
                        const Divider(height: 24),
                        _buildDetailRow('Principal Outstanding', DateTimeUtils.formatCurrency(loan.principalOutstanding)),
                        _buildDetailRow('Interest Outstanding', DateTimeUtils.formatCurrency(loan.interestOutstanding)),
                        _buildDetailRow('Total Outstanding', DateTimeUtils.formatCurrency(loan.totalOutstanding), isBold: true),
                        const Divider(height: 24),
                        _buildDetailRow('Monthly EMI', DateTimeUtils.formatCurrency(loan.monthlyEmi)),
                        _buildDetailRow('Next EMI Due', DateTimeUtils.formatDate(loan.nextEmiDue)),
                        _buildDetailRow('Expected End Date', DateTimeUtils.formatDate(loan.expectedEndDate)),
                        _buildDetailRow('Months Remaining', '$monthsRemaining months'),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Action Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // View Schedule - PRIMARY ACTION
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LoanScheduleScreen(
                                  loanId: loanId,
                                  accountNo: loan.loanId,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month_rounded, size: 20),
                          label: const Text('View Repayment Schedule'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (err, _) => AppErrorWidget(message: err.toString()),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textGray),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: isBold ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
