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
}
