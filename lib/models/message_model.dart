import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName;
  final String message;
  final String imageUrl;
  final Timestamp timestamp;
  bool isRead;

  Message({
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.imageUrl,
    required this.timestamp,
    required this.isRead,
  });

  // Convert Firestore JSON -> Message Object
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json["senderId"],
      senderName: json["senderName"],
      message: json["message"] ?? "",
      imageUrl: json["imageUrl"] ?? "",
      timestamp: json["timestamp"],
      isRead: json.containsKey('isRead') ? json['isRead'] as bool : false,
    );
  }

  // Convert Message Object -> Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      "senderId": senderId,
      "senderName": senderName,
      "message": message,
      "imageUrl": imageUrl,
      "timestamp": timestamp,
      'isRead': isRead,
    };
  }
}
