import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class AuthService {
  final UserRepository _userRepository;

  AuthService(this._userRepository);

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
  }

  Future<bool> isLoggedIn() async {
    return await _userRepository.isUserLoggedIn();
  }
}

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  AuthResult({required this.success, required this.message, this.user});
}
