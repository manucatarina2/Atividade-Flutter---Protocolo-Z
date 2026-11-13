import 'package:flutter/material.dart';
import '../models/faction.dart';

class FactionBadge extends StatelessWidget {
  final Faction faction;
  final bool large;

  const FactionBadge({super.key, required this.faction, this.large = false});

  Color _getColor() {
    try {
      return Color(int.parse(faction.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(faction.symbol, style: TextStyle(fontSize: large ? 20 : 14)),
          const SizedBox(width: 6),
          Text(
            faction.name,
            style: TextStyle(
              color: color, // Usa a cor escura da facção para o texto
              fontWeight: FontWeight.bold,
              fontSize: large ? 16 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
