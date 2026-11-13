import '../core/supabase/supabase_client.dart';
import '../models/faction.dart';

class FactionRepository {
  Future<List<Faction>> fetchFactions() async {
    final data = await SupabaseConfig.client.from('factions').select();
    return (data as List).map((e) => Faction.fromJson(e)).toList();
  }

  Future<void> chooseFaction(String factionId) async {
    await SupabaseConfig.client.rpc('choose_faction', params: {
      'p_faction_id': factionId,
    });
  }
}
