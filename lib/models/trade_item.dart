import 'item.dart';

class TradeItem {
  final String id;
  final String tradeId;
  final String itemId;
  final int quantity;
  final String direction; // 'offered' or 'requested'
  final Item? item;

  const TradeItem({
    required this.id,
    required this.tradeId,
    required this.itemId,
    required this.quantity,
    required this.direction,
    this.item,
  });

  factory TradeItem.fromJson(Map<String, dynamic> json) => TradeItem(
        id: json['id'] as String,
        tradeId: json['trade_id'] as String,
        itemId: json['item_id'] as String,
        quantity: (json['quantity'] as int?) ?? 0,
        direction: json['direction'] as String,
        item: json['items'] != null
            ? Item.fromJson(json['items'] as Map<String, dynamic>)
            : null,
      );
}
