import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

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
  Future<void> fetchChats() async {
    setLoading(true);
    final rawChats = await _chatRepository.getChatsOnce();

    _chats = await Future.wait(
      rawChats.map((chat) async {
        final customer = await _userRepository.getUserDetails(chat.userId);
        return Chat(
          id: chat.id,
          userId: chat.userId,
          userName: customer?.fullName ?? "Unknown", 
          lastMessage: chat.lastMessage,
          lastMessageTimestamp: chat.lastMessageTimestamp,
          unreadCount: chat.unreadCount,
        );
      }),
    );

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
    // Add debounce time to reduce excessive updates
    return _chatRepository
        .listenToMessages(userId)
        .debounce((_) => TimerStream(true, const Duration(milliseconds: 500)))
        .map((messages) {
          // Only update if the message list actually changed
          if (_messagesChanged(messages)) {
            _messages = messages;
            notifyListeners();
          }
          return messages;
        });
  }

  // Listen to real-time chat updates
  Stream<List<Chat>> listenToChats() {
    return _chatRepository
        .listenToChats()
        .map((rawChats) async {
          final updatedChats = await Future.wait(
            rawChats.map((chat) async {
              final customer = await _userRepository.getUserDetails(
                chat.userId,
              );
              return Chat(
                id: chat.id,
                userId: chat.userId,
                userName: customer?.fullName ?? "Unknown",
                lastMessage: chat.lastMessage,
                lastMessageTimestamp: chat.lastMessageTimestamp,
                unreadCount: chat.unreadCount,
              );
            }),
          );

          _chats = updatedChats;
          notifyListeners();

          return updatedChats;
        })
        .switchMap((future) => Stream.fromFuture(future));
  }

  bool _messagesChanged(List<Message> newMessages) {
    if (newMessages.length != _messages.length) return true;

    for (int i = 0; i < newMessages.length; i++) {
      if (i >= _messages.length || newMessages[i].id != _messages[i].id) {
        return true;
      }
    }

    return false;
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
    // Insert at index 0 to show at the bottom of the ListView (which is reversed)
    _messages.insert(0, message);

    // Update the chat list UI if this is a new chat or affects the last message
    final existingChatIndex = _chats.indexWhere(
      (chat) => chat.userId == message.senderId,
    );
    if (existingChatIndex != -1) {
      // Update existing chat's last message data
      _chats[existingChatIndex] = _chats[existingChatIndex].copyWith(
        lastMessage: message.message.isNotEmpty ? message.message : 'Image',
        lastMessageTimestamp: message.timestamp,
      );
    }

    notifyListeners();
  }

  // Replace temporary message with final image URLs after upload
  void replaceTempMessage(Message tempMessage, List<String> finalUrls) {
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

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
