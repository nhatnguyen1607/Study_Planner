import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../viewmodel/auth_view_model.dart';
import '../common/study_theme.dart';
import '../common/study_widgets.dart';

typedef AuthSubmit = Future<String?> Function(
  String email,
  String password,
  String name,
);

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.registering,
    required this.onSwitch,
    required this.onSubmit,
  });
  final bool registering;
  final VoidCallback onSwitch;
  final AuthSubmit onSubmit;
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool submitting = false;
  String? error;
  bool hidePassword = true;
  bool hideConfirm = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (submitting || !form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      submitting = true;
      error = null;
    });
    String? result;
    try {
      result = await widget.onSubmit(email.text, password.text, name.text);
    } catch (_) {
      result = 'Không thể kết nối dịch vụ. Vui lòng thử lại.';
    }
    if (!mounted) return;
    TextInput.finishAutofillContext(shouldSave: false);
    setState(() {
      submitting = false;
      error = result;
    });
  }

  Widget field({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool secret = false,
    bool hidden = false,
    VoidCallback? toggle,
    bool last = false,
    TextInputType? keyboard,
    Iterable<String>? autofill,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      enabled: !submitting,
      validator: validator,
      obscureText: secret && hidden,
      keyboardType: keyboard,
      autofillHints: autofill,
      autocorrect: !secret,
      enableSuggestions: !secret,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: (_) {
        if (last) {
          submit();
        } else {
          FocusScope.of(context).nextFocus();
        }
      },
      scrollPadding: const EdgeInsets.all(32),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        prefixIcon: Icon(icon, size: 21, color: StudyColors.textSecondary),
        suffixIcon: secret
            ? IconButton(
                tooltip: hidden ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                onPressed: toggle,
                icon: Icon(
                  hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 21,
                  color: StudyColors.textSecondary,
                ),
              )
            : null,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final registering = widget.registering;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: StudyColors.surface),
          Opacity(
            opacity: .82,
            child: Image.asset(
              'assets/images/study_planner_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  StudyColors.green500,
                                  Color(0xFF6AC77A),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.eco_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Study Planner',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Học thông minh hơn mỗi ngày',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: StudyColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  registering
                                      ? 'Khởi đầu nhỏ,\ntương lai lớn.'
                                      : 'Chào mừng\nbạn trở lại!',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    height: 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: StudyColors.green800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  registering
                                      ? 'Cùng xây dựng thói quen học tập tốt hơn.'
                                      : 'Tiếp tục hành trình chinh phục mục tiêu của bạn.',
                                  style: const TextStyle(
                                    color: StudyColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ExcludeSemantics(
                            child: Image.asset(
                              registering
                                  ? 'assets/images/goals_new_seed.png'
                                  : 'assets/images/home_welcome.png',
                              width: 88,
                              height: 106,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      StudyCard(
                        padding: const EdgeInsets.all(20),
                        child: AutofillGroup(
                          child: Form(
                            key: form,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  registering ? 'Tạo tài khoản' : 'Đăng nhập',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  registering
                                      ? 'Một nơi cho mọi kế hoạch của bạn.'
                                      : 'Hôm nay, mình cùng tiến bộ thêm một chút.',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: StudyColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (registering)
                                  field(
                                    label: 'Họ và tên',
                                    hint: 'Tên của bạn',
                                    icon: Icons.person_outline,
                                    controller: name,
                                    autofill: const [AutofillHints.name],
                                    validator: (value) =>
                                        (value ?? '').trim().isEmpty
                                        ? 'Vui lòng nhập họ và tên'
                                        : null,
                                  ),
                                field(
                                  label: 'Email',
                                  hint: 'ban@example.com',
                                  icon: Icons.mail_outline,
                                  controller: email,
                                  keyboard: TextInputType.emailAddress,
                                  autofill: const [AutofillHints.email],
                                  validator: AuthViewModel.validateEmail,
                                ),
                                field(
                                  label: 'Mật khẩu',
                                  hint: 'Ít nhất 8 ký tự',
                                  icon: Icons.lock_outline,
                                  controller: password,
                                  secret: true,
                                  hidden: hidePassword,
                                  last: !registering,
                                  autofill: [
                                    registering
                                        ? AutofillHints.newPassword
                                        : AutofillHints.password,
                                  ],
                                  validator: registering
                                      ? AuthViewModel.validatePassword
                                      : AuthViewModel.validateLoginPassword,
                                  toggle: () => setState(
                                    () => hidePassword = !hidePassword,
                                  ),
                                ),
                                if (registering)
                                  field(
                                    label: 'Xác nhận mật khẩu',
                                    hint: 'Nhập lại mật khẩu',
                                    icon: Icons.verified_user_outlined,
                                    controller: confirm,
                                    secret: true,
                                    hidden: hideConfirm,
                                    last: true,
                                    validator: (value) =>
                                        value != password.text ||
                                            (value ?? '').isEmpty
                                        ? 'Mật khẩu xác nhận chưa khớp'
                                        : null,
                                    toggle: () => setState(
                                      () => hideConfirm = !hideConfirm,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                if (error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: Semantics(
                                      liveRegion: true,
                                      child: Text(
                                        error!,
                                        style: const TextStyle(
                                          color: StudyColors.danger,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (submitting)
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                AbsorbPointer(
                                  absorbing: submitting,
                                  child: Opacity(
                                    opacity: submitting ? .6 : 1,
                                    child: PrimaryStudyButton(
                                      label: registering
                                          ? 'Tạo tài khoản'
                                          : 'Đăng nhập',
                                      icon: registering
                                          ? Icons.person_add_alt_1_outlined
                                          : Icons.login_rounded,
                                      onPressed: submit,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      registering
                                          ? 'Đã có tài khoản?'
                                          : 'Chưa có tài khoản?',
                                      style: const TextStyle(
                                        color: StudyColors.textSecondary,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: submitting
                                          ? null
                                          : () {
                                              FocusScope.of(context).unfocus();
                                              widget.onSwitch();
                                            },
                                      child: Text(
                                        registering
                                            ? 'Đăng nhập'
                                            : 'Đăng ký ngay',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // const Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Icon(
                      //       Icons.info_outline,
                      //       size: 17,
                      //       color: StudyColors.textSecondary,
                      //     ),
                      //     SizedBox(width: 8),
                      //     // Expanded(
                      //     //   child: Text(
                      //     //     'Tài khoản được xác thực bằng Firebase. Dữ liệu kế hoạch và thống kê hiện vẫn là dữ liệu mẫu.',
                      //     //     style: TextStyle(
                      //     //       fontSize: 12,
                      //     //       height: 1.5,
                      //     //       color: StudyColors.textSecondary,
                      //     //     ),
                      //     //   ),
                      //     // ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
