import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all chats for Admin
  Future<List<Chat>> getChatsOnce() async {
    QuerySnapshot snapshot =
        await _firestore
            .collection("chats")
            .orderBy("lastMessageTimestamp", descending: true)
            .get();

    return snapshot.docs
        .map((doc) => Chat.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Get messages for a specific user
  Future<List<Message>> getMessagesOnce(String userId) async {
    QuerySnapshot snapshot =
        await _firestore
            .collection("chats")
            .doc(userId)
            .collection("messages")
            .orderBy("timestamp", descending: true)
            .get();

    return snapshot.docs
        .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Get unread messages count
  Future<int> getUnreadMessagesCount(String userId) async {
    DocumentSnapshot chatDoc =
        await _firestore.collection("chats").doc(userId).get();

    if (!chatDoc.exists) return 0;

    Timestamp lastSeen = (chatDoc.data() as Map<String, dynamic>?)?["lastSeenMessageTimestamp"] ?? Timestamp(0, 0);

    QuerySnapshot unreadMessages =
        await _firestore
            .collection("chats")
            .doc(userId)
            .collection("messages")
            .where(
              "timestamp",
              isGreaterThan: lastSeen,
            ) // Only unread messages
            .get();

    return unreadMessages.docs.length;
  }

  // Mark chat as read when user opens chat
  Future<void> markChatAsRead(String userId) async {
    // Update last seen timestamp
    await _firestore.collection("chats").doc(userId).update({
      "lastSeenMessageTimestamp": Timestamp.now(),
    });

    // Update unread messages in the messages collection
    QuerySnapshot unreadMessages =
        await _firestore
            .collection("chats")
            .doc(userId)
            .collection("messages")
            .where("isRead", isEqualTo: false)
            .get();

    for (var doc in unreadMessages.docs) {
      doc.reference.update({'isRead': true});
    }
  }

  // Send message and update chat
  Future<void> sendMessage(
    String userId,
    String senderId,
    String senderName,
    String message, {
    String? imageUrl,
  }) async {
    Message newMessage = Message(
      senderId: senderId,
      senderName: senderName,
      message: message,
      imageUrl: imageUrl ?? "",
      timestamp: Timestamp.now(),
      isRead: senderId == userId, // Mark as read if the sender is the user
    );

    // Add message to Firestore
    await _firestore
        .collection("chats")
        .doc(userId)
        .collection("messages")
        .add(newMessage.toJson());

    // Update last message info in chat document
    await _firestore.collection("chats").doc(userId).set({
      "userId": userId,
      "userName": senderName,
      "lastMessage": message.isNotEmpty ? message : "Image",
      "lastMessageTimestamp": Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
