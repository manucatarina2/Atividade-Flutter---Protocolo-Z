import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/inventory/inventory_provider.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inv = ref.watch(inventoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inventário')),
      body: inv.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Inventário vazio. Faça uma expedição!'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => ListTile(
                  leading: Icon(Icons.inventory_2),
                  title: Text(items[i].item?.name ?? 'Item'),
                  trailing: Text('x${items[i].quantity}'),
                ),
              ),
      ),
    );
  }
}
