import '../../../core/api/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../home/models/room_model.dart';

class FavoriteService {
  final ApiClient _apiClient = ApiClient();

  Future<List<RoomModel>> fetchFavorites(String userId) async {
    try {
      final response = await _apiClient.get('/favorites', queryParameters: {'userId': userId});
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => RoomModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      Logger.error('FavoriteService.fetchFavorites failed', e);
      return [];
    }
  }

  Future<bool> addFavorite(String userId, String propertyId) async {
    try {
      final response = await _apiClient.post('/favorites', data: {
        'userId': userId,
        'propertyId': propertyId,
      });
      return response != null;
    } catch (e) {
      Logger.error('FavoriteService.addFavorite failed', e);
      return false;
    }
  }

  Future<bool> removeFavorite(String userId, String propertyId) async {
    try {
      // Dio delete with body can be done using data parameter
      final response = await _apiClient.delete('/favorites', data: {
        'userId': userId,
        'propertyId': propertyId,
      });
      return response != null;
    } catch (e) {
      Logger.error('FavoriteService.removeFavorite failed', e);
      return false;
    }
  }
}
