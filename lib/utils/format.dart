import 'package:intl/intl.dart';

class FormatHelper {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static String formatCurrency(num amount) {
    return _currencyFormat.format(amount);
  }
}