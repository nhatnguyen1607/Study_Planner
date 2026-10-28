import '../model/auth_user.dart';
import '../model/user_profile.dart';

abstract interface class UserProfileRepository {
  Future<void> ensureUser(AuthUser user);
  Stream<UserProfile?> watch(String uid);
  Future<void> save(UserProfile profile);
}
