import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shg_customer_app/utils/theme.dart';
import 'package:shg_customer_app/utils/formatters.dart';
import 'package:shg_customer_app/widgets/common_widgets.dart';
import 'package:shg_customer_app/providers/service_providers.dart';

// Provider that fetches loan detail with full schedule
final loanScheduleProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, loanId) async {
  final apiService = ref.read(apiServiceProvider);
  final response = await apiService.getLoanDetails(loanId);
  return response.data as Map<String, dynamic>;
});

// Helper to parse Fineract date arrays
DateTime _parseDate(dynamic val) {
  if (val is List && val.length >= 3) {
    return DateTime(
      int.parse(val[0].toString()),
      int.parse(val[1].toString()),
      int.parse(val[2].toString()),
    );
  }
  return DateTime.now();
}

double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is double) return val;
  if (val is int) return val.toDouble();
  return double.tryParse(val.toString()) ?? 0.0;
}

class LoanScheduleScreen extends ConsumerWidget {
  final String loanId;
  final String accountNo;

  const LoanScheduleScreen({
    Key? key,
    required this.loanId,
    required this.accountNo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAsync = ref.watch(loanScheduleProvider(loanId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: loanAsync.when(
        data: (loan) {
          final summary = loan['summary'] as Map<String, dynamic>? ?? {};
          final schedule = loan['repaymentSchedule'] as Map<String, dynamic>? ?? {};
          final periods = (schedule['periods'] as List? ?? [])
              .whereType<Map>()
              .where((p) => p.containsKey('period')) // skip disbursement period
              .toList();

          final totalOutstanding = _parseDouble(summary['totalOutstanding']);
          final totalRepayment = _parseDouble(summary['totalRepayment']);
          final totalExpected = _parseDouble(summary['totalExpectedRepayment']);
          final progress = totalExpected > 0 ? totalRepayment / totalExpected : 0.0;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Repayment Schedule',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Loan ID: $loanId  •  A/c: $accountNo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Summary row
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _headerStat('Total', DateTimeUtils.formatCurrency(totalExpected)),
                                _headerStat('Paid', DateTimeUtils.formatCurrency(totalRepayment)),
                                _headerStat('Outstanding', DateTimeUtils.formatCurrency(totalOutstanding)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 7,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${(progress * 100).toStringAsFixed(1)}% Repaid',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Column Headers
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      _colHeader('#', flex: 1),
                      _colHeader('Due Date', flex: 3),
                      _colHeader('EMI', flex: 3),
                      _colHeader('Balance', flex: 3),
                      _colHeader('Status', flex: 3),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 1),
                ),
              ),

              // Schedule Rows
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final period = Map<String, dynamic>.from(periods[index]);
                      final periodNo = period['period'] ?? (index + 1);
                      final dueDate = _parseDate(period['dueDate']);
                      final totalDue = _parseDouble(period['totalDueForPeriod']);
                      final totalPaid = _parseDouble(period['totalPaidForPeriod']);
                      final balanceOutstanding = _parseDouble(period['principalLoanBalanceOutstanding']);
                      final isComplete = period['complete'] == true;
                      final isOverdue = !isComplete && dueDate.isBefore(DateTime.now());

                      Color statusColor = isComplete
                          ? AppColors.success
                          : isOverdue
                              ? AppColors.error
                              : AppColors.textLight;
                      String statusLabel = isComplete ? 'Paid' : isOverdue ? 'Overdue' : 'Pending';
                      IconData statusIcon = isComplete
                          ? Icons.check_circle_rounded
                          : isOverdue
                              ? Icons.warning_rounded
                              : Icons.radio_button_unchecked_rounded;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          color: isComplete
                              ? AppColors.success.withOpacity(0.05)
                              : isOverdue
                                  ? AppColors.error.withOpacity(0.05)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isComplete
                                ? AppColors.success.withOpacity(0.2)
                                : isOverdue
                                    ? AppColors.error.withOpacity(0.2)
                                    : AppColors.divider.withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '$periodNo',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                DateTimeUtils.formatDate(dueDate),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  DateTimeUtils.formatCurrency(totalDue),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  DateTimeUtils.formatCurrency(balanceOutstanding),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: balanceOutstanding > 0 ? AppColors.textDark : AppColors.success,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, color: statusColor, size: 13),
                                  const SizedBox(width: 3),
                                  Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: periods.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(loanScheduleProvider(loanId)),
        ),
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
      ],
    );
  }

  Widget _colHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textGray,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
