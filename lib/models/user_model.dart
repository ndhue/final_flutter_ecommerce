import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final bool activated;
  final int loyaltyPoints;
  final int loyaltyPointsUsed;
  final String city;
  final String district;
  final String ward;
  final String shippingAddress;
  final Timestamp? createdAt;
  final String? avatar;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.role = 'user',
    this.activated = true,
    this.loyaltyPoints = 0,
    this.loyaltyPointsUsed = 0,
    required this.city,
    required this.district,
    required this.ward,
    required this.shippingAddress,
    required this.createdAt,
    this.avatar,
  });

  String get fullShippingAddress {
    return '$shippingAddress, $ward, $district, $city';
  }

  // Convert Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      activated: data['activated'] ?? false,
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      loyaltyPointsUsed: data['loyaltyPointsUsed'] ?? 0,
      city: data['city'] ?? '',
      district: data['district'] ?? '',
      ward: data['ward'] ?? '',
      shippingAddress: data['shippingAddress'] ?? '',
      createdAt:
          data['createdAt'] != null ? (data['createdAt'] as Timestamp) : null,
      avatar: data['avatar'],
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'activated': activated,
      'loyaltyPoints': loyaltyPoints,
      'loyaltyPointsUsed': loyaltyPointsUsed,
      'city': city,
      'district': district,
      'ward': ward,
      'shippingAddress': shippingAddress,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'avatar': avatar,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? role,
    bool? activated,
    int? loyaltyPoints,
    int? loyaltyPointsUsed,
    String? city,
    String? district,
    String? ward,
    String? shippingAddress,
    String? avatar, // Added to copyWith
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      activated: activated ?? this.activated,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
      city: city ?? this.city,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? createdAt,
      avatar: avatar ?? this.avatar,
    );
  }
}
