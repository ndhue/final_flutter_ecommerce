import 'package:flutter/material.dart';

import '../models/models_export.dart';

class MockChatProvider extends ChangeNotifier {
  final Map<String, List<Message>> _messages = {};
  final List<Chat> _chats = [];
  final Map<String, int> _unreadMessagesCount = {};
  bool _isLoading = false;
  bool _hasMoreMessages = true;
  bool _hasFetchedChats = false;

  Map<String, List<Message>> get messages => _messages;
  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  bool get hasMoreMessages => _hasMoreMessages;
  int getUnreadMessages(String userId) => _unreadMessagesCount[userId] ?? 0;

  /// Fetch chat list (Admin)
  Future<void> fetchChats() async {
    if (_hasFetchedChats) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _chats.clear();
    _chats.addAll(
      List.generate(
        5,
        (index) => Chat(
          id: "chat_$index",
          userId: "user_$index",
          userName: "User $index",
          lastMessage: "Last message from User $index",
          lastMessageTimestamp: DateTime.now().subtract(
            Duration(minutes: index * 5),
          ),
          unreadCount: index,
        ),
      ),
    );

    // Update unread messages count
    for (var chat in _chats) {
      _unreadMessagesCount[chat.userId] = chat.unreadCount;
    }

    _isLoading = false;
    _hasFetchedChats = true;
    notifyListeners();
  }

  /// Fetch messages (Lazy Loading)
  Future<void> fetchMockMessages(String userId, {bool loadMore = false}) async {
    if (loadMore && !_hasMoreMessages) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _messages.putIfAbsent(userId, () => []);
    final List<Message> newMessages = List.generate(
      10,
      (index) => Message(
        id: DateTime.now().toString(),
        senderId: index % 2 == 0 ? "admin" : userId,
        senderName: index % 2 == 0 ? "Admin" : "User",
        message: "Mock message $index",
        timestamp: DateTime.now().subtract(Duration(minutes: index * 5)),
        imageUrls: [],
        isRead: index % 2 == 0,
      ),
    );

    _messages[userId]!.insertAll(0, newMessages);

    // Update unread messages count for user
    _unreadMessagesCount[userId] =
        (_unreadMessagesCount[userId] ?? 0) + newMessages.length;

    _isLoading = false;
    _hasMoreMessages = newMessages.isNotEmpty;
    notifyListeners();
  }

  /// Get unread messages count
  Future<void> fetchUnreadMessagesCount(String userId) async {
    _unreadMessagesCount[userId] =
        _messages[userId]?.where((msg) => msg.senderId != userId).length ?? 0;
    notifyListeners();
  }

  /// Add a temporary message before upload completes
  void addLocalMessage(Message tempMessage) {
    _messages.putIfAbsent(tempMessage.senderId, () => []);
    _messages[tempMessage.senderId]!.insert(0, tempMessage);
    notifyListeners();
  }

  /// ✅ Replace the temporary message with uploaded images
  void replaceTempMessage(Message tempMessage, List<String> uploadedImageUrls) {
    if (!_messages.containsKey(tempMessage.senderId)) return;

    int index = _messages[tempMessage.senderId]!.indexOf(tempMessage);
    if (index != -1) {
      _messages[tempMessage.senderId]![index] = tempMessage.copyWith(
        imageUrls: uploadedImageUrls,
      );
      notifyListeners();
    }
  }

  /// ✅ Send message and update unread count
  Future<void> sendMockMessage(
    String userId,
    String senderId,
    String senderName,
    String message, {
    List<String>? imageUrls,
  }) async {
    final newMessage = Message(
      id: DateTime.now().toString(),
      senderId: senderId,
      senderName: senderName,
      message: message,
      timestamp: DateTime.now(),
      imageUrls: imageUrls ?? [],
      isRead: false,
    );

    _messages.putIfAbsent(userId, () => []);
    _messages[userId]!.insert(0, newMessage);

    // ✅ Increase unread count if message is from admin
    if (senderId == "admin") {
      _unreadMessagesCount[userId] = (_unreadMessagesCount[userId] ?? 0) + 1;
    }

    notifyListeners();
  }

  /// Mark chat as read
  void markChatAsRead(String userId) {
    _unreadMessagesCount[userId] = 0;
    notifyListeners();
  }

  /// Listen to real-time updates (Mocked)
  Stream<List<Message>> listenToMessages(String userId) async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield _messages[userId] ?? [];
  }
}
