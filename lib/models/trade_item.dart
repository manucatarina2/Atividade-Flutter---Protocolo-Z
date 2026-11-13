import 'item.dart';

class TradeItem {
  final String id;
  final String itemId;
  final int quantity;
  final String direction; // 'oferecido' ou 'pedido'
  final Item? item;

  const TradeItem({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.direction,
    this.item,
  });

  bool get isOffered => direction == 'oferecido';

  factory TradeItem.fromJson(Map<String, dynamic> json) => TradeItem(
        id: json['id'] as String,
        itemId: json['item_id'] as String,
        quantity: json['quantity'] as int,
        direction: json['direction'] as String,
        item: json['items'] != null ? Item.fromJson(json['items']) : null,
      );
}
