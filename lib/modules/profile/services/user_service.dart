import '../../../core/api/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/user_model.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel?> getProfile() async {
    try {
      final response = await _apiClient.get('/auth/me');
      if (response != null && response['user'] != null) {
        final u = response['user'];
        return UserModel(
          id: u['id'] ?? '',
          name: u['name'] ?? '',
          email: u['email'] ?? '',
          phone: u['phone'] ?? '',
        );
      }
      return null;
    } catch (e) {
      Logger.error('UserService.getProfile failed', e);
      rethrow;
    }
  }

  Future<UserModel?> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.put(
        '/auth/me',
        data: {'name': name, 'email': email, 'phone': phone},
      );
      if (response != null && response['user'] != null) {
        final u = response['user'];
        return UserModel(
          id: u['id'] ?? '',
          name: u['name'] ?? '',
          email: u['email'] ?? '',
          phone: u['phone'] ?? '',
        );
      }
      return null;
    } catch (e) {
      Logger.error('UserService.updateProfile failed', e);
      rethrow;
    }
  }
}
