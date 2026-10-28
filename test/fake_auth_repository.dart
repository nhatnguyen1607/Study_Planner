import 'dart:async';

import 'package:study_planner_flutter/model/auth_user.dart';
import 'package:study_planner_flutter/services/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthUser? initialUser}) : _user = initialUser;
  AuthUser? _user;
  final _events = StreamController<AuthUser?>.broadcast();
  String? failure;
  int requests = 0;
  Completer<void>? pending;
  @override
  Stream<AuthUser?> get userChanges async* {
    yield _user;
    yield* _events.stream;
  }

  @override
  Future<void> signIn(String email, String password) async {
    requests++;
    if (pending != null) await pending!.future;
    if (failure != null) throw AuthFailure(failure!);
    _user = AuthUser(uid: 'test-user', email: email, displayName: 'Minh Anh');
    _events.add(_user);
  }

  @override
  Future<void> register(String name, String email, String password) =>
      signIn(email, password);
  @override
  Future<void> signOut() async {
    _user = null;
    _events.add(null);
  }

  Future<void> dispose() => _events.close();
}
