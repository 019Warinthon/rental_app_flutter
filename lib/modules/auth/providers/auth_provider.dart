import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  // ignore: unused_field
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      await _storage.saveToken('dummy_token');
      Logger.log('User logged in successfully: $email');
      return true;
    } catch (e) {
      Logger.error('Login failed', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      await _storage.saveToken('dummy_token');
      Logger.log('User registered successfully: $email');
      return true;
    } catch (e) {
      Logger.error('Registration failed', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    notifyListeners();
  }
}
