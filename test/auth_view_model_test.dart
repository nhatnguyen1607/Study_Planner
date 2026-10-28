import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/model/auth_user.dart';
import 'package:study_planner_flutter/viewmodel/auth_view_model.dart';

import 'fake_auth_repository.dart';

void main() {
  Future<void> flush() => Future<void>.delayed(Duration.zero);
  test('Restores a session and signs out', () async {
    final repo = FakeAuthRepository(
      initialUser: const AuthUser(uid: 'existing'),
    );
    final vm = AuthViewModel(repo);
    await flush();
    expect(vm.initializing, false);
    expect(vm.user?.uid, 'existing');
    expect(await vm.signOut(), isNull);
    expect(vm.authenticated, false);
    vm.dispose();
    await repo.dispose();
  });
  test('Backend failure must not grant access', () async {
    final repo = FakeAuthRepository()
      ..failure = 'Email hoặc mật khẩu không đúng.';
    final vm = AuthViewModel(repo);
    await flush();
    expect(await vm.submit('a@example.com', 'wrong', ''), repo.failure);
    expect(vm.authenticated, false);
    expect(vm.busy, false);
    vm.dispose();
    await repo.dispose();
  });
  test('Prevents duplicate submissions while awaiting backend', () async {
    final repo = FakeAuthRepository()..pending = Completer<void>();
    final vm = AuthViewModel(repo);
    await flush();
    final first = vm.submit('a@example.com', 'secret123', '');
    expect(vm.busy, true);
    expect(await vm.submit('a@example.com', 'secret123', ''), isNotNull);
    expect(repo.requests, 1);
    repo.pending!.complete();
    expect(await first, isNull);
    await flush();
    expect(vm.authenticated, true);
    vm.dispose();
    await repo.dispose();
  });
  test('Login permits existing short passwords; registration requires 8 characters', () {
    expect(AuthViewModel.validateLoginPassword('123456'), isNull);
    expect(AuthViewModel.validatePassword('123456'), isNotNull);
    expect(
      AuthViewModel.messageForCode('invalid-credential'),
      'Email hoặc mật khẩu không đúng.',
    );
  });
}
