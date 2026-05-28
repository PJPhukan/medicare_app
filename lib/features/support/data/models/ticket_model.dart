import '../../domain/entities/ticket_entity.dart';

class Ticket extends TicketEntity {
  const Ticket({
    required super.id,
    required super.subject,
    required super.body,
    required super.status,
    required super.createdAt,
    super.category,
    super.resolvedAt,
    super.adminReply,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: json['id'] as String,
        subject: json['subject'] as String,
        body: json['body'] as String,
        status: json['status'] as String,
        createdAt: json['createdAt'] as String,
        category: json['category'] as String?,
        resolvedAt: json['resolvedAt'] as String?,
        adminReply: json['adminReply'] as String?,
      );
}
