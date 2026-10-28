import 'package:firebase_auth/firebase_auth.dart';

import '../model/auth_user.dart';
import 'firestore_user_profile_repository.dart';
import 'user_profile_repository.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, UserProfileRepository? profiles})
    : _auth = auth ?? FirebaseAuth.instance,
      _profiles = profiles ?? FirestoreUserProfileRepository();
  final FirebaseAuth _auth;
  final UserProfileRepository _profiles;
  @override
  Stream<AuthUser?> get userChanges => _auth.userChanges().map(
    (user) => user == null
        ? null
        : AuthUser(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
          ),
  );
  @override
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> register(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    try {
      await credential.user!.updateDisplayName(name);
    } on FirebaseAuthException {
      // Account creation has already succeeded: do not invite another registration.
      await _auth.signOut();
      throw const AuthFailure(
        'Tài khoản đã được tạo nhưng chưa lưu được tên. Hãy đăng nhập bằng email và mật khẩu vừa tạo.',
      );
    }
    try {
      await _profiles.ensureUser(
        AuthUser(
          uid: credential.user!.uid,
          email: credential.user!.email,
          displayName: name,
        ),
      );
    } catch (_) {
      // Authentication and Firestore are separate services, not one transaction.
      // Keep the account. The signed-in profile gate offers a safe retry.
      throw const AuthFailure(
        'Tài khoản đã được tạo nhưng chưa lưu được hồ sơ. Hãy thử lại ở màn hồ sơ; không cần đăng ký lại.',
      );
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
