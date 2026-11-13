import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/supabase/supabase_client.dart';
import '../../state/trade/trade_provider.dart';
import '../../widgets/trade_card.dart';

class TradeListScreen extends ConsumerWidget {
  const TradeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradesAsync = ref.watch(myTradesProvider);
    final myId = SupabaseConfig.client.auth.currentUser?.id;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trocas'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Recebidas'),
              Tab(text: 'Enviadas'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => context.push('/trocas/nova'),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: tradesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
          data: (trades) {
            final received =
                trades.where((t) => t.recipientId == myId).toList();
            final sent = trades.where((t) => t.authorId == myId).toList();

            return TabBarView(
              children: [
                _buildList(context, ref, received, true),
                _buildList(context, ref, sent, false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
      BuildContext context, WidgetRef ref, List trades, bool isReceived) {
    if (trades.isEmpty) {
      return Center(
        child: Text(
          isReceived ? 'Nenhuma troca recebida.' : 'Nenhuma troca enviada.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myTradesProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trades.length,
        itemBuilder: (context, i) {
          final trade = trades[i];
          return TradeCard(
            trade: trade,
            isReceived: isReceived,
            onAccept: isReceived
                ? () => _handleAction(context, ref, trade.id, 'accept_trade')
                : null,
            onReject: isReceived
                ? () => _handleAction(context, ref, trade.id, 'cancel_trade')
                : null,
            onCancel: !isReceived
                ? () => _handleAction(context, ref, trade.id, 'cancel_trade')
                : null,
          );
        },
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref,
      String tradeId, String rpcName) async {
    try {
      await SupabaseConfig.client.rpc(rpcName, params: {'p_trade_id': tradeId});
      ref.invalidate(myTradesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: AppColors.danger));
      }
    }
  }
}
