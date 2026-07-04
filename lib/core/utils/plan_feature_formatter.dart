import '../constants/app_strings.dart';

/// Parses raw feature strings from the backend into readable text.
///
/// Formats:
///   "name | value"       → value-first ("5 medicines", "Unlimited caretaker")
///   "{value} rest"       → same with brace template
///   "Feature | true"     → boolean feature, show name only
///   "Plain text"         → returned as-is
String formatPlanFeature(String raw) {
  final s = raw.trim();

  final brace = RegExp(r'^\{([^}]+)\}\s*(.+)$').firstMatch(s);
  if (brace != null) {
    final val  = brace.group(1)!.trim();
    final rest = brace.group(2)!.trim();
    return val.toLowerCase() == 'unlimited'
        ? '${AppStrings.planUnlimited} $rest'
        : '$val $rest';
  }

  final pipe = s.indexOf('|');
  if (pipe > 0) {
    final name  = s.substring(0, pipe).trim();
    final value = s.substring(pipe + 1).trim();
    if (value.toLowerCase() == 'true') return name;
    if (value.toLowerCase() == 'unlimited') return '${AppStrings.planUnlimited} $name';
    return '$value $name';
  }

  return s;
}
