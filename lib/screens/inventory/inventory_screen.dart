import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../state/inventory/inventory_provider.dart';
import '../../models/inventory_item.dart';
import '../../widgets/item_tile.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  // Cópia local para podermos brincar com os botões sem alterar o banco de verdade
  List<InventoryItem>? _localItems;

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _localItems = null); // Limpa a cópia local
              ref.invalidate(inventoryProvider);
            },
          ),
        ],
      ),
      body: inventoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar: $e')),
        data: (items) {
          // Se ainda não tem cópia local, copia os itens do banco
          _localItems ??= List.from(items);

          if (_localItems!.isEmpty) {
            return _buildEmptyState(context);
          }

          // Agrupa por categoria
          final Map<String, List<InventoryItem>> grouped = {};
          for (var item in _localItems!) {
            final cat = item.item?.category ?? 'Outros';
            grouped.putIfAbsent(cat, () => []).add(item);
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _localItems = null);
              ref.invalidate(inventoryProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                ...grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryTitle(entry.key),
                      ...entry.value.map((item) {
                        return ItemTile(
                          item: item,
                          onAdd: () => _changeQuantity(item, 1),
                          onRemove: () => _changeQuantity(item, -1),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // Função auxiliar para mudar o número na tela sem salvar no banco
  void _changeQuantity(InventoryItem item, int delta) {
    final index = _localItems!.indexWhere((i) => i.id == item.id);
    if (index == -1) return;

    final current = _localItems![index];
    final newQty = current.quantity + delta;

    if (newQty < 0) return; // Não deixa ficar negativo

    setState(() {
      _localItems![index] = InventoryItem(
        id: current.id,
        playerId: current.playerId,
        itemId: current.itemId,
        quantity: newQty,
        item: current.item,
      );
    });
  }

  Widget _buildHeader() {
    final total = _localItems!.fold(0, (sum, item) => sum + item.quantity);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total de Suprimentos',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Mochila de Sobrevivente',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            '$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text(
              'Seu inventário está vazio',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Envie sobreviventes em expedições ou faça trocas para conseguir suprimentos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
