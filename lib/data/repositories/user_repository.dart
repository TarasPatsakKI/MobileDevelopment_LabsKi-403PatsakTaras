import '../models/user_model.dart';

abstract class UserRepository {
  Future<bool> registerUser(UserModel user);
  Future<UserModel?> loginUser(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<bool> updateUser(UserModel user);
  Future<bool> deleteUser(String userId);
  Future<void> logout();
  Future<bool> isUserLoggedIn();
}
