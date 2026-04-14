import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shg_customer_app/utils/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  late Dio _dio;
  late FlutterSecureStorage _secureStorage;

  String get baseUrl => Env.apiBase;
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';

  ApiService() {
    _secureStorage = const FlutterSecureStorage();
    String liveUrl = Env.apiBase;
    if (!liveUrl.endsWith('/')) liveUrl += '/';
    
    print('>>> ApiService INIT at ${DateTime.now()} <<<');
    print('>>> CONNECTING TO: $liveUrl <<<');
    _dio = Dio(BaseOptions(
      baseUrl: liveUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      queryParameters: {
        'tenantIdentifier': 'default', // standard Fineract requirement
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Always use Basic Auth for Fineract operations in this environment
          final String basicAuth = 'Basic ${base64Encode(utf8.encode('admin:password'))}';
          options.headers['Authorization'] = basicAuth;
          options.headers['Content-Type'] = 'application/json';
          options.headers['Fineract-Platform-TenantId'] = 'default';
          return handler.next(options);
        },
        onError: (error, handler) async {
          print('>>> API CONNECTION ERROR: ${error.type} <<<');
          print('>>> MESSAGE: ${error.message} <<<');
          print('>>> STATUS: ${error.response?.statusCode} <<<');
          
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: tokenKey);
  }

  Future<void> saveToken(String token, String refreshToken) async {
    await _secureStorage.write(key: tokenKey, value: token);
    await _secureStorage.write(key: refreshTokenKey, value: refreshToken);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': ''}),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refreshToken'];
        await saveToken(newToken, newRefreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Auth endpoints
  Future<Response> login(String email, String password) {
    return _dio
        .post('/auth/login', data: {'email': email, 'password': password});
  }

  // OTP-based login - Using explicitly requested path: ExternalApi/sendotp
  Future<Response> requestOTP(String mobileNumber) {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('admin:password'))}';
    
    print('>>> SENDING OTP TO: ExternalApi/sendotp <<<');
    
    return _dio.post(
      'ExternalApi/sendotp',
      data: {
        'mobileNumber': mobileNumber,
      },
      options: Options(
        headers: {
          'Fineract-Platform-TenantId': 'default',
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
      ),
    );
  }

  // Verify OTP - Matching Docs: POST /otp/verify
  Future<Response> verifyOTP(String mobileNumber, String otp) {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('admin:password'))}';
    
    print('>>> VERIFYING OTP AT: otp/verify <<<');

    return _dio.post(
      'ExternalApi/verifyotp',
      data: {
        'mobileNumber': mobileNumber,
        'otp': otp,
      },
      options: Options(
        headers: {
          'Fineract-Platform-TenantId': 'default',
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
      ),
    );
  }

  Future<Response> logout() {
    return _dio.post('/auth/logout');
  }

  // User/Client endpoints
  Future<Response> getProfile(String mobileNumber) {
    return _dio.get('clients/mobile', queryParameters: {'mobileNo': mobileNumber});
  }

  Future<Response> getClientById(String clientId) {
    return _dio.get('clients/$clientId', queryParameters: {'associations': 'all'});
  }

  // Accounts endpoints
  Future<Response> getClientAccounts(String clientId) {
    return _dio.get('clients/$clientId/accounts');
  }

  Future<Response> getSavingsAccountDetails(String accountId) {
    return _dio.get('savingsaccounts/$accountId', queryParameters: {'associations': 'all'});
  }

  Future<Response> getLoanAccounts(String mobileNumber) {
    return _dio.get('otp/loanAccount', queryParameters: {'mobileNumber': mobileNumber});
  }

  Future<Response> getLoanOverview(String mobileNumber) {
    return _dio.get('otp/loanverview', queryParameters: {'mobileNumber': mobileNumber});
  }

  Future<Response> getLoanDetails(String loanId) {
    return _dio.get('loans/$loanId', queryParameters: {
      'associations': 'all',
      'exclude': 'guarantors,futureSchedule',
    });
  }

  // Transactions endpoints
  Future<Response> getTransactionHistory(String mobileNumber) {
    // Documentation suggests loanverview returns the full transaction list for all loans
    return _dio.get('otp/loanverview', queryParameters: {'mobileNumber': mobileNumber});
  }

  Future<Response> getSpecificLoanTransactions(String loanId) {
    return _dio.get('loans/$loanId/transactions');
  }

  // Notifications endpoints
  Future<Response> getNotifications() {
    return _dio.get('/notifications');
  }

  Future<Response> markNotificationAsRead(String id) {
    return _dio.put('/notifications/$id/read');
  }

  void clearToken() async {
    await _secureStorage.delete(key: tokenKey);
    await _secureStorage.delete(key: refreshTokenKey);
  }
}
