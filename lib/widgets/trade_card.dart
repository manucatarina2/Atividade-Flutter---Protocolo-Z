import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../core/constants/app_colors.dart';

class TradeCard extends StatelessWidget {
  final Trade trade;
  final bool isReceived;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;

  const TradeCard({
    super.key,
    required this.trade,
    required this.isReceived,
    this.onAccept,
    this.onReject,
    this.onCancel,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return AppColors.warning;
      case 'aceita':
        return AppColors.success;
      case 'recusada':
        return AppColors.danger;
      case 'cancelada':
        return AppColors.textSecondary;
      case 'expirada':
        return Colors.grey;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherPlayer =
        isReceived ? trade.author?.nickname : trade.recipient?.nickname;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: Status e Jogador
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isReceived ? 'De: $otherPlayer' : 'Para: $otherPlayer',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(trade.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trade.status.toUpperCase(),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(trade.status)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Itens
            ...trade.items.map((item) {
              final isGivenByMe = isReceived ? item.isOffered : !item.isOffered;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Icon(
                      isGivenByMe ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                      color: isGivenByMe ? AppColors.danger : AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text('${item.quantity}x ${item.item?.name ?? "Item"}'),
                    const SizedBox(width: 4),
                    Text(isGivenByMe ? '(Você dá)' : '(Você recebe)',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              );
            }),

            // Botões de Ação
            if (trade.isPending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isReceived) ...[
                    TextButton(
                      onPressed: onReject,
                      child: const Text('Recusar',
                          style: TextStyle(color: AppColors.danger)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onAccept,
                      child: const Text('Aceitar'),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: onCancel,
                      child: const Text('Cancelar Proposta',
                          style: TextStyle(color: AppColors.danger)),
                    ),
                  ]
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
