import 'package:flutter/material.dart';

import 'auth_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({
    super.key,
    required this.onLogin,
    required this.onSubmit,
  });
  final VoidCallback onLogin;
  final AuthSubmit onSubmit;
  @override
  Widget build(BuildContext context) =>
      AuthForm(registering: true, onSwitch: onLogin, onSubmit: onSubmit);
}
