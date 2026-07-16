import 'package:intl/intl.dart';

/// Helpers for converting a [DateTime] into the user-facing
/// "今天 / 昨天 / 2025-01-12" headers used to group the message list.
///
/// The logic intentionally uses the device's local timezone and the
/// device's current date (not server time) — a private two-person app
/// doesn't need server-side grouping for v1.
class ChatTime {
  ChatTime._();

  /// Returns a header label for a given message timestamp.
  ///
  /// - Same calendar day as `now` → "今天"
  /// - The day before `now` → "昨天"
  /// - Within the current calendar year → "01-12"
  /// - Older → "2024-01-12"
  static String dayHeader(DateTime ts, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(ts.year, ts.month, ts.day);
    final diffDays = today.difference(that).inDays;

    if (diffDays == 0) return '今天';
    if (diffDays == 1) return '昨天';
    if (ts.year == now.year) return DateFormat('MM-dd').format(ts);
    return DateFormat('yyyy-MM-dd').format(ts);
  }

  /// "HH:mm" — used as the inline timestamp next to each bubble.
  static String clock(DateTime ts) => DateFormat('HH:mm').format(ts);
}
