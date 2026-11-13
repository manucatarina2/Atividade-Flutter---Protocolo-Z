import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../core/constants/app_colors.dart';

class TradeCard extends StatelessWidget {
  final Trade trade;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const TradeCard({
    super.key,
    required this.trade,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Troca #${trade.id.substring(0, 4)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trade.status == 'pendente'
                        ? AppColors.warning
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trade.status.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Status: ${trade.status}'),
            if (trade.status == 'pendente' &&
                onAccept != null &&
                onReject != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
