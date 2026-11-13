import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/inventory_item.dart';
import '../../repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider((ref) => InventoryRepository());

final inventoryProvider =
    FutureProvider.autoDispose<List<InventoryItem>>((ref) async {
  return ref.watch(inventoryRepositoryProvider).fetchMyInventory();
});
