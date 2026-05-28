import '../../domain/entities/report_entity.dart';

class ReportTag extends ReportTagEntity {
  const ReportTag({required super.id, required super.name});

  factory ReportTag.fromJson(Map<String, dynamic> json) =>
      ReportTag(id: json['id'] as String, name: json['name'] as String);
}

class MedicalReport extends MedicalReportEntity {
  const MedicalReport({
    required super.id,
    required super.title,
    required super.fileUrl,
    required super.createdAt,
    required List<ReportTag> tags,
    super.fileType,
    super.description,
    super.reportDate,
  }) : super(tags: tags);

  @override
  List<ReportTag> get tags => super.tags.cast<ReportTag>();

  factory MedicalReport.fromJson(Map<String, dynamic> json) => MedicalReport(
        id: json['id'] as String,
        title: json['title'] as String,
        fileUrl: json['fileUrl'] as String,
        createdAt: json['createdAt'] as String,
        fileType: json['fileType'] as String?,
        description: json['description'] as String?,
        reportDate: json['reportDate'] as String?,
        tags: (json['tags'] as List<dynamic>? ?? [])
            .map((e) => ReportTag.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
