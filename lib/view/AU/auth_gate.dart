import '../../services/study_database.dart';
import '../../viewmodel/study_data_view_model.dart';
import 'study_database_gate.dart';
import '../../services/firestore_user_profile_repository.dart';
import '../../services/user_profile_repository.dart';
import '../../model/auth_user.dart';
import 'user_profile_gate.dart';

import 'package:flutter/material.dart';

import '../../services/firebase_auth_repository.dart';
import '../../viewmodel/auth_view_model.dart';
import '../../viewmodel/study_planner_view_model.dart';
import '../study_planner_app.dart';
import 'auth_scope.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, this.auth, this.profiles, this.syncState = true});
  final bool syncState;
  final AuthViewModel? auth;
  final UserProfileRepository? profiles;
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthViewModel auth =
      widget.auth ?? AuthViewModel(FirebaseAuthRepository());
  @override
  void dispose() {
    if (widget.auth == null) auth.dispose();
    super.dispose();
  }

  late final profiles = widget.profiles ?? FirestoreUserProfileRepository();
  bool _wasSignedIn = false;
  @override
  Widget build(BuildContext context) => AuthScope(
    auth: auth,
    child: ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        if (auth.initializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (auth.authenticated && !auth.busy) {
          _wasSignedIn = true;
          return _SignedInSession(
            key: ValueKey(auth.user!.uid),
            user: auth.user!,
            profiles: profiles,
            syncState: widget.syncState,
          );
        }
        // Keep the signed-in screen mounted during logout; dispose it on success.
        if (auth.authenticated && auth.busy && _wasSignedIn) {
          return _SignedInSession(
            key: ValueKey(auth.user!.uid),
            user: auth.user!,
            profiles: profiles,
            syncState: widget.syncState,
          );
        }
        if (!auth.authenticated) _wasSignedIn = false;
        if (auth.registering) {
          return RegisterScreen(
            key: const ValueKey('register'),
            onLogin: () => auth.showRegistration(false),
            onSubmit: auth.submit,
          );
        }
        return LoginScreen(
          key: const ValueKey('login'),
          onRegister: () => auth.showRegistration(true),
          onSubmit: auth.submit,
        );
      },
    ),
  );
}

/// Never carry locally edited planner state between different signed-in users.
class _SignedInSession extends StatefulWidget {
  const _SignedInSession({
    super.key,
    required this.user,
    required this.profiles,
    required this.syncState,
  });
  final bool syncState;
  final AuthUser user;
  final UserProfileRepository profiles;
  @override
  State<_SignedInSession> createState() => _SignedInSessionState();
}

class _SignedInSessionState extends State<_SignedInSession> {
  final vm = StudyPlannerViewModel();
  StudyDataViewModel? data;
  AuthViewModel? auth;
  Future<void> Function()? signOutGuard;
  @override
  void initState() {
    super.initState();
    if (widget.syncState) {
      data = StudyDataViewModel(StudyDatabase(widget.user.uid));
      vm.database = data;
      data!.addListener(restoreAllocation);
    }
  }

  bool allocationRestored = false;
  void restoreAllocation() {
    if (allocationRestored || data == null || !data!.ready) return;
    allocationRestored = true;
    final allocation = data!.find('settings', 'editor')?.data['allocation'];
    if (allocation is Map) {
      vm.restoreCloudState(Map<String, dynamic>.from(allocation));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth ??= AuthScope.maybeOf(context);
    if (data != null) {
      signOutGuard ??= data!.prepareSignOut;
      auth?.beforeSignOut = signOutGuard;
    }
  }

  @override
  void dispose() {
    if (identical(auth?.beforeSignOut, signOutGuard)) {
      auth?.beforeSignOut = null;
    }
    data?.removeListener(restoreAllocation);
    data?.dispose();
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Navigator(
    onGenerateRoute: (_) => MaterialPageRoute<void>(
      builder: (_) => UserProfileGate(
        user: widget.user,
        repository: widget.profiles,
        child: data == null
            ? StudyPlannerApp(viewModel: vm)
            : StudyDatabaseGate(
                data: data!,
                child: StudyPlannerApp(viewModel: vm),
              ),
      ),
    ),
  );
}
