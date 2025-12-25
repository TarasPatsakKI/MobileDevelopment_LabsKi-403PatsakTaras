import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/api_client.dart';

class AuthService {
  final UserRepository _userRepository;
  final ApiClient? apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthService(this._userRepository, {this.apiClient});

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: fullName,
        email: email,
        password: password,
      );

      final success = await _userRepository.registerUser(user);

      if (!success) {
        return AuthResult(success: false, message: 'Email already exists');
      }

      return AuthResult(
        success: true,
        message: 'Registration successful',
        user: user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _userRepository.loginUser(email, password);

      if (user == null) {
        return AuthResult(success: false, message: 'Invalid email or password');
      }

      // Try to obtain token from remote API if apiClient provided
      if (apiClient != null) {
        try {
          final resp = await apiClient!.post('/auth/login', data: {
            'email': email,
            'password': password,
          });

          if (resp.statusCode == 200 && resp.data != null) {
            final token = resp.data['token']?.toString();
            if (token != null && token.isNotEmpty) {
              await saveToken(token);
              apiClient!.setToken(token);
            }
          }
        } catch (_) {
          // ignore api token errors, local login still works
        }
      }

      return AuthResult(success: true, message: 'Login successful', user: user);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  Future<UserModel?> getCurrentUser() async {
    return await _userRepository.getCurrentUser();
  }

  Future<bool> updateUser(UserModel user) async {
    return await _userRepository.updateUser(user);
  }

  Future<void> logout() async {
    await _userRepository.logout();
    await clearToken();
    apiClient?.clearToken();
  }

  Future<bool> isLoggedIn() async {
    return await _userRepository.isUserLoggedIn();
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }
}

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  AuthResult({required this.success, required this.message, this.user});
}
