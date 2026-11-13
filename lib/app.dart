import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'widgets/realtime_listener.dart';

class ProtocoloZApp extends ConsumerWidget {
  const ProtocoloZApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Protocolo Z',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        // Envolve o app inteiro para escutar notificações globais
        return RealtimeListener(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
