import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final String userId;
  final String userName;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final int unreadCount;

  Chat({
    required this.id,
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.unreadCount,
  });

  // Convert Firestore document to Chat object
  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTimestamp: (map['lastMessageTimestamp'] as Timestamp).toDate(),
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  // Convert Chat object to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp.toUtc(),
      'unreadCount': unreadCount,
    };
  }

  // Add copyWith method to create a new Chat instance with some properties updated
  Chat copyWith({
    String? id,
    String? userId,
    String? userName,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    int? unreadCount,
  }) {
    return Chat(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
