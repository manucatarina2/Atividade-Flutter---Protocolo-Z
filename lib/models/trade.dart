import 'trade_item.dart';
import 'profile.dart';

class Trade {
  final String id;
  final String authorId;
  final String recipientId;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<TradeItem> items;
  final Profile? author;
  final Profile? recipient;

  const Trade({
    required this.id,
    required this.authorId,
    required this.recipientId,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.items = const [],
    this.author,
    this.recipient,
  });

  bool get isPending => status == 'pendente';

  factory Trade.fromJson(Map<String, dynamic> json) => Trade(
        id: json['id'] as String,
        authorId: json['author_id'] as String,
        recipientId: json['recipient_id'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        expiresAt: DateTime.parse(json['expires_at'] as String).toLocal(),
        items: (json['trade_items'] as List<dynamic>?)
                ?.map((e) => TradeItem.fromJson(e))
                .toList() ??
            [],
        author:
            json['author'] != null ? Profile.fromJson(json['author']) : null,
        recipient: json['recipient'] != null
            ? Profile.fromJson(json['recipient'])
            : null,
      );
}
