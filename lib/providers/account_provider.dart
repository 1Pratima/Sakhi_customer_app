import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.navajyoti.app/models/account.dart';
import 'package:com.navajyoti.app/models/loan.dart';
import 'package:com.navajyoti.app/providers/service_providers.dart';
import 'package:com.navajyoti.app/providers/auth_provider.dart';
import 'package:com.navajyoti.app/providers/user_provider.dart';

// Savings accounts provider with fallback demo data
final savingsAccountsProvider =
    FutureProvider<List<SavingsAccount>>((ref) async {
  try {
    final apiService = ref.read(apiServiceProvider);
    
    // Authenticate and get the real client profile from backend using Mobile Number
    final userProfile = await ref.watch(userProfileProvider.future);
    
    // Fetch all overview accounts linked to the user's specific Client ID
    final overviewResp = await apiService.getClientAccounts(userProfile.id);
    dynamic respData = overviewResp.data;
    
    List basicSavings = [];
    if (respData is Map<String, dynamic> && respData.containsKey('savingsAccounts')) {
      basicSavings = respData['savingsAccounts'] as List? ?? [];
    } else if (respData is List) {
      basicSavings = respData;
    }
    
    List<SavingsAccount> fullyDetailedAccounts = [];
    
    // Iterate over fetched accounts and dynamically pull their deep details models
    for (var basicAcc in basicSavings) {
      if (basicAcc == null) continue;
      final accId = basicAcc['id']?.toString() ?? basicAcc['accountId']?.toString();
      if (accId == null) continue;
      
      try {
        final detailResp = await apiService.getSavingsAccountDetails(accId);
        final jsonData = detailResp.data as Map<String, dynamic>;
        fullyDetailedAccounts.add(SavingsAccount.fromJson(jsonData));
      } catch (innerError) {
        print('Error fetching detailed savings account $accId: $innerError');
      }
    }
    
    return fullyDetailedAccounts;
  } catch (e) {
    // Escalate the backend error to the UI
    rethrow;
  }

});

// Loan accounts provider
final loanAccountsProvider = FutureProvider<List<LoanAccount>>((ref) async {
  try {
    final apiService = ref.read(apiServiceProvider);
    final userProfile = await ref.watch(userProfileProvider.future);

    // Fetch account overview to find all loans
    final overviewResp = await apiService.getClientAccounts(userProfile.id);
    dynamic respData = overviewResp.data;

    List basicLoans = [];
    if (respData is Map<String, dynamic> && respData.containsKey('loanAccounts')) {
      basicLoans = respData['loanAccounts'] as List? ?? [];
    }
    
    List<LoanAccount> detailedLoans = [];
    for (var basic in basicLoans) {
      final id = basic['id']?.toString();
      if (id == null) continue;
      
      try {
        final detailResp = await apiService.getLoanDetails(id);
        detailedLoans.add(LoanAccount.fromJson(detailResp.data));
      } catch (e) {
        print('Error fetching loan $id detail: $e');
      }
    }
    
    return detailedLoans;
  } catch (e) {
    rethrow;
  }
});

// Deposit history provider
final depositHistoryProvider =
    FutureProvider.family<List<Deposit>, String>((ref, accountId) async {
  try {
    final apiService = ref.read(apiServiceProvider);
    final response = await apiService.getLoanDetails(accountId);
    // In Fineract, 'deposits' for a loan are often listed as transactions or schedule events
    // For now returning mock/empty until the parsing logic for 'loanDetails' is mapped
    return [];
  } catch (e) {
    return [];
  }
});

// Refresh accounts
final refreshAccountsProvider =
    StateNotifierProvider<RefreshNotifier, bool>((ref) {
  return RefreshNotifier(ref);
});

class RefreshNotifier extends StateNotifier<bool> {
  final Ref ref;

  RefreshNotifier(this.ref) : super(false);

  void refreshAll() {
    ref.invalidate(savingsAccountsProvider);
    ref.invalidate(loanAccountsProvider);
    state = !state;
  }
}
