import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all chats (for Admin)
  Future<List<Chat>> getChatsOnce() async {
    final snapshot = await _firestore.collection('chats').get();
    return snapshot.docs.map((doc) => Chat.fromMap(doc.data())).toList();
  }

  // Fetch messages (lazy loading)
  Future<List<Message>> getMessagesWithPagination(
    String userId,
    DocumentSnapshot? lastMessage,
  ) async {
    try {
      Query query = _firestore
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(10);

      if (lastMessage != null) {
        query = query.startAfterDocument(lastMessage);
      }

      QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs
          .map(
            (doc) =>
                Message.fromMap(doc.data() as Map<String, dynamic>)
                  ..documentSnapshot = doc,
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Listen for real-time message updates
  Stream<List<Message>> listenToMessages(String userId) {
    return _firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .debounceTime(
          const Duration(milliseconds: 1000),
        ) // Reduce excessive updates
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList(),
        );
  }

  // Get unread messages count
  Future<int> getUnreadMessagesCount(String userId) async {
    final snapshot =
        await _firestore
            .collection('chats')
            .doc(userId)
            .collection('messages')
            .where('isRead', isEqualTo: false)
            .get();
    return snapshot.docs.length;
  }

  // Mark all messages as read
  Future<void> markChatAsRead(String userId) async {
    final batch = _firestore.batch();
    final unreadMessages =
        await _firestore
            .collection('chats')
            .doc(userId)
            .collection('messages')
            .where('isRead', isEqualTo: false)
            .get();

    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    // Reset unread count
    batch.update(_firestore.collection('chats').doc(userId), {
      'unreadCount': 0,
    });

    await batch.commit();
  }

  // Send message (supports text & images)
  Future<void> sendMessage(
    String userId,
    String senderId,
    String senderName,
    String message, {
    List<String>? imageUrls,
  }) async {
    try {
      final docRef =
          _firestore
              .collection('chats')
              .doc(userId)
              .collection('messages')
              .doc();

      final newMessage = Message(
        id: docRef.id,
        senderId: senderId,
        senderName: senderName,
        message: message,
        imageUrls: imageUrls ?? [],
        timestamp: DateTime.now(),
        isRead: senderId == adminId, // Mark admin messages as read
      );

      // Store the message in Firestore
      await docRef.set(newMessage.toMap());

      // Update chat metadata (last message & unread count)
      await _firestore.collection('chats').doc(userId).update({
        'lastMessage': message.isNotEmpty ? message : "[Image]",
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadCount':
            senderId == adminId
                ? 0
                : FieldValue.increment(
                  1,
                ), // Increment unread count for user messages
      });

      debugPrint("Message sent successfully: ${newMessage.toMap()}");
    } catch (e) {
      debugPrint("Error sending message: $e");
      rethrow;
    }
  }

  // Check if chat exists without creating if not exists
  Future<bool> chatExists(String userId) async {
    final chatDoc = await _firestore.collection('chats').doc(userId).get();
    return chatDoc.exists;
  }

  // Chat exists before opening
  Future<void> checkChatExists(String userId) async {
    final chatDoc = await _firestore.collection('chats').doc(userId).get();
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(userId).set({
        'userId': userId,
        'adminId': adminId,
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
        'unreadCount': 0,
      });
    }
  }
}
