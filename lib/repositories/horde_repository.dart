import '../core/supabase/supabase_client.dart';
import '../models/horde_alert.dart';

class HordeRepository {
  Future<List<HordeAlert>> fetchActiveAlerts() async {
    final data = await SupabaseConfig.client
        .from('horde_alerts')
        .select()
        .gt('expires_at', DateTime.now().toIso8601String());

    return (data as List).map((e) => HordeAlert.fromJson(e)).toList();
  }

  Future<void> createAlert({
    required double latitude,
    required double longitude,
    required String intensity,
    String? description,
  }) async {
    await SupabaseConfig.client.from('horde_alerts').insert({
      'author_id': SupabaseConfig.client.auth.currentUser!.id,
      'latitude': latitude,
      'longitude': longitude,
      'intensity': intensity,
      'description': description,
    });
  }
}
