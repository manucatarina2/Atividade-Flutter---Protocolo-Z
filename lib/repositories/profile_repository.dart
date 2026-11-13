import '../core/supabase/supabase_client.dart';
import '../models/profile.dart';

class ProfileRepository {
  Future<Profile?> fetchMyProfile() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return null;

    final data = await SupabaseConfig.client
        .from('profiles')
        .select('*, factions(*)')
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return Profile.fromJson(data);
  }
}
