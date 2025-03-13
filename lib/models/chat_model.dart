import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String userId;
  final String userName;
  final String lastMessage;
  final Timestamp lastMessageTimestamp;
  final Timestamp lastSeenMessageTimestamp;

  Chat({
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.lastSeenMessageTimestamp,
  });

  // Convert Firestore JSON -> Chat Object
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      userId: json["userId"],
      userName: json["userName"],
      lastMessage: json["lastMessage"],
      lastMessageTimestamp: json["lastMessageTimestamp"] as Timestamp,
      lastSeenMessageTimestamp:
          json.containsKey('lastSeenMessageTimestamp')
              ? json['lastSeenMessageTimestamp'] as Timestamp
              : Timestamp(0, 0), // Default if missing
    );
  }

  // Convert Chat Object -> Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "userName": userName,
      "lastMessage": lastMessage,
      "lastMessageTimestamp": lastMessageTimestamp,
      'lastSeenMessageTimestamp': lastSeenMessageTimestamp,
    };
  }
}
