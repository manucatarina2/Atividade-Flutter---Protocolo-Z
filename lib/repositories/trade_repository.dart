import '../core/supabase/supabase_client.dart';
import '../models/trade.dart';

class TradeRepository {
  Future<List<Trade>> fetchMyTrades() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return [];

    final data = await SupabaseConfig.client
        .from('trades')
        .select()
        .or('author_id.eq.${user.id},recipient_id.eq.${user.id}')
        .order('created_at', ascending: false);

    return (data as List).map((e) => Trade.fromJson(e)).toList();
  }
}
