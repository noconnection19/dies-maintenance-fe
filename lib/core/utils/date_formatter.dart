import 'package:intl/intl.dart';

/// Helper untuk format tanggal dan waktu secara konsisten di seluruh aplikasi.
///
/// Penggunaan:
/// ```dart
/// DateFormatter.display(task.createdAt)    // "20 Apr 2026 08:15"
/// DateFormatter.short(task.createdAt)      // "20/04/2026"
/// DateFormatter.timeAgo(task.createdAt)    // "2 jam yang lalu"
/// ```
class DateFormatter {
  DateFormatter._();

  static late final _display  = DateFormat('dd MMM yyyy, HH:mm');
  static late final _short    = DateFormat('dd/MM/yyyy');
  static late final _timeOnly = DateFormat('HH:mm');
  static late final _full     = DateFormat('EEEE, dd MMMM yyyy');
  static late final _iso      = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// "20 Apr 2026 08:15"
  static String display(String? isoString) {
    final dt = _parse(isoString);
    return dt != null ? _display.format(dt) : '-';
  }

  /// "20/04/2026"
  static String short(String? isoString) {
    final dt = _parse(isoString);
    return dt != null ? _short.format(dt) : '-';
  }

  /// "08:15"
  static String time(String? isoString) {
    final dt = _parse(isoString);
    return dt != null ? _timeOnly.format(dt) : '-';
  }

  /// "Minggu, 20 April 2026"
  static String full(String? isoString) {
    final dt = _parse(isoString);
    return dt != null ? _full.format(dt) : '-';
  }

  /// "2 jam yang lalu" / "3 hari yang lalu" / "baru saja"
  static String timeAgo(String? isoString) {
    final dt = _parse(isoString);
    if (dt == null) return '-';
    final diff = DateTime.now().difference(dt);

    if (diff.inSeconds < 60)  return 'Baru saja';
    if (diff.inMinutes < 60)  return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24)    return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 30)     return '${diff.inDays} hari yang lalu';
    if (diff.inDays < 365)    return '${(diff.inDays / 30).floor()} bulan yang lalu';
    return '${(diff.inDays / 365).floor()} tahun yang lalu';
  }

  static DateTime? _parse(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final cleanStr = value.replaceAll(' ', 'T');
      final utcStr = cleanStr.endsWith('Z') ? cleanStr : '${cleanStr}Z';
      return DateTime.parse(utcStr).toLocal();
    } catch (_) {
      try {
        return DateTime.parse(value).toLocal();
      } catch (_) {
        return null;
      }
    }
  }
}
