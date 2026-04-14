import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _loginKey = 'user_login';
  static const String _rememberMeKey = 'remember_me';

  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  Future<void> saveLoginCredentials(String email, String password) async {
    await _storage.write(
      key: _loginKey,
      value: '$email|$password',
    );
  }

  Future<Map<String, String>?> getLoginCredentials() async {
    final credentials = await _storage.read(key: _loginKey);
    if (credentials == null) {
      return null;
    }

    final parts = credentials.split('|');
    return {
      'email': parts[0],
      'password': parts[1],
    };
  }

  Future<void> clearLoginCredentials() async {
    await _storage.delete(key: _loginKey);
  }

  Future<void> setRememberMe(bool value) async {
    await _storage.write(key: _rememberMeKey, value: value.toString());
  }

  Future<bool> isRememberMeEnabled() async {
    final value = await _storage.read(key: _rememberMeKey);
    return value == 'true';
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
