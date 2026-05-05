import '../../../core/api/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/room_model.dart';

class PropertyService {
  final ApiClient _apiClient = ApiClient();

  Future<List<RoomModel>> fetchProperties() async {
    try {
      final response = await _apiClient.get('/properties');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => RoomModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      Logger.error('PropertyService.fetchProperties failed', e);
      return [];
    }
  }

  Future<RoomModel?> createProperty(Map<String, dynamic> propertyData) async {
    try {
      final response = await _apiClient.post('/properties', data: propertyData);
      if (response != null && response['id'] != null) {
        return RoomModel.fromJson(response as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Logger.error('PropertyService.createProperty failed', e);
      return null;
    }
  }

  Future<RoomModel?> updateProperty(String id, Map<String, dynamic> propertyData) async {
    try {
      final response = await _apiClient.put('/properties/$id', data: propertyData);
      if (response != null && response['id'] != null) {
        return RoomModel.fromJson(response as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Logger.error('PropertyService.updateProperty failed', e);
      return null;
    }
  }

  Future<bool> deleteProperty(String id) async {
    try {
      final response = await _apiClient.delete('/properties/$id');
      return response != null;
    } catch (e) {
      Logger.error('PropertyService.deleteProperty failed', e);
      return false;
    }
  }
}
