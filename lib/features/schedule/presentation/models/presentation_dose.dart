import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/badges/app_badge.dart';

enum DoseStatus { pending, taken, skipped }

enum DoseTimeGroup {
  morning('Morning', '5:00 - 12:00 PM', Icons.wb_sunny_outlined, AppColors.amber,
      AppBadgeVariant.amber),
  afternoon('Afternoon', '12:00 - 5:00 PM', Icons.wb_twilight_rounded, AppColors.blue,
      AppBadgeVariant.blue),
  evening('Evening', '5:00 - 9:00 PM', Icons.nightlight_round, AppColors.purple,
      AppBadgeVariant.purple),
  night('Night', '9:00 - 5:00 AM', Icons.bedtime_rounded, AppColors.teal,
      AppBadgeVariant.teal);

  final String label;
  final String range;
  final IconData icon;
  final Color color;

  /// Mirrors [color] as an [AppBadgeVariant] so group-tinted badges (the
  /// section range tag, the dose unit pill) can use the shared AppBadge
  /// widget instead of re-deriving the same brand colour by hand.
  final AppBadgeVariant badgeVariant;

  const DoseTimeGroup(
      this.label, this.range, this.icon, this.color, this.badgeVariant);
}

enum DoseFoodTimingEnum { before, with_, after }

@immutable
class PresentationDose {
  const PresentationDose({
    required this.id,
    required this.time,
    required this.name,
    required this.unit,
    required this.foodTiming,
    required this.status,
    required this.group,
  });

  final String id;
  final String time; // "HH:mm"
  final String name;
  final String unit;
  final DoseFoodTimingEnum foodTiming;
  final DoseStatus status;
  final DoseTimeGroup group;

  PresentationDose copyWith({
    String? id,
    String? time,
    String? name,
    String? unit,
    DoseFoodTimingEnum? foodTiming,
    DoseStatus? status,
    DoseTimeGroup? group,
  }) {
    return PresentationDose(
      id: id ?? this.id,
      time: time ?? this.time,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      foodTiming: foodTiming ?? this.foodTiming,
      status: status ?? this.status,
      group: group ?? this.group,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresentationDose &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          time == other.time &&
          name == other.name &&
          unit == other.unit &&
          foodTiming == other.foodTiming &&
          status == other.status &&
          group == other.group;

  @override
  int get hashCode =>
      id.hashCode ^
      time.hashCode ^
      name.hashCode ^
      unit.hashCode ^
      foodTiming.hashCode ^
      status.hashCode ^
      group.hashCode;
}
