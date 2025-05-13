import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

Color getStatusColor(String status) {
  switch (status) {
    case 'Pending':
      return Colors.orange;
    case 'Confirmed':
      return Colors.blue;
    case 'Shipping':
      return Colors.deepPurple;
    case 'Delivered':
      return Colors.green;
    case 'Cancelled':
      return Colors.red;
    default:
      return Colors.grey; // fallback
  }
}

List<String> getActionsForStatus(String status) {
  switch (status) {
    case 'Pending':
      return ['Cancel'];
    case 'Confirmed':
      return ['Cancel'];
    case 'Shipping':
      return ['Track'];
    case 'Delivered':
    case 'Cancelled':
      return [];
    default:
      return [];
  }
}

String getDaySuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

// Hàm format DateTime -> "8th Jan 2025"
String formatDate(DateTime date) {
  final day = date.day;
  final month = DateFormat('MMM').format(date); // Jan, Feb, Mar...
  final year = date.year;
  final suffix = getDaySuffix(day);

  return '$day$suffix $month $year';
}

String formatDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('HH:mm dd/MM/yyyy');
  return formatter.format(dateTime);
}

// Format number with thousand separator
String formatNumber(int number) {
  return number.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
}

// Convert from VND to loyalty points (10% conversion rate)
int convertVndToPoints(int vndAmount) {
  return (vndAmount / 10000).floor(); // 10,000 VND = 1 point
}
