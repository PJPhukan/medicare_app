class ReportTagEntity {
  const ReportTagEntity({required this.id, required this.name});

  final String id;
  final String name;
}

class MedicalReportEntity {
  const MedicalReportEntity({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.createdAt,
    required this.tags,
    this.fileType,
    this.description,
    this.reportDate,
  });

  final String id;
  final String title;
  final String fileUrl;
  final String createdAt;
  final List<ReportTagEntity> tags;
  final String? fileType;
  final String? description;
  final String? reportDate;

  bool get isPdf => fileType?.toLowerCase() == 'pdf';
  bool get isImage {
    final t = fileType?.toLowerCase();
    return t == 'jpg' || t == 'jpeg' || t == 'png';
  }

  DateTime get createdAtDate => DateTime.parse(createdAt);
}
