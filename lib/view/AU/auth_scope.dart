import 'package:flutter/material.dart';

import '../../viewmodel/auth_view_model.dart';

class AuthScope extends InheritedNotifier<AuthViewModel> {
  const AuthScope({
    super.key,
    required AuthViewModel auth,
    required super.child,
  }) : super(notifier: auth);
  static AuthViewModel? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()?.notifier;
}
