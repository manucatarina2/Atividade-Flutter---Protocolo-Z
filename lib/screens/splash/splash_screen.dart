import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../state/auth/auth_provider.dart';
import '../../state/auth/auth_state.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 96, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'PROTOCOLO Z',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sobreviver é um trabalho em equipe',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
            if (auth.errorMessage != null) ...[
              const SizedBox(height: 24),
              Text(auth.errorMessage!,
                  style: const TextStyle(color: AppColors.danger)),
            ],
          ],
        ),
      ),
    );
  }
}
