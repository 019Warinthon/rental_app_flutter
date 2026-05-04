import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../../../core/storage/secure_storage.dart';

class UserProvider extends ChangeNotifier {
  UserModel _user = const UserModel(
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+66 81 234 5678',
  );

  bool _isSaving = false;

  UserModel get user => _user;
  bool get isSaving => _isSaving;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  UserProvider() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final storage = SecureStorage();
    final token = await storage.getToken();
    _isLoggedIn = token != null && token.isNotEmpty;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      _user = _user.copyWith(name: name, email: email, phone: phone);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
