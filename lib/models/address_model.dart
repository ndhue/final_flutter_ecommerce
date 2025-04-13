class AddressInfo {
  final String city;
  final String district;
  final String ward;
  final String detailedAddress;
  final String receiverName;

  AddressInfo({
    required this.city,
    required this.district,
    required this.ward,
    required this.detailedAddress,
    required this.receiverName,
  });

  String get fullShippingAddress {
    return '$detailedAddress, $ward, $district, $city';
  }
}
