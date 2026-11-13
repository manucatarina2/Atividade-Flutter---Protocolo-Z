import '../core/supabase/supabase_client.dart';
import '../models/trade.dart';
import '../models/profile.dart';

class TradeRepository {
  // Busca o histórico de trocas do jogador (recebidas e enviadas)
  Future<List<Trade>> fetchMyTrades() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return [];

    final data = await SupabaseConfig.client
        .from('trades')
        .select('''
          *,
          trade_items(*, items(*)),
          author:profiles!trades_author_id_fkey(id, nickname),
          recipient:profiles!trades_recipient_id_fkey(id, nickname)
        ''')
        .or('author_id.eq.${user.id},recipient_id.eq.${user.id}')
        .order('created_at', ascending: false);

    return (data as List).map((e) => Trade.fromJson(e)).toList();
  }

  // Busca outros jogadores para trocar (excluindo a si mesmo)
  Future<List<Profile>> fetchOtherPlayers() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return [];

    final data = await SupabaseConfig.client
        .from('profiles')
        .select()
        .neq('id', user.id)
        .not('faction_id', 'is', null); // Só quem já tem facção

    return (data as List).map((e) => Profile.fromJson(e)).toList();
  }
}
