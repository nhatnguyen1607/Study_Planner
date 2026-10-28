import '../model/auth_user.dart';

abstract interface class AuthRepository {
  Stream<AuthUser?> get userChanges;
  Future<void> signIn(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<void> signOut();
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
}
