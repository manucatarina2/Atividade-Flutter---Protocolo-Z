import '../core/supabase/supabase_client.dart';
import '../models/expedition.dart';
import '../models/expedition_type.dart';

class ExpeditionRepository {
  Future<List<ExpeditionType>> fetchTypes() async {
    final data = await SupabaseConfig.client.from('expedition_types').select();
    return (data as List).map((e) => ExpeditionType.fromJson(e)).toList();
  }

  Future<Expedition?> fetchActiveExpedition() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return null;

    final data = await SupabaseConfig.client
        .from('expeditions')
        .select('*, expedition_types(*)')
        .eq('player_id', user.id)
        .eq('status', 'em_andamento')
        .maybeSingle();

    if (data == null) return null;
    return Expedition.fromJson(data);
  }

  Future<void> startExpedition(String typeId) async {
    await SupabaseConfig.client.rpc('start_expedition', params: {
      'p_expedition_type_id': typeId,
    });
  }

  Future<Map<String, dynamic>> collectRewards(String expeditionId) async {
    final response =
        await SupabaseConfig.client.rpc('collect_expedition_rewards', params: {
      'p_expedition_id': expeditionId,
    });
    return response as Map<String, dynamic>;
  }
}
