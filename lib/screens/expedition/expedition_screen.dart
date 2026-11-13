import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../state/expedition/expedition_provider.dart';
import '../../state/inventory/inventory_provider.dart';
import '../../widgets/countdown_timer.dart';
import '../../models/expedition_type.dart';

class ExpeditionScreen extends ConsumerWidget {
  const ExpeditionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeExpedition = ref.watch(activeExpeditionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Expedições')),
      body: activeExpedition.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (expedition) {
          if (expedition != null) {
            return _buildActiveExpedition(context, ref, expedition);
          }
          return _buildExpeditionList(context, ref);
        },
      ),
    );
  }

  Widget _buildActiveExpedition(
      BuildContext context, WidgetRef ref, expedition) {
    final isReady = expedition.isReady;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isReady ? Icons.check_circle : Icons.explore,
              size: 80,
              color: isReady ? AppColors.success : AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              isReady ? 'Expedição Concluída!' : 'Em andamento...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              expedition.type?.name ?? 'Local Desconhecido',
              style:
                  const TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            if (!isReady)
              CountdownTimer(
                endsAt: expedition.endsAt,
                onFinished: () => ref.invalidate(activeExpeditionProvider),
                style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            if (isReady)
              ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()));
                  try {
                    final result = await ref
                        .read(expeditionRepositoryProvider)
                        .collectRewards(expedition.id);
                    ref.invalidate(activeExpeditionProvider);
                    ref.invalidate(inventoryProvider);

                    if (context.mounted) {
                      Navigator.pop(context);
                      _showRewardsDialog(context, result['rewards']);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Erro: $e'),
                          backgroundColor: AppColors.danger));
                    }
                  }
                },
                icon: const Icon(Icons.inventory),
                label: const Text('Coletar Recompensas'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpeditionList(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(expeditionTypesProvider);

    return typesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (types) {
        if (types.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Nenhum tipo de expedição disponível.\nVerifique o banco de dados.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: types.length,
          itemBuilder: (context, index) {
            final type = types[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(type.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRiskColor(type.risk).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Risco: ${type.risk}',
                            style: TextStyle(
                                color: _getRiskColor(type.risk),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(type.description,
                        style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            'Duração: ${(type.durationSeconds / 60).toStringAsFixed(0)} min'),
                        ElevatedButton(
                          onPressed: () =>
                              _startExpedition(context, ref, type.id),
                          child: const Text('Iniciar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getRiskColor(String risk) {
    if (risk == 'alto') return AppColors.danger;
    if (risk == 'médio') return AppColors.warning;
    return AppColors.success;
  }

  Future<void> _startExpedition(
      BuildContext context, WidgetRef ref, String typeId) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      await ref.read(expeditionRepositoryProvider).startExpedition(typeId);
      ref.invalidate(activeExpeditionProvider);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro: $e'), backgroundColor: AppColors.danger));
      }
    }
  }

  void _showRewardsDialog(BuildContext context, List<dynamic> rewards) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Itens Coletados!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: rewards
              .map((r) => ListTile(
                    leading: const Icon(Icons.check_circle,
                        color: AppColors.success),
                    title: Text(r['item']),
                    trailing: Text('+${r['quantity']}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}
