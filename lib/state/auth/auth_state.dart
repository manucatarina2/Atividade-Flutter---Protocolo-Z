import '../../models/profile.dart';

enum AuthStatus { loading, unauthenticated, authenticated }

class AppAuthState {
  final AuthStatus status;
  final Profile? profile;
  final String? errorMessage;

  const AppAuthState({
    required this.status,
    this.profile,
    this.errorMessage,
  });

  const AppAuthState.loading() : this(status: AuthStatus.loading);
  const AppAuthState.unauthenticated({String? error})
      : this(status: AuthStatus.unauthenticated, errorMessage: error);
  const AppAuthState.authenticated(Profile profile)
      : this(status: AuthStatus.authenticated, profile: profile);

  bool get hasFaction => profile?.hasFaction ?? false;
}
