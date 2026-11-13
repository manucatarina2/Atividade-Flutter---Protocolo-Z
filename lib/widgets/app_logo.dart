import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // O Z gigante no fundo
          Text(
            'Z',
            style: TextStyle(
              fontSize: size * 0.6,
              fontWeight: FontWeight.w900,
              color: AppColors.background.withOpacity(0.2),
              height: 1,
            ),
          ),
          // O ícone de escudo sobrevivente
          Icon(
            Icons.health_and_safety,
            size: size * 0.5,
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
