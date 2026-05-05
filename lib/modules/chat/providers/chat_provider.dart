import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../../profile/providers/user_provider.dart';
import '../../../core/utils/logger.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  UserProvider? _userProvider;
  
  List<ChatModel> _chats = [];
  List<MessageModel> _currentMessages = [];
  bool _isLoading = false;
  ChatModel? _currentChat;
  
  IO.Socket? _socket;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  ChatModel? get currentChat => _currentChat;
  
  void updateProxy(UserProvider userProvider) {
    _userProvider = userProvider;
    if (_userProvider?.user == null) {
      _chats = [];
      _disconnectSocket();
    } else {
      fetchChats();
      _connectSocket();
    }
    notifyListeners();
  }

  void _connectSocket() {
    if (_socket != null && _socket!.connected) return;
    
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
    _socket = IO.io(baseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build()
    );

    _socket?.connect();

    _socket?.onConnect((_) {
      Logger.log('Socket connected: ${_socket?.id}');
    });

    _socket?.on('receive_message', (data) {
      if (_currentChat != null && data['chatId'] == _currentChat!.id) {
        final newMessage = MessageModel.fromJson(data);
        // Avoid duplicates
        if (!_currentMessages.any((m) => m.id == newMessage.id)) {
           _currentMessages.add(newMessage);
           notifyListeners();
        }
      }
      // Also fetch chats to update the "lastMessage" preview
      fetchChats();
    });

    _socket?.onDisconnect((_) {
      Logger.log('Socket disconnected');
    });
  }

  void _disconnectSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  Future<void> fetchChats() async {
    if (_userProvider?.user == null) return;
    try {
      _chats = await _chatService.fetchChats();
      notifyListeners();
    } catch (e) {
      Logger.error('fetchChats error: $e');
    }
  }

  Future<void> openChat(String propertyId, String ownerId) async {
    if (_userProvider?.user == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _currentChat = await _chatService.createOrGetChat(propertyId, ownerId);
      _currentMessages = await _chatService.fetchMessages(_currentChat!.id);
      
      // Join socket room
      _socket?.emit('join_chat', _currentChat!.id);
    } catch (e) {
      Logger.error('openChat error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openChatByModel(ChatModel chat) async {
    _isLoading = true;
    _currentChat = chat;
    notifyListeners();

    try {
      _currentMessages = await _chatService.fetchMessages(chat.id);
      _socket?.emit('join_chat', chat.id);
    } catch (e) {
      Logger.error('openChatByModel error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void leaveChat() {
    if (_currentChat != null) {
      _socket?.emit('leave_chat', _currentChat!.id);
      _currentChat = null;
      _currentMessages = [];
      notifyListeners();
    }
  }

  void sendMessage(String text) {
    if (_currentChat == null || _userProvider?.user == null || text.isEmpty) return;
    
    _socket?.emit('send_message', {
      'chatId': _currentChat!.id,
      'senderId': _userProvider!.user!.id,
      'text': text,
    });
  }
}
