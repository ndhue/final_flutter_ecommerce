import 'package:flutter/material.dart';
import 'package:final_ecommerce/models/models_export.dart';

class MockChatProvider extends ChangeNotifier {
  List<Chat> _chats = [];
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  MockChatProvider() {
    _generateMockChats();
  }

  // ✅ Tạo danh sách cuộc trò chuyện giả (Admin View)
  void _generateMockChats() {
    _chats = [
      Chat(
        userId: "user1",
        userName: "Alice",
        lastMessage: "Hello, I need help!",
        lastMessageTimestamp: DateTime.now(),
      ),
      Chat(
        userId: "user2",
        userName: "Bob",
        lastMessage: "Is my order confirmed?",
        lastMessageTimestamp: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      Chat(
        userId: "user3",
        userName: "Charlie",
        lastMessage: "Can I get a refund?",
        lastMessageTimestamp: DateTime.now().subtract(Duration(hours: 1)),
      ),
    ];
    notifyListeners();
  }

  // ✅ Tạo danh sách tin nhắn giả (User View)
  void fetchMockMessages(String userId) {
    _isLoading = true;
    notifyListeners();

    Future.delayed(Duration(seconds: 1), () {
      _messages = [
        Message(
          senderId: userId,
          senderName: "User",
          message: "Hello, I have a problem.",
          imageUrl: "",
          timestamp: DateTime.now().subtract(Duration(minutes: 10)),
        ),
        Message(
          senderId: "admin",
          senderName: "Admin",
          message: "Sure, how can I assist you?",
          imageUrl: "",
          timestamp: DateTime.now().subtract(Duration(minutes: 8)),
        ),
        Message(
          senderId: userId,
          senderName: "User",
          message: "I received the wrong product.",
          imageUrl: "",
          timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        ),
      ];
      _isLoading = false;
      notifyListeners();
    });
  }

  // ✅ Mock Gửi Tin Nhắn
  void sendMockMessage(
    String userId,
    String senderId,
    String senderName,
    String message, {
    String? imageUrl,
  }) {
    final newMessage = Message(
      senderId: senderId,
      senderName: senderName,
      message: message,
      imageUrl: imageUrl ?? "",
      timestamp: DateTime.now(),
    );

    _messages.insert(0, newMessage);
    notifyListeners();
  }
}
