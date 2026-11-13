import '../core/supabase/supabase_client.dart';
import '../models/inventory_item.dart';

class InventoryRepository {
  Future<List<InventoryItem>> fetchMyInventory() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return [];

    final data = await SupabaseConfig.client
        .from('inventory')
        .select('*, items(*)')
        .eq('player_id', user.id)
        .gt('quantity', 0); // Só pega itens que o cara tem

    return (data as List).map((e) => InventoryItem.fromJson(e)).toList();
  }
}
