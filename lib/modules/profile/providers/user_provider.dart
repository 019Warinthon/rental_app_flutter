import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../../../core/storage/secure_storage.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  UserModel _user = const UserModel(
    id: '',
    name: 'Guest User',
    email: 'guest@rentspace.com',
    phone: '',
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

    if (_isLoggedIn) {
      try {
        final profile = await _userService.getProfile();
        if (profile != null) {
          _user = profile;
        } else {
          _isLoggedIn = false;
        }
      } catch (e) {
        _isLoggedIn = false;
      }
    } else {
      _user = const UserModel(
        id: '',
        name: 'Guest User',
        email: 'guest@rentspace.com',
        phone: '',
      );
    }
    notifyListeners();
  }

  void clearProfile() {
    _isLoggedIn = false;
    _user = const UserModel(
      id: '',
      name: 'Guest User',
      email: 'guest@rentspace.com',
      phone: '',
    );
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
      final updatedProfile = await _userService.updateProfile(
        name: name,
        email: email,
        phone: phone,
      );

      if (updatedProfile != null) {
        _user = updatedProfile;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
