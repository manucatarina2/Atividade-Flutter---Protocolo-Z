import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/trade/trade_provider.dart';
import '../../widgets/trade_card.dart';

class TradeListScreen extends ConsumerWidget {
  const TradeListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trades = ref.watch(myTradesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Trocas')),
      body: trades.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('Nenhuma troca encontrada.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) => TradeCard(trade: list[i]),
              ),
      ),
    );
  }
}
