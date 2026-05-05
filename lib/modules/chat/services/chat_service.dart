import '../../../core/api/api_client.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../../../core/utils/logger.dart';

class ChatService {
  final ApiClient _api = ApiClient();

  Future<List<ChatModel>> fetchChats() async {
    try {
      final response = await _api.get('/api/chats');
      final List data = response.data['data'];
      return data.map((json) => ChatModel.fromJson(json)).toList();
    } catch (e) {
      Logger.error('fetchChats failed: $e');
      throw Exception('ไม่สามารถดึงรายการแชทได้');
    }
  }

  Future<List<MessageModel>> fetchMessages(String chatId) async {
    try {
      final response = await _api.get('/api/chats/$chatId/messages');
      final List data = response.data['data'];
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      Logger.error('fetchMessages failed: $e');
      throw Exception('ไม่สามารถดึงข้อความได้');
    }
  }

  Future<ChatModel> createOrGetChat(String propertyId, String ownerId) async {
    try {
      final response = await _api.post('/api/chats', data: {
        'propertyId': propertyId,
        'ownerId': ownerId,
      });
      return ChatModel.fromJson(response.data);
    } catch (e) {
      Logger.error('createOrGetChat failed: $e');
      throw Exception('ไม่สามารถเชื่อมต่อแชทได้');
    }
  }
}
