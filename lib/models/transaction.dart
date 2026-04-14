enum TransactionType { emiPayment, savingsDeposit, withdrawal, disbursement }

class Transaction {
  final String id;
  final DateTime date;
  final double amount;
  final TransactionType type;
  final String description;
  final String reference;
  final double outstandingBalance;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    required this.reference,
    required this.outstandingBalance,
  });



  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Map transaction type correctly based on Fineract backend strings
    final typeObj = json['type'];
    final typeString = (typeObj != null && typeObj is Map) 
        ? typeObj['value']?.toString() ?? ''
        : json['transactionType']?.toString() ?? '';
        
    TransactionType parsedType = TransactionType.emiPayment; // default fallback
    
    if (typeString.toLowerCase().contains('deposit')) {
      parsedType = TransactionType.savingsDeposit;
    } else if (typeString.toLowerCase().contains('withdraw')) {
      parsedType = TransactionType.withdrawal;
    } else if (typeString.toLowerCase().contains('disburse')) {
      parsedType = TransactionType.disbursement;
    } else if (typeString.toLowerCase().contains('repayment')) {
      parsedType = TransactionType.emiPayment;
    }
    
    // Dates can be string arrays or normal strings in Fineract
    DateTime parsedDate = DateTime.now();
    try {
      final dateVal = json['date'] ?? json['transactionDate'];
      if (dateVal is List) {
         if (dateVal.length >= 3) {
           parsedDate = DateTime(
             int.parse(dateVal[0].toString()), 
             int.parse(dateVal[1].toString()), 
             int.parse(dateVal[2].toString())
           );
         }
      } else if (dateVal != null) {
         parsedDate = DateTime.tryParse(dateVal.toString()) ?? parsedDate;
      }
    } catch (e) {
      // fallback to now if date parsing fails
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    final double amount = parseDouble(json['amount']);
    final double outstanding = parseDouble(json['outstandingLoanBalance'] ?? 
                                           json['runningBalance'] ?? 
                                           json['outstandingBalance']);

    return Transaction(
      id: json['id']?.toString() ?? 'txn',
      date: parsedDate,
      amount: amount,
      outstandingBalance: outstanding,
      type: parsedType,
      description: typeString.isNotEmpty ? typeString : 'Transaction',
      reference: json['loanId']?.toString() ?? json['accountId']?.toString() ?? json['savingsId']?.toString() ?? '',
    );
  }

  /// Factory specifically for savings account transactions from
  /// GET /savingsaccounts/{id}?associations=all
  factory Transaction.fromSavingsJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Parse date array [yyyy, mm, dd]
    DateTime parsedDate = DateTime.now();
    try {
      final dateVal = json['date'];
      if (dateVal is List && dateVal.length >= 3) {
        parsedDate = DateTime(
          int.parse(dateVal[0].toString()),
          int.parse(dateVal[1].toString()),
          int.parse(dateVal[2].toString()),
        );
      }
    } catch (_) {}

    // Transaction type from nested object
    final txTypeObj = json['transactionType'];
    final typeValue = (txTypeObj is Map) ? (txTypeObj['value']?.toString() ?? '') : '';

    TransactionType parsedType = TransactionType.savingsDeposit;
    if (typeValue.toLowerCase().contains('withdraw')) {
      parsedType = TransactionType.withdrawal;
    } else if (typeValue.toLowerCase().contains('interest')) {
      parsedType = TransactionType.emiPayment;
    }

    return Transaction(
      id: json['id']?.toString() ?? 'stxn',
      date: parsedDate,
      amount: parseDouble(json['amount']),
      outstandingBalance: parseDouble(json['runningBalance']),
      type: parsedType,
      description: typeValue.isNotEmpty ? typeValue : 'Savings Deposit',
      reference: json['accountId']?.toString() ?? '',
    );
  }

  get icon {
    switch (type) {
      case TransactionType.emiPayment:
        return '💳';
      case TransactionType.savingsDeposit:
        return '💚';
      case TransactionType.withdrawal:
        return '💸';
      case TransactionType.disbursement:
        return '🏦';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'transactionType': description,
    'date': date.toIso8601String(),
    'outstandingBalance': outstandingBalance,
    'reference': reference,
  };
}
