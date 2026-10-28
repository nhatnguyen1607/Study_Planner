import 'package:firebase_core/firebase_core.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/auth_user.dart';
import '../model/user_profile.dart';
import '../services/user_profile_repository.dart';

class UserProfileViewModel extends ChangeNotifier {
  UserProfileViewModel(this.user, this.repository) {
    unawaited(load());
  }
  final AuthUser user;
  final UserProfileRepository repository;
  UserProfile? profile;
  String? error;
  bool loading = true, saving = false, _disposed = false, _loading = false;
  StreamSubscription<UserProfile?>? _subscription;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  String profileError(Object cause, String stage) {
    final code = cause is FirebaseException
        ? cause.code
        : cause is TimeoutException
        ? 'timeout'
        : 'unexpected';
    debugPrint('StudyDB operation=profile-$stage code=$code');
    return 'Không thể đồng bộ hồ sơ (profile-$stage / $code). Kiểm tra kết nối, Project ID và Firestore Rules rồi thử lại.';
  }

  Future<void> load() async {
    if (_loading || _disposed) return;
    _loading = true;
    loading = true;
    error = null;
    _emit();
    try {
      await repository.ensureUser(user);
      if (_disposed) return;
      await _subscription?.cancel();
      if (_disposed) return;
      _subscription = repository
          .watch(user.uid)
          .listen(
            (value) {
              profile = value;
              loading = false;
              error = value == null
                  ? 'Hồ sơ chưa tồn tại. Vui lòng thử lại.'
                  : null;
              _emit();
            },
            onError: (Object cause) {
              loading = false;
              error = profileError(cause, 'watch');
              _emit();
            },
          );
    } catch (cause) {
      loading = false;
      error = profileError(cause, 'load');
      _emit();
    } finally {
      _loading = false;
    }
  }

  Future<String?> save(UserProfile value) async {
    if (saving) return 'Đang lưu, vui lòng chờ.';
    if (value.uid != user.uid) return 'Không thể sửa hồ sơ người dùng khác.';
    if (value.displayName.trim().isEmpty ||
        value.displayName.trim().length > 80) {
      return 'Họ tên cần từ 1 đến 80 ký tự.';
    }
    if ((value.bio?.length ?? 0) > 120) return 'Tiểu sử tối đa 120 ký tự.';
    saving = true;
    _emit();
    try {
      await repository.save(value);
      if (!_disposed) profile = value;
      return null;
    } catch (cause) {
      return profileError(cause, 'save');
    } finally {
      saving = false;
      _emit();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
