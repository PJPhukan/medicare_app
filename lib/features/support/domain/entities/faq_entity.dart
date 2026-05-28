// Pure domain entity for FAQ entries.
// No Flutter, no JSON, no Dio.

class FaqEntity {
  const FaqEntity({
    required this.id,
    required this.question,
    required this.answer,
    required this.sortOrder,
    this.category,
  });

  final String id;
  final String question;
  final String answer;
  final int sortOrder;
  final String? category;
}
