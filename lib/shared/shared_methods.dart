import 'package:intl/intl.dart';

String formatCurrency(
  var number, {
  String symbol = 'Rp ',
}) {
  if (number != null) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: symbol,
      decimalDigits: 0,
    ).format(number);
  }
  return '0';
}
