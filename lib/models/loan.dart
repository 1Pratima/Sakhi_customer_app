class LoanAccount {
  final String loanId;
  final String accountNo;
  final String accountName;
  final double principalDisbursed;
  final double principalPaid;
  final double principalOutstanding;
  final double interestCharged;
  final double interestPaid;
  final double interestOutstanding;
  final double totalExpectedRepayment;
  final double totalRepayment;
  final double totalOutstanding;
  final double totalOverdue;
  final DateTime disbursedDate;
  final double interestRate;
  final int tenureMonths;
  final DateTime expectedEndDate;
  final DateTime nextEmiDue;
  final double monthlyEmi;

  LoanAccount({
    required this.loanId,
    required this.accountNo,
    required this.accountName,
    required this.principalDisbursed,
    required this.principalPaid,
    required this.principalOutstanding,
    required this.interestCharged,
    required this.interestPaid,
    required this.interestOutstanding,
    required this.totalExpectedRepayment,
    required this.totalRepayment,
    required this.totalOutstanding,
    required this.totalOverdue,
    required this.disbursedDate,
    required this.interestRate,
    required this.tenureMonths,
    required this.expectedEndDate,
    required this.nextEmiDue,
    required this.monthlyEmi,
  });

  factory LoanAccount.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    DateTime parseDate(dynamic v) {
      if (v is List && v.length >= 3) {
        return DateTime(v[0], v[1], v[2]);
      }
      if (v != null) {
        return DateTime.tryParse(v.toString()) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final timeline = json['timeline'] as Map<String, dynamic>? ?? {};
    final repaymentSchedule = json['repaymentSchedule'] as Map<String, dynamic>? ?? {};
    final periods = repaymentSchedule['periods'] as List? ?? [];
    
    // Find monthly EMI and next due date from schedule periods
    double emi = 0;
    DateTime nextDue = DateTime.now();
    final now = DateTime.now();
    for (var p in periods) {
      if (emi == 0) emi = parseDouble(p['totalDueForPeriod']);
      final dueDate = parseDate(p['dueDate']);
      if (dueDate.isAfter(now)) {
        nextDue = dueDate;
        emi = parseDouble(p['totalDueForPeriod']);
        break;
      }
    }

    return LoanAccount(
      loanId: json['id']?.toString() ?? '0',
      accountNo: json['accountNo']?.toString() ?? '',
      accountName: json['loanProductName']?.toString() ?? 'SHG Loan',
      principalDisbursed: parseDouble(summary['principalDisbursed']),
      principalPaid: parseDouble(summary['principalPaid']),
      principalOutstanding: parseDouble(summary['principalOutstanding']),
      interestCharged: parseDouble(summary['interestCharged']),
      interestPaid: parseDouble(summary['interestPaid']),
      interestOutstanding: parseDouble(summary['interestOutstanding']),
      totalExpectedRepayment: parseDouble(summary['totalExpectedRepayment']),
      totalRepayment: parseDouble(summary['totalRepayment']),
      totalOutstanding: parseDouble(summary['totalOutstanding']),
      totalOverdue: parseDouble(summary['totalOverdue']),
      disbursedDate: parseDate(timeline['actualDisbursementDate']),
      interestRate: parseDouble(json['annualInterestRate']),
      tenureMonths: json['numberOfRepayments'] as int? ?? 0,
      expectedEndDate: parseDate(timeline['expectedMaturityDate']),
      nextEmiDue: nextDue,
      monthlyEmi: emi,
    );
  }

  // Backward compatibility getter for currentBalance - Now returns Total (Principal + Interest)
  double get currentBalance => totalOutstanding;
  // Backward compatibility getter for loanAmount
  double get loanAmount => totalExpectedRepayment;
}
