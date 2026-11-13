import 'item.dart';

class InventoryItem {
  final String id;
  final String playerId;
  final String itemId;
  final int quantity;
  final Item? item;

  const InventoryItem({
    required this.id,
    required this.playerId,
    required this.itemId,
    required this.quantity,
    this.item,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] as String,
        playerId: json['player_id'] as String,
        itemId: json['item_id'] as String,
        quantity: json['quantity'] as int,
        item: json['items'] != null
            ? Item.fromJson(json['items'] as Map<String, dynamic>)
            : null,
      );
}
