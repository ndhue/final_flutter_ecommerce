import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch chats (for Admin)
  Future<List<Chat>> getChatsOnce() async {
    final snapshot = await _firestore.collection('chats').get();
    return snapshot.docs.map((doc) => Chat.fromMap(doc.data())).toList();
  }

  // Fetch messages (lazy loading)
  Future<List<Message>> getMessagesOnce(
    String userId, {
    DocumentSnapshot? lastMessage,
  }) async {
    Query query = _firestore
        .collection('chats')
        .doc("chat_$userId")
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(10); // Load 10 messages at a time

    if (lastMessage != null) {
      query = query.startAfterDocument(lastMessage);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

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

      List<Message> messages =
          querySnapshot.docs
              .map(
                (doc) =>
                    Message.fromMap(doc.data() as Map<String, dynamic>)
                      ..documentSnapshot = doc,
              ) // Lưu snapshot để pagination
              .toList();

      return messages;
    } catch (e) {
      return [];
    }
  }

  // Listen for real-time updates (new messages)
  Stream<List<Message>> listenToMessages(String userId) {
    return _firestore
        .collection('chats')
        .doc("chat_$userId")
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
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
            .doc("chat_$userId")
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
            .doc("chat_$userId")
            .collection('messages')
            .where('isRead', isEqualTo: false)
            .get();

    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    // Reset unread count in chat metadata
    batch.update(_firestore.collection('chats').doc("chat_$userId"), {
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
    final docRef =
        _firestore
            .collection('chats')
            .doc("chat_$userId")
            .collection('messages')
            .doc();

    final newMessage = Message(
      id: docRef.id,
      senderId: senderId,
      senderName: senderName,
      message: message,
      imageUrls: imageUrls ?? [],
      timestamp: DateTime.now(),
      isRead: senderId == "admin", // Admin messages are always read
    );

    await docRef.set(newMessage.toMap());

    // Update chat metadata (last message & unread count)
    await _firestore.collection('chats').doc("chat_$userId").update({
      'lastMessage': message,
      'lastMessageTimestamp': DateTime.now(),
      'unreadCount':
          senderId == "admin"
              ? 0
              : FieldValue.increment(
                1,
              ), // Increase unread count only for user messages
    });
  }
}
