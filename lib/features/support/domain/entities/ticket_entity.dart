// Pure domain entity for support tickets.
// No Flutter, no JSON, no Dio.

class TicketEntity {
  const TicketEntity({
    required this.id,
    required this.subject,
    required this.body,
    required this.status,
    required this.createdAt,
    this.category,
    this.resolvedAt,
    this.adminReply,
  });

  final String id;
  final String subject;
  final String body;
  final String status; // 'OPEN' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED'
  final String createdAt;
  final String? category;
  final String? resolvedAt;
  final String? adminReply;

  bool get isOpen => status == 'OPEN';
  bool get isResolved => status == 'RESOLVED' || status == 'CLOSED';
  bool get hasReply => adminReply != null;
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
