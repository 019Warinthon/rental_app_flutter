import '../../../core/api/api_client.dart';
import '../../../core/utils/logger.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<String?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      if (response != null && response['token'] != null) {
        return response['token'] as String;
      }
      return null;
    } catch (e) {
      Logger.error('AuthService.login failed', e);
      rethrow;
    }
  }

  Future<String?> register(String name, String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      if (response != null && response['token'] != null) {
        return response['token'] as String;
      }
      return null;
    } catch (e) {
      Logger.error('AuthService.register failed', e);
      rethrow;
    }
  }

  Future<String?> loginWithGoogle(String email, String name) async {
    try {
      final response = await _apiClient.post(
        '/auth/google',
        data: {'email': email, 'name': name},
      );
      if (response != null && response['token'] != null) {
        return response['token'] as String;
      }
      return null;
    } catch (e) {
      Logger.error('AuthService.loginWithGoogle failed', e);
      rethrow;
    }
  }
}
