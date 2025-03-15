import 'package:final_ecommerce/models/models_export.dart';
import 'package:flutter/material.dart';

import '../repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();

  List<Chat> _chats = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  int _unreadMessages = 0;

  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  int get unreadMessages => _unreadMessages;

  ChatProvider() {
    fetchChats();
  }

  // Fetch chat list for Admin
  Future<void> fetchChats() async {
    _isLoading = true;
    notifyListeners();

    _chats = await _chatRepository.getChatsOnce();
    _isLoading = false;
    notifyListeners();
  }

  // Fetch messages for a specific user
  Future<void> fetchMessages(String userId) async {
    _isLoading = true;
    notifyListeners();

    _messages = await _chatRepository.getMessagesOnce(userId);
    _unreadMessages = await getUnreadMessagesCount(
      userId,
    ); // Fetch unread count
    _isLoading = false;
    notifyListeners();
  }

  // Get unread messages count
  Future<int> getUnreadMessagesCount(String userId) async {
    return await _chatRepository.getUnreadMessagesCount(userId);
  }

  // Mark chat as read when user opens chat
  Future<void> markChatAsRead(String userId) async {
    await _chatRepository.markChatAsRead(userId);
    _unreadMessages = 0;
    notifyListeners();
  }

  // Send message and update unread count
  Future<void> sendMessage(
    String userId,
    String senderId,
    String senderName,
    String message, {
    String? imageUrl,
  }) async {
    await _chatRepository.sendMessage(
      userId,
      senderId,
      senderName,
      message,
      imageUrl: imageUrl,
    );
    await fetchMessages(userId);
  }
}
