import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/inventory_item.dart';

class ItemTile extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  const ItemTile({
    super.key,
    required this.item,
    this.onTap,
    this.onAdd,
    this.onRemove,
  });

  IconData _getIcon(String? iconName, String category) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop;
      case 'restaurant':
        return Icons.restaurant;
      case 'medical_services':
        return Icons.medical_services;
      case 'construction':
        return Icons.construction;
      case 'local_gas_station':
        return Icons.local_gas_station;
      default:
        switch (category) {
          case 'água':
            return Icons.water_drop;
          case 'comida':
            return Icons.restaurant;
          case 'medicamentos':
            return Icons.medical_services;
          case 'ferramentas':
            return Icons.construction;
          case 'combustível':
            return Icons.local_gas_station;
          default:
            return Icons.inventory_2;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemName = item.item?.name ?? 'Item Desconhecido';
    final category = item.item?.category ?? 'outros';
    final iconData = _getIcon(item.item?.icon, category);

    // Lógica para avisar que está acabando
    final isLowStock = item.quantity > 0 && item.quantity <= 3;
    final isEmpty = item.quantity == 0;

    Color borderColor = isEmpty
        ? AppColors.danger.withOpacity(0.3)
        : isLowStock
            ? AppColors.warning.withOpacity(0.5)
            : Colors.grey.shade200;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Ícone
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEmpty
                      ? AppColors.surfaceLight
                      : AppColors.primaryLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData,
                    color:
                        isEmpty ? AppColors.textSecondary : AppColors.primary,
                    size: 28),
              ),
              const SizedBox(width: 16),

              // Nome e Categoria
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isEmpty
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: isEmpty ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Controles de Quantidade (Visual)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: AppColors.danger),
                    onPressed: onRemove,
                    tooltip: 'Diminuir',
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isEmpty
                          ? AppColors.danger.withOpacity(0.1)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isEmpty
                            ? AppColors.danger
                            : (isLowStock
                                ? AppColors.warning
                                : AppColors.textPrimary),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppColors.success),
                    onPressed: onAdd,
                    tooltip: 'Aumentar',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
