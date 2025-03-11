import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get chats once time
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

  // Get messages once time
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

  // Send message
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
      timestamp: Timestamp.now().toDate(),
    );

    await _firestore
        .collection("chats")
        .doc(userId)
        .collection("messages")
        .add(newMessage.toJson());

    await _firestore.collection("chats").doc(userId).set({
      "userId": userId,
      "userName": senderName,
      "lastMessage": message.isNotEmpty ? message : "Image",
      "lastMessageTimestamp": Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
