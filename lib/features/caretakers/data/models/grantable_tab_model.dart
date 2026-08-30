import '../../domain/entities/caretaker_entity.dart';

class GrantableTabModel extends GrantableTabEntity {
  const GrantableTabModel({
    required super.id,
    required super.slug,
    required super.label,
    required super.tabType,
    required super.allowView,
    required super.allowAdd,
    required super.allowEdit,
    required super.allowDelete,
    required super.allowShare,
  });

  // GET /api/users/tabs → user.service.ts getActiveTabs / TabConfig rows
  factory GrantableTabModel.fromJson(Map<String, dynamic> json) => GrantableTabModel(
        id: json['id'] as String,
        slug: json['slug'] as String,
        label: json['label'] as String,
        tabType: json['tabType'] as String? ?? 'DEFAULT',
        allowView: json['allowView'] as bool? ?? false,
        allowAdd: json['allowAdd'] as bool? ?? false,
        allowEdit: json['allowEdit'] as bool? ?? false,
        allowDelete: json['allowDelete'] as bool? ?? false,
        allowShare: json['allowShare'] as bool? ?? false,
      );
}
