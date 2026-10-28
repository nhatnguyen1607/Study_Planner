import '../model/study_record.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/auth_user.dart';
import '../services/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this.repository) {
    _subscription = repository.userChanges.listen(
      (value) {
        user = value;
        initializing = false;
        _emit();
      },
      onError: (Object error) {
        user = null;
        initializing = false;
        sessionError = 'Không thể kiểm tra phiên đăng nhập. Vui lòng thử lại.';
        _emit();
      },
    );
  }
  final AuthRepository repository;
  late final StreamSubscription<AuthUser?> _subscription;
  AuthUser? user;
  bool registering = false;
  bool initializing = true;
  bool busy = false;
  String? sessionError;
  Future<void> Function()? beforeSignOut;
  bool _disposed = false;
  bool get authenticated => user != null;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void showRegistration(bool value) {
    if (busy) return;
    registering = value;
    _emit();
  }

  Future<String?> submit(String email, String password, String name) async {
    if (busy) return 'Vui lòng chờ yêu cầu trước hoàn tất.';
    if (registering && (name.trim().isEmpty || name.trim().length > 80)) {
      return 'Họ tên cần từ 1 đến 80 ký tự.';
    }
    busy = true;
    sessionError = null;
    _emit();
    try {
      if (registering) {
        await repository.register(name.trim(), email.trim(), password);
      } else {
        await repository.signIn(email.trim(), password);
      }
      return null;
    } on AuthFailure catch (error) {
      return error.message;
    } on FirebaseAuthException catch (error) {
      return messageForCode(error.code);
    } catch (_) {
      return 'Không thể kết nối dịch vụ. Vui lòng thử lại.';
    } finally {
      busy = false;
      _emit();
    }
  }

  Future<String?> signOut() async {
    if (busy) return 'Vui lòng chờ yêu cầu trước hoàn tất.';
    busy = true;
    _emit();
    try {
      await beforeSignOut?.call();
      await repository.signOut();
      user = null;
      registering = false;
      return null;
    } on DataFailure catch (e) {
      return e.message;
    } catch (_) {
      return 'Đăng xuất chưa thành công. Vui lòng thử lại.';
    } finally {
      busy = false;
      _emit();
    }
  }

  static String messageForCode(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Email hoặc mật khẩu không đúng.',
    'email-already-in-use' => 'Email này đã được sử dụng. Hãy đăng nhập.',
    'invalid-email' => 'Email chưa đúng định dạng.',
    'weak-password' || 'password-does-not-meet-requirements' =>
      'Mật khẩu chưa đáp ứng yêu cầu bảo mật của hệ thống.',
    'network-request-failed' => 'Không có kết nối mạng. Vui lòng kiểm tra lại.',
    'too-many-requests' => 'Có quá nhiều yêu cầu. Vui lòng thử lại sau.',
    'operation-not-allowed' =>
      'Đăng nhập Email/Password chưa được bật trong Firebase.',
    'user-disabled' => 'Tài khoản này đã bị vô hiệu hóa.',
    _ => 'Không thể xác thực tài khoản. Vui lòng thử lại.',
  };
  static String? validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Email chưa đúng định dạng';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if ((value ?? '').length < 8) return 'Mật khẩu cần ít nhất 8 ký tự';
    return null;
  }

  static String? validateLoginPassword(String? value) =>
      (value ?? '').isEmpty ? 'Vui lòng nhập mật khẩu' : null;
  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
