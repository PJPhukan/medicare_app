// Canonical "HH:mm" (24h, as stored/sent by the API) → 12-hour display
// formatting. Three call sites (medicine cards, schedule rows, dashboard
// doses) each grew their own copy of this before it landed here — one
// implementation now, so a formatting fix applies everywhere at once.

/// "21:00" → "9:00 PM". "09:05" → "9:05 AM".
String formatTime12h(String hhmm) {
  final parts = hhmm.split(':');
  var h = int.tryParse(parts.first) ?? 0;
  final m = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
  final suffix = h >= 12 ? 'PM' : 'AM';
  h = h % 12;
  if (h == 0) h = 12;
  return '$h:$m $suffix';
}

/// "14:00" → "2 PM"; "09:30" → "9:30 AM". Drops ":00" on the hour — the
/// saved width is what lets several dose times fit on one line/chip instead
/// of truncating to an overflow badge.
String formatTime12hCompact(String hhmm) {
  final parts = hhmm.split(':');
  var h = int.tryParse(parts.first) ?? 0;
  final m = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
  final suffix = h >= 12 ? 'PM' : 'AM';
  h = h % 12;
  if (h == 0) h = 12;
  return m == '00' ? '$h $suffix' : '$h:$m $suffix';
}

/// Evening/night doses (>= 6 PM) read better with a moon than a sun.
bool isNightTime(String hhmm) => (int.tryParse(hhmm.split(':').first) ?? 0) >= 18;

/// "9:00 PM" / "9:05 AM" from a [DateTime] — for timestamps that don't come
/// as an "HH:mm" string (vitals readings, chat messages, dashboard "last
/// measured" times). Mirrors [formatTime12h]'s output format.
String formatTime12hDt(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final suffix = dt.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $suffix';
}
