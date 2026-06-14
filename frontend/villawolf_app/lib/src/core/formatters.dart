import 'package:intl/intl.dart';

/// Display helpers for money, dates and enum labels.
class Formatters {
  static final _money = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

  static String money(num value) => _money.format(value);
  static String date(DateTime d) => DateFormat('dd/MM/yyyy').format(d.toLocal());
  static String time(DateTime d) => DateFormat('HH:mm').format(d.toLocal());
  static String dateTime(DateTime d) => DateFormat('dd/MM HH:mm').format(d.toLocal());

  /// Turns API enum values like `InProgress` / `NoShow` into `In Progress` / `No Show`.
  static String label(String value) =>
      value.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ');
}
