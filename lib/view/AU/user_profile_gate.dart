import 'package:flutter/material.dart';

import '../../model/auth_user.dart';
import '../../services/user_profile_repository.dart';
import '../../viewmodel/user_profile_view_model.dart';
import 'auth_scope.dart';

class UserProfileScope extends InheritedNotifier<UserProfileViewModel> {
  const UserProfileScope({
    super.key,
    required UserProfileViewModel profile,
    required super.child,
  }) : super(notifier: profile);
  static UserProfileViewModel? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UserProfileScope>()?.notifier;
}

class UserProfileGate extends StatefulWidget {
  const UserProfileGate({
    super.key,
    required this.user,
    required this.repository,
    required this.child,
  });
  final AuthUser user;
  final UserProfileRepository repository;
  final Widget child;
  @override
  State<UserProfileGate> createState() => _UserProfileGateState();
}

class _UserProfileGateState extends State<UserProfileGate> {
  late final vm = UserProfileViewModel(widget.user, widget.repository);
  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UserProfileScope(
    profile: vm,
    child: ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        if (vm.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (vm.error != null) {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_outlined, size: 40),
                      const SizedBox(height: 16),
                      Text(vm.error!, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: vm.load,
                        child: const Text('Thử lại'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final error = await AuthScope.maybeOf(context)
                              ?.signOut();
                          if (error != null && context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(error)));
                          }
                        },
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return widget.child;
      },
    ),
  );
}
