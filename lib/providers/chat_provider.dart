import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/models_export.dart';
import '../repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();

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
    fetchChats();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setLoadingMore(bool value) {
    _isLoadingMore = value;
    notifyListeners();
  }

  Future<void> fetchChats() async {
    setLoading(true);
    _chats = await _chatRepository.getChatsOnce();
    setLoading(false);
  }

  // Fetch messages with lazy loading
  Future<void> fetchMessages(String userId, {bool loadMore = false}) async {
    if (loadMore && (!_hasMoreMessages || _isLoadingMore)) return;

    if (!loadMore) {
      _messages = [];
      _lastMessage = null;
      setLoading(true);
    } else {
      setLoadingMore(true);
    }

    final newMessages = await _chatRepository.getMessagesWithPagination(
      userId,
      _lastMessage,
    );

    if (newMessages.isNotEmpty) {
      _messages.insertAll(_messages.length, newMessages);
      _lastMessage = newMessages.last.documentSnapshot;
    } else {
      _hasMoreMessages = false; // Không còn tin nhắn để load
    }

    setLoading(false);
    setLoadingMore(false);
  }

  // real-time messages
  Stream<List<Message>> listenToMessages(String userId) {
    return _chatRepository.listenToMessages(userId).map((messages) {
      _messages = messages;
      notifyListeners();
      return messages;
    });
  }

  Future<void> fetchUnreadMessagesCount(String userId) async {
    _unreadMessages = await _chatRepository.getUnreadMessagesCount(userId);
    notifyListeners();
  }

  Future<void> markChatAsRead(String userId) async {
    await _chatRepository.markChatAsRead(userId);
    _unreadMessages = 0;
    notifyListeners();
  }

  Future<void> sendMessage(
    String userId,
    String senderId,
    String senderName,
    String message, {
    List<String>? imageUrls,
  }) async {
    await _chatRepository.sendMessage(
      userId,
      senderId,
      senderName,
      message,
      imageUrls: imageUrls,
    );
    await fetchMessages(userId, loadMore: false); // Cập nhật danh sách tin nhắn
  }

  void addLocalMessage(Message message) {
    _messages.insert(0, message); // Add to top
    notifyListeners();
  }

  void replaceTempMessage(Message tempMessage, List<String> finalUrls) {
    int index = _messages.indexOf(tempMessage);
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
