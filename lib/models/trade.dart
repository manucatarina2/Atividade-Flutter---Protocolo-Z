class Trade {
  final String id;
  final String authorId;
  final String recipientId;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;

  const Trade({
    required this.id,
    required this.authorId,
    required this.recipientId,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Trade.fromJson(Map<String, dynamic> json) => Trade(
        id: json['id'] as String,
        authorId: json['author_id'] as String,
        recipientId: json['recipient_id'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );
}
