import 'dart:ui';

import '../models/user_model.dart';

bool isAdmin(UserModel user) {
  return user.role == 'admin';
}

Color hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  return Color(int.parse(hex, radix: 16));
}

String colorToHex(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';
}
