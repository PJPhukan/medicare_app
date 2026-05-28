import '../../domain/entities/faq_entity.dart';

class Faq extends FaqEntity {
  const Faq({
    required super.id,
    required super.question,
    required super.answer,
    required super.sortOrder,
    super.category,
  });

  factory Faq.fromJson(Map<String, dynamic> json) => Faq(
        id: json['id'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
        sortOrder: json['sortOrder'] as int? ?? 0,
        category: json['category'] as String?,
      );
}
