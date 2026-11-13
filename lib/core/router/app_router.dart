import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth/auth_provider.dart';
import '../../state/auth/auth_state.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/shell/main_shell.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/map/map_screen.dart';
import '../../screens/expedition/expedition_screen.dart';
import '../../screens/inventory/inventory_screen.dart';
import '../../screens/trade/trade_list_screen.dart';
import '../../screens/ranking/ranking_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../widgets/loading_indicator.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<AppAuthState>(const AppAuthState.loading());

  ref.listen<AppAuthState>(authProvider, (_, next) {
    notifier.value = next;
  }, fireImmediately: true);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;

      final isSplash = loc == '/splash';
      final isAuthRoute = loc == '/login' || loc == '/register';

      if (auth.status == AuthStatus.loading) {
        return isSplash ? null : '/splash';
      }

      if (auth.status == AuthStatus.unauthenticated) {
        // Pode ir para login/register; qualquer outra rota interna volta pro login
        if (isAuthRoute) return null;
        return '/login';
      }

      // Autenticado
      if (!auth.hasFaction) {
        // Sem facção: ainda não temos a tela de escolha, então mandamos pra home provisoriamente
        // (vamos ajustar quando criarmos a tela de escolha de facção)
        if (isAuthRoute || isSplash) return '/home';
        return null;
      }

      // Autenticado com facção
      if (isAuthRoute || isSplash) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/mapa', builder: (_, __) => const MapScreen()),
          GoRoute(
              path: '/expedicoes',
              builder: (_, __) => const ExpeditionScreen()),
          GoRoute(
              path: '/inventario', builder: (_, __) => const InventoryScreen()),
          GoRoute(path: '/trocas', builder: (_, __) => const TradeListScreen()),
          GoRoute(path: '/ranking', builder: (_, __) => const RankingScreen()),
          GoRoute(path: '/perfil', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      appBar: AppBar(title: const Text('Erro')),
      body: Center(child: Text('Rota não encontrada: ${state.uri}')),
    ),
  );

  ref.onDispose(() {
    notifier.dispose();
    router.dispose();
  });

  return router;
});
