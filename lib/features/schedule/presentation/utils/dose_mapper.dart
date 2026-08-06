import '../../data/models/today_dose_model.dart';
import '../models/presentation_dose.dart';

abstract final class DoseMapper {
  /// Robustly parses time string ("08:30", "8:30", "08.30", "8", null) without crashing.
  static int parseHour(String? input) {
    if (input == null || input.trim().isEmpty) return 8;
    final cleaned = input.replaceAll('.', ':').trim();
    final parts = cleaned.split(':');
    return int.tryParse(parts.first.trim()) ?? 8;
  }

  static DoseTimeGroup determineGroup(String? timeStr) {
    final h = parseHour(timeStr);
    if (h >= 5 && h < 12) return DoseTimeGroup.morning;
    if (h >= 12 && h < 17) return DoseTimeGroup.afternoon;
    if (h >= 17 && h < 21) return DoseTimeGroup.evening;
    return DoseTimeGroup.night;
  }

  static DoseStatus parseStatus(String? statusStr) {
    switch (statusStr?.toUpperCase()) {
      case 'TAKEN':
        return DoseStatus.taken;
      case 'SKIPPED':
        return DoseStatus.skipped;
      default:
        return DoseStatus.pending;
    }
  }

  static DoseFoodTimingEnum parseFoodTiming(String? timingStr) {
    switch (timingStr?.toUpperCase()) {
      case 'BEFORE':
        return DoseFoodTimingEnum.before;
      case 'WITH':
        return DoseFoodTimingEnum.with_;
      default:
        return DoseFoodTimingEnum.after;
    }
  }

  static String foodTimingLabel(DoseFoodTimingEnum timing) {
    switch (timing) {
      case DoseFoodTimingEnum.before:
        return 'Before food';
      case DoseFoodTimingEnum.with_:
        return 'With food';
      case DoseFoodTimingEnum.after:
        return 'After food';
    }
  }
}

extension TodayDoseMapper on TodayDose {
  PresentationDose toPresentation() {
    return PresentationDose(
      id: doseTimeId,
      time: scheduledTime,
      name: medicineName,
      unit: unit ?? '',
      foodTiming: DoseMapper.parseFoodTiming(foodTiming),
      status: DoseMapper.parseStatus(status),
      group: DoseMapper.determineGroup(scheduledTime),
    );
  }
}
