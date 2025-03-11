class Chat {
  final String userId;
  final String userName;
  final String lastMessage;
  final DateTime lastMessageTimestamp;

  Chat({
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });

  // Convert Firestore JSON -> Chat Object
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      userId: json["userId"],
      userName: json["userName"],
      lastMessage: json["lastMessage"],
      lastMessageTimestamp: json["lastMessageTimestamp"],
    );
  }

  // Convert Chat Object -> Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "userName": userName,
      "lastMessage": lastMessage,
      "lastMessageTimestamp": lastMessageTimestamp,
    };
  }
}
