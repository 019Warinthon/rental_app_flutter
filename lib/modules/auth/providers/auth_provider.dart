import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/logger.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SecureStorage _storage = SecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '1071852180400-veqfjkhh74j258c2bumac9lju34bsql9.apps.googleusercontent.com',
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ── Email / Password Login ─────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.login(email, password);

      if (token != null) {
        await _storage.saveToken(token);
        Logger.log('User logged in successfully: $email');
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Login failed', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Register ───────────────────────────────────────────────
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.register(name, email, password);

      if (token != null) {
        await _storage.saveToken(token);
        Logger.log('User registered successfully: $email');
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Registration failed', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Google Sign-In (จริง) ──────────────────────────────────
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // เปิด Google Sign-In popup จริง
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // ผู้ใช้กด Cancel
        return false;
      }

      final String email = googleUser.email;
      final String name = googleUser.displayName ?? email.split('@').first;

      Logger.log('Google Sign-In: $email ($name)');

      // ส่ง email + name ไปที่ Backend
      final token = await _authService.loginWithGoogle(email, name);

      if (token != null) {
        await _storage.saveToken(token);
        Logger.log('Google login success: $email');
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Google Sign-In failed', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Logout ─────────────────────────────────────────────────
  Future<void> logout() async {
    await _storage.deleteToken();
    // Sign out จาก Google ด้วย (เพื่อให้ Next time ต้อง choose account ใหม่)
    await _googleSignIn.signOut();
    notifyListeners();
  }
}
