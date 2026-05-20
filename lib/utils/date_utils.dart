/// Date formatting and calculation utilities for FlowMate.
///
/// Named [FlowDateUtils] to avoid conflict with Flutter's built-in
/// [DateUtils] class.
class FlowDateUtils {
  FlowDateUtils._(); // prevent instantiation

  // ──────────────────────────────────────────────
  // Month names in Bahasa Indonesia
  // ──────────────────────────────────────────────

  static const List<String> monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> monthNamesShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> dayNamesShort = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  // ──────────────────────────────────────────────
  // Formatting helpers
  // ──────────────────────────────────────────────

  /// Format a date as "dd MMMM yyyy" in Bahasa Indonesia.
  /// Example: "15 Januari 2026"
  static String formatDate(DateTime date) {
    final day = date.day.toString();
    final month = monthNames[date.month - 1];
    final year = date.year.toString();
    return '$day $month $year';
  }

  /// Format a date as "dd MMM yyyy" (short month name).
  /// Example: "15 Jan 2026"
  static String formatDateShort(DateTime date) {
    final day = date.day.toString();
    final month = monthNamesShort[date.month - 1];
    final year = date.year.toString();
    return '$day $month $year';
  }

  /// Format as "MMMM yyyy" — e.g. "Januari 2026".
  static String formatMonthYear(DateTime date) {
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  /// Format as "dd/MM/yyyy" — e.g. "15/01/2026".
  static String formatDateNumeric(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  /// Format as "Senin, 15 Januari 2026".
  static String formatDateFull(DateTime date) {
    // DateTime.weekday: 1=Monday ... 7=Sunday
    final dayName = dayNames[date.weekday - 1];
    return '$dayName, ${formatDate(date)}';
  }

  /// Format a date range, e.g. "15 Jan – 20 Jan 2026".
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${start.day} – ${end.day} ${monthNamesShort[start.month - 1]} ${start.year}';
    }
    return '${formatDateShort(start)} – ${formatDateShort(end)}';
  }

  // ──────────────────────────────────────────────
  // Calculation helpers
  // ──────────────────────────────────────────────

  /// Calculate the number of days between two dates (date-only).
  /// Returns a positive number if [to] is after [from].
  static int daysBetween(DateTime from, DateTime to) {
    final f = DateTime(from.year, from.month, from.day);
    final t = DateTime(to.year, to.month, to.day);
    return t.difference(f).inDays;
  }

  /// Check if two dates represent the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if a date is today.
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Get the start of a day (midnight).
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get all dates in a month as a list (useful for calendar grids).
  static List<DateTime> getDaysInMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List.generate(
      daysInMonth,
      (index) => DateTime(year, month, index + 1),
    );
  }

  /// Get the number of days in a given month.
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Get the name of a month by its 1-based index.
  static String getMonthName(int month) {
    if (month < 1 || month > 12) return '';
    return monthNames[month - 1];
  }

  /// Get the short name of a month by its 1-based index.
  static String getMonthNameShort(int month) {
    if (month < 1 || month > 12) return '';
    return monthNamesShort[month - 1];
  }

  /// Get the day name (Senin, Selasa, ...) for a DateTime.
  static String getDayName(DateTime date) {
    return dayNames[date.weekday - 1];
  }

  /// Parse a date string in "dd/MM/yyyy" format.
  static DateTime? parseNumeric(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  /// Format a DateTime into local "HH:mm" time.
  /// Example: "14:30"
  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
