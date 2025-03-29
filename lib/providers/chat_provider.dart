import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/repositories/user_repository.dart';
import 'package:flutter/material.dart';

import '../models/models_export.dart';
import '../repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final UserRepository _userRepository = UserRepository();

  List<Chat> _chats = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _unreadMessages = 0;
  DocumentSnapshot? _lastMessage;
  bool _hasMoreMessages = true;

  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  int get unreadMessages => _unreadMessages;
  bool get hasMoreMessages => _hasMoreMessages;

  ChatProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final user = await _userRepository.getUserDetails(
      _userRepository.currentUserId!,
    );
    if (user?.role == "admin") {
      fetchChats();
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setLoadingMore(bool value) {
    _isLoadingMore = value;
    notifyListeners();
  }

  // Fetch all chats (Admin only)
  // Props callback to here
  Future<void> fetchChats() async {
    setLoading(true);
    _chats = await _chatRepository.getChatsOnce();
    await fetchUnreadMessagesCount(_userRepository.currentUserId!);
    notifyListeners();
    setLoading(false);
  }

  // Fetch messages with lazy loading
  Future<void> fetchMessages(String userId, {bool loadMore = false}) async {
    if (loadMore && (!_hasMoreMessages || _isLoadingMore)) return;

    if (!loadMore) {
      _messages.clear();
      _lastMessage = null;
      setLoading(true);
    } else {
      setLoadingMore(true);
    }

    await _chatRepository.checkChatExists(userId);

    final newMessages = await _chatRepository.getMessagesWithPagination(
      userId,
      _lastMessage,
    );

    if (newMessages.isEmpty) {
      _hasMoreMessages = false;
    } else {
      for (var msg in newMessages) {
        if (!_messages.any((m) => m.id == msg.id)) {
          _messages.add(msg);
        }
      }
      _lastMessage = newMessages.last.documentSnapshot;
    }

    setLoading(false);
    setLoadingMore(false);
  }

  // Ensure chat exists before opening
  Future<void> ensureChatExists(String userId) async {
    await _chatRepository.checkChatExists(userId);
  }

  // Listen to real-time message updates
  Stream<List<Message>> listenToMessages(String userId) {
    return _chatRepository.listenToMessages(userId).map((messages) {
      _messages = messages;
      notifyListeners();
      return messages;
    });
  }

  // Fetch unread messages count
  Future<void> fetchUnreadMessagesCount(String userId) async {
    _unreadMessages = await _chatRepository.getUnreadMessagesCount(userId);
    notifyListeners();
  }

  // Mark messages as read
  Future<void> markChatAsRead(String userId) async {
    await _chatRepository.markChatAsRead(userId);
    _unreadMessages = 0;
    notifyListeners();
  }

  // Send a message (text & images)
  Future<void> sendMessage(
    String userId,
    String senderId,
    String senderName,
    String message, {
    List<String>? imageUrls,
  }) async {
    try {
      // Send the message to Firestore
      await _chatRepository.sendMessage(
        userId,
        senderId,
        senderName,
        message,
        imageUrls: imageUrls,
      );

      // No need to re-fetch messages here
    } catch (e) {
      debugPrint("Error sending message: $e");
      // Optionally handle errors, e.g., remove the temporary message
    }
  }

  // Add local message for instant UI update
  void addLocalMessage(Message message) {
    debugPrint("Adding local message...");
    _messages.insert(0, message);
    notifyListeners();
  }

  // Replace temporary message with final image URLs after upload
  void replaceTempMessage(Message tempMessage, List<String> finalUrls) {
    debugPrint("Replacing temp message...");
    int index = _messages.indexWhere((msg) => msg.id == tempMessage.id);
    if (index != -1) {
      _messages[index] = Message(
        id: tempMessage.id,
        senderId: tempMessage.senderId,
        senderName: tempMessage.senderName,
        message: tempMessage.message,
        timestamp: tempMessage.timestamp,
        imageUrls: finalUrls,
        isRead: tempMessage.isRead,
      );
      notifyListeners();
    }
  }
}
