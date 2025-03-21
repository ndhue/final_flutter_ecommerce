import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final List<String> imageUrls;
  final DateTime timestamp;
  final bool isRead;
  QueryDocumentSnapshot<Object?>? documentSnapshot;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.imageUrls,
    required this.timestamp,
    required this.isRead,
    this.documentSnapshot,
  });

  Message copyWith({bool? isRead, required List<String> imageUrls}) {
    return Message(
      id: id,
      senderId: senderId,
      senderName: senderName,
      message: message,
      imageUrls: imageUrls,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead, // Update only if provided
    );
  }

  // Convert Firestore data to Message object
  factory Message.fromMap(
    Map<String, dynamic> map, {
    DocumentSnapshot? snapshot,
  }) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      imageUrls:
          (map['imageUrls'] as List<dynamic>?)
              ?.map((url) => url as String)
              .toList() ??
          [], // Properly cast imageUrls to List<String>
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      documentSnapshot: snapshot as QueryDocumentSnapshot<Object?>?,
    );
  }

  QueryDocumentSnapshot<Object?>? get getDocumentSnapshot => documentSnapshot;

  set setDocumentSnapshot(QueryDocumentSnapshot<Object?>? documentSnapshot) {
    this.documentSnapshot = documentSnapshot;
  }

  // Convert Message object to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'imageUrls': imageUrls,
      'timestamp': timestamp.toUtc(),
      'isRead': isRead,
    };
  }
}
