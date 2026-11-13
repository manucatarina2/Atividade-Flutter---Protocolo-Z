import '../core/supabase/supabase_client.dart';

class RankingRepository {
  Future<List<Map<String, dynamic>>> fetchSurvivorRanking() async {
    final response = await SupabaseConfig.client
        .from('profiles')
        .select('*, factions(*)')
        .order('reputation', ascending: false)
        .limit(100);
    return (response as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchFactionRanking() async {
    final response = await SupabaseConfig.client
        .from('profiles')
        .select('faction_id, reputation, factions(*)')
        .not('faction_id', 'is', null);

    final rows = (response as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    // Aggregate in Dart: group by faction_id
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final row in rows) {
      final factionId = row['faction_id'] as String;
      final reputation = (row['reputation'] as int?) ?? 0;
      if (!grouped.containsKey(factionId)) {
        grouped[factionId] = {
          'faction': row['factions'],
          'totalReputation': 0,
          'memberCount': 0,
        };
      }
      grouped[factionId]!['totalReputation'] =
          (grouped[factionId]!['totalReputation'] as int) + reputation;
      grouped[factionId]!['memberCount'] =
          (grouped[factionId]!['memberCount'] as int) + 1;
    }

    final result = grouped.values.toList();
    result.sort((a, b) => (b['totalReputation'] as int)
        .compareTo(a['totalReputation'] as int));
    return result;
  }
}
