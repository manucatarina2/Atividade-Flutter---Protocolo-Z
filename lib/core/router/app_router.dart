import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth/auth_provider.dart';
import '../../state/auth/auth_state.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/faction/faction_choice_screen.dart';
import '../../screens/shell/main_shell.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/map/map_screen.dart';
import '../../screens/expedition/expedition_screen.dart';
import '../../screens/inventory/inventory_screen.dart';
import '../../screens/trade/trade_list_screen.dart';
import '../../screens/ranking/ranking_screen.dart';
import '../../screens/profile/profile_screen.dart';

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
      final isFactionRoute = loc == '/escolher-faccao';

      // 1. Carregando sessão
      if (auth.status == AuthStatus.loading) {
        return isSplash ? null : '/splash';
      }

      // 2. Não autenticado
      if (auth.status == AuthStatus.unauthenticated) {
        if (isAuthRoute) return null;
        return '/login';
      }

      // 3. Autenticado SEM facção
      if (!auth.hasFaction) {
        if (isFactionRoute) return null;
        return '/escolher-faccao';
      }

      // 4. Autenticado COM facção
      if (isAuthRoute || isSplash || isFactionRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Rota de escolha de facção (Fica FORA do ShellRoute, pois não tem bottom nav)
      GoRoute(
        path: '/escolher-faccao',
        builder: (_, __) => const FactionChoiceScreen(),
      ),

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
