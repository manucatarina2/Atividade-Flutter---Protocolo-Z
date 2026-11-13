import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/supabase/supabase_client.dart';
import '../../models/inventory_item.dart';
import '../../models/item.dart';
import '../../models/profile.dart';
import '../../state/inventory/inventory_provider.dart';
import '../../state/item/item_provider.dart';
import '../../state/trade/trade_provider.dart';

class TradeCreateScreen extends ConsumerStatefulWidget {
  const TradeCreateScreen({super.key});

  @override
  ConsumerState<TradeCreateScreen> createState() => _TradeCreateScreenState();
}

class _TradeCreateScreenState extends ConsumerState<TradeCreateScreen> {
  Profile? _selectedPlayer;

  // O que eu ofereço (baseado no meu inventário)
  final Map<String, int> _offeredQuantities = {};
  // O que eu quero pedir (baseado no catálogo geral)
  final Map<String, int> _requestedQuantities = {};

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(availablePlayersProvider);
    final inventoryAsync = ref.watch(inventoryProvider);
    final catalogAsync = ref.watch(itemCatalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Proposta')),
      body: playersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (players) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // 1. Selecionar Jogador
              const Text('1. Para quem?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Profile>(
                decoration: const InputDecoration(
                    hintText: 'Selecione um sobrevivente'),
                value: _selectedPlayer,
                items: players
                    .map((p) =>
                        DropdownMenuItem(value: p, child: Text(p.nickname)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedPlayer = val),
              ),

              const SizedBox(height: 32),

              // 2. Oferecer Itens (Do meu inventário)
              const Text('2. O que você oferece?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              inventoryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erro: $e'),
                data: (items) {
                  if (items.isEmpty)
                    return const Text('Seu inventário está vazio.');
                  return Column(
                    children: items
                        .map((item) =>
                            _buildInventoryRow(item, _offeredQuantities))
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 32),

              // 3. Pedir Itens (Do catálogo)
              const Text('3. O que você quer receber?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              catalogAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erro: $e'),
                data: (items) {
                  return Column(
                    children: items
                        .map((item) =>
                            _buildCatalogRow(item, _requestedQuantities))
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Enviar Proposta'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Linha para itens do inventário
  Widget _buildInventoryRow(
      InventoryItem item, Map<String, int> controllerMap) {
    final qty = controllerMap[item.itemId] ?? 0;
    return ListTile(
      title: Text(item.item?.name ?? 'Item'),
      subtitle: Text('Disponível: ${item.quantity}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: qty > 0
                ? () => setState(() => controllerMap[item.itemId] = qty - 1)
                : null,
          ),
          Text('$qty',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: qty < item.quantity
                ? () => setState(() => controllerMap[item.itemId] = qty + 1)
                : null,
          ),
        ],
      ),
    );
  }

  // Linha para itens do catálogo
  Widget _buildCatalogRow(Item item, Map<String, int> controllerMap) {
    final qty = controllerMap[item.id] ?? 0;
    return ListTile(
      title: Text(item.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: qty > 0
                ? () => setState(() => controllerMap[item.id] = qty - 1)
                : null,
          ),
          Text('$qty',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => setState(() => controllerMap[item.id] = qty + 1),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (_selectedPlayer == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecione um jogador.')));
      return;
    }

    final offered = _offeredQuantities.entries
        .where((e) => e.value > 0)
        .map((e) => {
              'item_id': e.key,
              'quantity': e.value,
            })
        .toList();

    final requested = _requestedQuantities.entries
        .where((e) => e.value > 0)
        .map((e) => {
              'item_id': e.key,
              'quantity': e.value,
            })
        .toList();

    if (offered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Você precisa oferecer pelo menos 1 item.')));
      return;
    }

    if (requested.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Você precisa pedir pelo menos 1 item.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseConfig.client.rpc('create_trade', params: {
        'p_recipient_id': _selectedPlayer!.id,
        'p_offered_items': offered,
        'p_requested_items': requested,
      });

      ref.invalidate(myTradesProvider);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro: $e'), backgroundColor: AppColors.danger));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
