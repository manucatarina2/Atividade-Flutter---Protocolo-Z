import '../core/supabase/supabase_client.dart';
import '../models/shelter.dart';

class ShelterRepository {
  Future<List<Shelter>> fetchShelters() async {
    final data = await SupabaseConfig.client
        .from('shelters')
        .select('*, profiles(nickname, faction_id)')
        .order('created_at', ascending: false);

    return (data as List).map((e) => Shelter.fromJson(e)).toList();
  }

  Future<void> createShelter({
    required String name,
    String? description,
    int? capacity,
    String? photoUrl,
    required double latitude,
    required double longitude,
    required String visibility,
  }) async {
    await SupabaseConfig.client.rpc('create_shelter', params: {
      'p_name': name,
      'p_description': description,
      'p_capacity': capacity,
      'p_photo_url': photoUrl,
      'p_latitude': latitude,
      'p_longitude': longitude,
      'p_visibility': visibility,
    });
  }
}
