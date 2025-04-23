import 'package:intl/intl.dart';

class DateHelper {
  /// Formats date as 'yyyy-MM-dd'
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Formats date & time as 'yyyy-MM-dd HH:mm'
  static String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  /// Formats time only as 'HH:mm'
  static String formatTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('HH:mm').format(date);
  }
}
