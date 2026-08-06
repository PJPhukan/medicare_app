abstract final class DateFormatter {
  static const _short  = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  static const _long   = ['January','February','March','April','May','June','July','August','September','October','November','December'];

  /// "25 Jun 2026"
  static String short(DateTime dt) => '${dt.day} ${_short[dt.month - 1]} ${dt.year}';

  /// "25 June 2026"
  static String long(DateTime dt) => '${dt.day} ${_long[dt.month - 1]} ${dt.year}';

  /// "25/6/2026"
  static String slash(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  /// "Jun 2026"
  static String monthYear(DateTime dt) => '${_short[dt.month - 1]} ${dt.year}';

  /// "Jun 25"
  static String monthDay(DateTime dt) => '${_short[dt.month - 1]} ${dt.day}';

  /// "June 2026"
  static String monthYearLong(DateTime dt) => '${_long[dt.month - 1]} ${dt.year}';

  /// "Mon, 25 Jun"
  static String weekdayMonthDay(DateTime dt) =>
      '${['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][dt.weekday - 1]}, ${dt.day} ${_short[dt.month - 1]}';

  /// "Today, August 2026" / "Yesterday, August 2026" / "Tomorrow, August 2026",
  /// falling back to "8 November, 2026" for anything further out.
  static String relativeDateHeader(DateTime dt) {
    final today = DateTime.now();
    final diff = DateTime(dt.year, dt.month, dt.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    return switch (diff) {
      0 => 'Today, ${monthYearLong(dt)}',
      -1 => 'Yesterday, ${monthYearLong(dt)}',
      1 => 'Tomorrow, ${monthYearLong(dt)}',
      _ => '${dt.day} ${_long[dt.month - 1]}, ${dt.year}',
    };
  }

  /// True when [a] and [b] fall on the same calendar day (ignores time).
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
