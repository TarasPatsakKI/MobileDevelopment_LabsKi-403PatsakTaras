import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  static const String _usersKey = 'users';
  static const String _currentUserIdKey = 'current_user_id';

  @override
  Future<bool> registerUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      final List<Map<String, dynamic>> usersList = usersJson != null
          ? List<Map<String, dynamic>>.from(jsonDecode(usersJson) as List)
          : [];

      final emailExists = usersList.any((u) => u['email'] == user.email);

      if (emailExists) {
        return false;
      }

      usersList.add(user.toJson());
      await prefs.setString(_usersKey, jsonEncode(usersList));

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        return null;
      }

      final List<Map<String, dynamic>> usersList =
          List<Map<String, dynamic>>.from(jsonDecode(usersJson) as List);

      final userJson = usersList.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => <String, dynamic>{},
      );

      if (userJson.isEmpty) {
        return null;
      }

      final user = UserModel.fromJson(userJson);
      await prefs.setString(_currentUserIdKey, user.id);

      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString(_currentUserIdKey);

      if (currentUserId == null) {
        return null;
      }

      final usersJson = prefs.getString(_usersKey);
      if (usersJson == null) {
        return null;
      }

      final List<Map<String, dynamic>> usersList =
          List<Map<String, dynamic>>.from(jsonDecode(usersJson) as List);

      final userJson = usersList.firstWhere(
        (u) => u['id'] == currentUserId,
        orElse: () => <String, dynamic>{},
      );

      if (userJson.isEmpty) {
        return null;
      }

      return UserModel.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        return false;
      }

      final List<Map<String, dynamic>> usersList =
          List<Map<String, dynamic>>.from(jsonDecode(usersJson) as List);

      final index = usersList.indexWhere((u) => u['id'] == user.id);

      if (index == -1) {
        return false;
      }

      usersList[index] = user.toJson();
      await prefs.setString(_usersKey, jsonEncode(usersList));

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        return false;
      }

      final List<Map<String, dynamic>> usersList =
          List<Map<String, dynamic>>.from(jsonDecode(usersJson) as List);

      usersList.removeWhere((u) => u['id'] == userId);
      await prefs.setString(_usersKey, jsonEncode(usersList));

      final currentUserId = prefs.getString(_currentUserIdKey);
      if (currentUserId == userId) {
        await prefs.remove(_currentUserIdKey);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
  }

  @override
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserIdKey);
  }
}
