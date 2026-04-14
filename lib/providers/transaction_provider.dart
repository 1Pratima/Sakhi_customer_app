import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shg_customer_app/models/transaction.dart';
import 'package:shg_customer_app/models/account.dart';
import 'package:shg_customer_app/providers/service_providers.dart';
import 'package:shg_customer_app/providers/auth_provider.dart';
import 'package:shg_customer_app/providers/user_provider.dart';

// Deposit history provider (Currently using Loan Details associations for more info)
final depositHistoryProvider =
    FutureProvider.family<List<Deposit>, String>((ref, accountId) async {
  try {
    final apiService = ref.read(apiServiceProvider);
    final response = await apiService.getLoanDetails(accountId);
    // Extract deposits from repayment schedule or transactions if available
    return []; // For now return empty until parsing logic is ready
  } catch (e) {
    return [];
  }
});

// Transaction history provider - merges savings + loan transactions
final transactionHistoryProvider =
    FutureProvider.autoDispose<List<Transaction>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final authState = ref.watch(authStateProvider);
  final mobileNumber = authState.mobileNumber;

  if (mobileNumber == null || mobileNumber.isEmpty) return [];

  final List<Transaction> allTransactions = [];

  // --- 1. Savings Transactions from savingsaccounts/{id}?associations=all ---
  try {
    // Re-use the same account fetching logic: get client accounts then fetch each SA detail
    final userProfile = await ref.watch(userProfileProvider.future);
    final overviewResp = await apiService.getClientAccounts(userProfile.id);
    final dynamic respData = overviewResp.data;

    List basicSavings = [];
    if (respData is Map<String, dynamic> && respData.containsKey('savingsAccounts')) {
      basicSavings = respData['savingsAccounts'] as List? ?? [];
    } else if (respData is List) {
      basicSavings = respData;
    }

    for (var basicAcc in basicSavings) {
      if (basicAcc == null) continue;
      final accId = basicAcc['id']?.toString() ?? basicAcc['accountId']?.toString();
      if (accId == null) continue;
      try {
        final detailResp = await apiService.getSavingsAccountDetails(accId);
        final jsonData = detailResp.data as Map<String, dynamic>;
        final txns = jsonData['transactions'] as List? ?? [];
        allTransactions.addAll(
          txns.whereType<Map>().map(
            (t) => Transaction.fromSavingsJson(Map<String, dynamic>.from(t)),
          ),
        );
      } catch (e) {
        print('Error fetching savings transactions for $accId: $e');
      }
    }
  } catch (e) {
    print('Error fetching savings account list: $e');
  }

  // --- 2. Loan Transactions from loans/{loanId}?associations=all ---
  // loanverview only gives us loan IDs; we fetch full details per loan
  // so that we get the actual transactions[] array with correct amounts.
  try {
    final loanOverviewResp = await apiService.getTransactionHistory(mobileNumber);
    final List loanList = loanOverviewResp.data as List;

    for (var loanSummary in loanList) {
      // loanverview returns loanId field
      final loanId = loanSummary['loanId']?.toString() ??
                     loanSummary['id']?.toString();
      if (loanId == null) continue;

      try {
        // GET loans/{loanId}?associations=all&exclude=guarantors,futureSchedule
        final detailResp = await apiService.getLoanDetails(loanId);
        final loanDetail = detailResp.data as Map<String, dynamic>;
        final List txns = loanDetail['transactions'] as List? ?? [];

        // Filter to only user-visible transaction types:
        // Disbursement, Repayment, Recovery Repayment — skip Accrual, Contra, etc.
        const skipTypes = {
          'accrual', 'contra', 'writeoff', 'chargeoff',
          'initiateTransfer', 'approveTransfer', 'withdrawTransfer', 'rejectTransfer',
        };

        for (final rawTxn in txns.whereType<Map>()) {
          final json = Map<String, dynamic>.from(rawTxn);
          final typeObj = json['type'];
          final typeCode = (typeObj is Map)
              ? (typeObj['code']?.toString() ?? '')
              : '';

          // Skip internal accounting entries
          final lowerCode = typeCode.toLowerCase();
          if (skipTypes.any((s) => lowerCode.contains(s))) continue;

          allTransactions.add(Transaction.fromJson(json));
        }
      } catch (e) {
        print('Error fetching loan transactions for loanId=$loanId: $e');
      }
    }
  } catch (e) {
    print('Error fetching loan list: $e');
  }

  // Sort combined list by date descending, then by ID descending to handle same-day transactions correctly
  allTransactions.sort((a, b) {
    int dateComp = b.date.compareTo(a.date);
    if (dateComp != 0) return dateComp;
    // Tie-break with ID (assuming higher ID = later transaction)
    return b.id.compareTo(a.id);
  });
  return allTransactions;
});

// Paginated transactions provider with demo data fallback
final paginatedTransactionsProvider =
    FutureProvider.autoDispose.family<List<Transaction>, int>((ref, page) async {
  try {
    final apiService = ref.read(apiServiceProvider);
    final authState = ref.watch(authStateProvider);
    final mobileNumber = authState.mobileNumber;
    
    if (mobileNumber == null || mobileNumber.isEmpty) return [];
    
    final response = await apiService.getTransactionHistory(mobileNumber);
    final List loans = response.data as List;
    final List<Transaction> allTransactions = [];
    
    for (var loan in loans) {
      final List txns = loan['transactions'] ?? [];
      allTransactions.addAll(txns.whereType<Map>().map((json) => Transaction.fromJson(Map<String, dynamic>.from(json))));
    }
    
    allTransactions.sort((a, b) => b.date.compareTo(a.date));
    return allTransactions;
  } catch (e) {
    // Escalate the backend error to the UI
    rethrow;
  }
});
