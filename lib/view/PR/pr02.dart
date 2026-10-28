import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

import '../../model/user_profile.dart';
import '../AU/user_profile_gate.dart';

class Pr02Screen extends StatefulWidget {
  const Pr02Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  State<Pr02Screen> createState() => _Pr02ScreenState();
}

class _Pr02ScreenState extends State<Pr02Screen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      bio = TextEditingController(),
      role = TextEditingController(),
      school = TextEditingController(),
      major = TextEditingController(),
      year = TextEditingController();
  bool loaded = false, saving = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = UserProfileScope.maybeOf(context)?.profile;
    if (!loaded && p != null) {
      loaded = true;
      name.text = p.displayName;
      bio.text = p.bio ?? '';
      role.text = p.studyRole ?? '';
      school.text = p.school ?? '';
      major.text = p.major ?? '';
      year.text = p.academicYear ?? '';
    }
  }

  @override
  void dispose() {
    for (final c in [name, bio, role, school, major, year]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget field(
    String label,
    TextEditingController c, {
    int limit = 120,
    int lines = 1,
    bool required = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: c,
      enabled: !saving,
      maxLength: limit,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        hintText: required ? null : 'Chưa cập nhật',
        counterText: lines > 1 ? null : '',
      ),
      validator: (value) => required && (value ?? '').trim().isEmpty
          ? 'Vui lòng nhập họ tên'
          : null,
    ),
  );
  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    final vm = UserProfileScope.maybeOf(context);
    final current = vm?.profile;
    if (vm == null || current == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để lưu hồ sơ.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => saving = true);
    final error = await vm.save(
      UserProfile(
        uid: current.uid,
        email: current.email,
        displayName: name.text,
        bio: bio.text,
        studyRole: role.text,
        school: school.text,
        major: major.text,
        academicYear: year.text,
        photoUrl: current.photoUrl,
      ),
    );
    if (!mounted) return;
    setState(() => saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      widget.viewModel.navigate(D.pr01);
    }
  }

  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pr02),
    vm: widget.viewModel,
    title: 'Chỉnh sửa hồ sơ',
    section: 4,
    gap: 12,
    scrollHeader: true,
    tail: 18,
    body: (s) => [
      avatar(size: 104, iconSize: 86),
      Form(
        key: form,
        child: Column(
          children: [
            field('Họ và tên', name, limit: 80, required: true),
            field('Tiểu sử', bio, lines: 3),
            field('Vai trò học tập', role, limit: 40),
            field('Trường học', school),
            field('Ngành học', major),
            field('Năm học', year, limit: 40),
          ],
        ),
      ),
      const T(
        'Email được quản lý bởi Firebase Authentication. Không lưu mật khẩu trong hồ sơ.',
        size: 12,
        color: muted,
      ),
      AbsorbPointer(
        absorbing: saving,
        child: KButton(saving ? 'Đang lưu…' : 'Lưu thay đổi', save),
      ),
    ],
  );
}
