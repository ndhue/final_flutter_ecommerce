import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:flutter/material.dart';

class MockChatProvider extends ChangeNotifier {
  List<Chat> _chats = [];
  final Map<String, List<Message>> _messages = {}; // Store messages per user
  bool _isLoading = false;
  final Map<String, Timestamp> _lastSeenMessageTimestamp =
      {}; // Track last seen per user

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;

  Map<String, List<Message>> get messages => _messages;

  MockChatProvider() {
    _generateMockChats();
  }

  // Generate mock chats
  void _generateMockChats() {
    _chats = [
      Chat(
        userId: "user1",
        userName: "Alice",
        lastMessage: "Hello, I need help!",
        lastMessageTimestamp: Timestamp.now(),
        lastSeenMessageTimestamp: Timestamp(0, 0), // Default: No messages seen
      ),
      Chat(
        userId: "user2",
        userName: "Bob",
        lastMessage: "Is my order confirmed?",
        lastMessageTimestamp: Timestamp.now(),
        lastSeenMessageTimestamp: Timestamp(0, 0),
      ),
    ];

    _messages["user1"] = _generateMockMessages("user1");
    _messages["user2"] = _generateMockMessages("user2");

    notifyListeners();
  }

  // Generate mock messages per user
  List<Message> _generateMockMessages(String userId) {
    return [
      Message(
        senderId: userId,
        senderName: "User",
        message: "Hello, I have a problem.",
        imageUrl: "",
        timestamp: Timestamp.now(),
        isRead: false, // Default unread
      ),
      Message(
        senderId: "admin",
        senderName: "Admin",
        message: "Sure, how can I assist you?",
        imageUrl: "",
        timestamp: Timestamp.now(),
        isRead: false, // Default unread
      ),
    ];
  }

  // Fetch messages and mark as read
  Future<void> fetchMockMessages(String userId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1)); // Simulate network delay

    _messages[userId] ??= _generateMockMessages(userId);

    // Mark all messages as read
    for (var msg in _messages[userId]!) {
      msg.isRead = true;
    }

    _lastSeenMessageTimestamp[userId] = Timestamp.now();
    _isLoading = false;
    notifyListeners();
  }

  // Get unread messages count
  int getUnreadMessagesCount(String userId) {
    if (!_messages.containsKey(userId) ||
        !_lastSeenMessageTimestamp.containsKey(userId)) {
      return 0;
    }

    return _messages[userId]!
        .where(
          (msg) =>
              msg.timestamp.toDate().isAfter(
                _lastSeenMessageTimestamp[userId]!.toDate(),
              ) &&
              !msg.isRead,
        )
        .length;
  }

  // Mark chat as read when user opens chat
  void markChatAsRead(String userId) {
    if (!_messages.containsKey(userId)) return;

    // Mark all messages as read
    for (var message in _messages[userId]!) {
      message.isRead = true;
    }

    // Update last seen timestamp
    _lastSeenMessageTimestamp[userId] = Timestamp.now();

    notifyListeners();
  }

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
      timestamp: Timestamp.now(),
      isRead: senderId == userId, // If sender is user, mark as read
    );

    _messages[userId] ??= [];
    _messages[userId]!.insert(0, newMessage);

    // Update last message info in chat list
    var chatIndex = _chats.indexWhere((chat) => chat.userId == userId);
    if (chatIndex != -1) {
      _chats[chatIndex] = Chat(
        userId: userId,
        userName: _chats[chatIndex].userName,
        lastMessage: message,
        lastMessageTimestamp: Timestamp.now(),
        lastSeenMessageTimestamp:
            _lastSeenMessageTimestamp[userId] ?? Timestamp(0, 0),
      );
    }

    notifyListeners();
  }
}
