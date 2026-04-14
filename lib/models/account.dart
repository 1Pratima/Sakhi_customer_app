class SavingsAccount {
  final int id;
  final String accountNumber;
  final String groupName;
  final String productName;
  
  final double accountBalance;
  final double totalDeposits;
  final List<Deposit> deposits;

  SavingsAccount({
    required this.id,
    required this.accountNumber,
    required this.groupName,
    required this.productName,
    required this.accountBalance,
    required this.totalDeposits,
    required this.deposits,
  });

  factory SavingsAccount.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final transactions = json['transactions'] as List? ?? [];
    
    return SavingsAccount(
      id: json['id'] as int? ?? 0,
      accountNumber: json['accountNo'] as String? ?? '',
      groupName: json['groupName'] as String? ?? 'Savings Account',
      productName: json['savingsProductName'] as String? ?? '',
      accountBalance: (summary['accountBalance'] as num? ?? 0.0).toDouble(),
      totalDeposits: (summary['totalDeposits'] as num? ?? 0.0).toDouble(),
      deposits: transactions.map((t) => Deposit.fromJson(t as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'accountNo': accountNumber,
    'groupName': groupName,
    'savingsProductName': productName,
    'summary': {
      'accountBalance': accountBalance,
      'totalDeposits': totalDeposits,
    },
    'transactions': deposits.map((d) => d.toJson()).toList(),
  };
  
  // Helpers for UI
  String get accountId => id.toString();
  String get accountName => groupName;
  double get totalSavings => totalDeposits;
  double get yourSavings => accountBalance;
  
  DateTime get lastDeposit {
    if (deposits.isEmpty) return DateTime.now();
    return deposits.reduce((a, b) => a.date.isAfter(b.date) ? a : b).date;
  }
  
  double get averageDeposit {
    if (deposits.isEmpty) return 0.0;
    return deposits.map((d) => d.amount).reduce((a, b) => a + b) / deposits.length;
  }
} // End of SavingsAccount

class Deposit {
  final int id;
  final double amount;
  final String type;
  final DateTime date;
  
  // UI Helper
  String get description => type;

  Deposit({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
  });

  factory Deposit.fromJson(Map<String, dynamic> json) {
    final typeData = json['transactionType'] as Map<String, dynamic>? ?? {};
    final dateArray = json['date'] as List? ?? [];
    
    DateTime parsedDate = DateTime.now();
    if (dateArray.length >= 3) {
      parsedDate = DateTime(dateArray[0], dateArray[1], dateArray[2]);
    }

    return Deposit(
      id: json['id'] as int? ?? 0,
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      type: typeData['value'] as String? ?? 'Deposit',
      date: parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'transactionType': {
      'value': type,
    },
    'date': [date.year, date.month, date.day],
  };
}
