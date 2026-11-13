import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/profile_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());
final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final profileRepo = ref.watch(profileRepositoryProvider);
  return AuthNotifier(authRepo, profileRepo);
});

class AuthNotifier extends StateNotifier<AppAuthState> {
  final AuthRepository _authRepo;
  final ProfileRepository _profileRepo;

  // Aqui está o segredo: usamos o AuthState DO SUPABASE explicitamente
  StreamSubscription<AuthState>? _sub;

  AuthNotifier(this._authRepo, this._profileRepo)
      : super(const AppAuthState.loading()) {
    _init();
  }

  Future<void> _init() async {
    if (_authRepo.currentSession != null) {
      await _loadProfile();
    } else {
      state = const AppAuthState.unauthenticated();
    }

    _sub = _authRepo.authStateChanges.listen((authState) async {
      final event = authState.event;
      if (event == AuthChangeEvent.signedIn) {
        await _loadProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AppAuthState.unauthenticated();
      }
    });
  }

  Future<void> _loadProfile() async {
    state = const AppAuthState.loading();
    try {
      final profile = await _profileRepo.fetchMyProfile();
      if (profile == null) {
        state =
            const AppAuthState.unauthenticated(error: 'Perfil não encontrado');
      } else {
        state = AppAuthState.authenticated(profile);
      }
    } catch (e) {
      state = AppAuthState.unauthenticated(error: e.toString());
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _authRepo.signIn(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return _translateError(e);
    } catch (e) {
      return 'Erro ao entrar: $e';
    }
  }

  Future<String?> signUp(String nickname, String email, String password) async {
    try {
      await _authRepo.signUp(
          nickname: nickname, email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return _translateError(e);
    } catch (e) {
      return 'Erro ao cadastrar: $e';
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
  }

  Future<void> refresh() async => _loadProfile();

  String _translateError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials'))
      return 'E-mail ou senha incorretos.';
    if (msg.contains('already registered') ||
        msg.contains('user already exists')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (msg.contains('network') || msg.contains('socket')) {
      return 'Sem conexão. Verifique sua internet.';
    }
    if (msg.contains('password'))
      return 'Senha inválida (mínimo 6 caracteres).';
    return e.message;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
