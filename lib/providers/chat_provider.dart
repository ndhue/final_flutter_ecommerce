import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/repositories/chat_repository.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();

  List<Chat> _chats = [];
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  // Fetch Chats (Admin side)
  Future<void> fetchChats() async {
    _isLoading = true;
    notifyListeners();

    _chats = await _chatRepository.getChatsOnce();
    _isLoading = false;
    notifyListeners();
  }

  // Fetch messages in one chat
  Future<void> fetchMessages(String userId) async {
    _isLoading = true;
    notifyListeners();

    _messages = await _chatRepository.getMessagesOnce(userId);
    _isLoading = false;
    notifyListeners();
  }

  // Send message
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
    await fetchMessages(userId); // Re-fetch messages
  }
}
