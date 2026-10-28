import 'package:flutter/material.dart';

import 'auth_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.onRegister,
    required this.onSubmit,
  });
  final VoidCallback onRegister;
  final AuthSubmit onSubmit;
  @override
  Widget build(BuildContext context) =>
      AuthForm(registering: false, onSwitch: onRegister, onSubmit: onSubmit);
}
