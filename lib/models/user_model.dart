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

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.activated,
    required this.loyaltyPoints,
    required this.loyaltyPointsUsed,
    required this.city,
    required this.district,
    required this.ward,
    required this.shippingAddress,
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
    };
  }
}
