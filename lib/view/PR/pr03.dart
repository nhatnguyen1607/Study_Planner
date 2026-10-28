import '../AU/auth_scope.dart';

import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PR/PR03.kt. Screen-specific structure is kept here.
class Pr03Screen extends StatelessWidget {
  const Pr03Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pr03),
    vm: viewModel,
    title: 'Cài đặt ứng dụng',
    section: 4,
    gap: 12,
    scrollHeader: true,
    tail: 18,

    body: (s) => [
      heading('Tài khoản'),
      settingsRow(Icons.person_outline, 'Hồ sơ cá nhân', tap: s.go(D.pr02)),
      settingsRow(Icons.lock_outline, 'Đổi bảo mật'),
      settingsRow(
        Icons.cloud_sync_outlined,
        'Đồng bộ theo tài khoản',
        value: 'Firestore',
      ),
      heading('Tùy chỉnh'),
      settingsRow(
        Icons.notifications_outlined,
        'Cài đặt thông báo',
        tap: s.go(D.pr04),
      ),
      settingsRow(
        Icons.palette_outlined,
        'Cài đặt giao diện',
        tap: s.go(D.pr05),
      ),
      settingsRow(Icons.language, 'Ngôn ngữ', value: 'Tiếng Việt'),
      if (AuthScope.maybeOf(context) != null)
        settingsRow(
          Icons.logout_rounded,
          'Đăng xuất',
          tap: () async {
            final auth = AuthScope.maybeOf(context)!;
            if (auth.busy) return;
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Đăng xuất?'),
                content: const Text(
                  'Bạn sẽ cần đăng nhập lại để sử dụng ứng dụng.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Đăng xuất'),
                  ),
                ],
              ),
            );
            if (confirmed != true) return;
            final error = await auth.signOut();
            if (error != null && context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(error)));
            }
          },
        ),
      heading('Khác'),
      settingsRow(Icons.help_outline, 'Trợ giúp & Phản hồi'),
      settingsRow(Icons.privacy_tip_outlined, 'Chính sách bảo mật'),
      settingsRow(Icons.info_outline, 'Giới thiệu ứng dụng', value: 'v1.2.0'),
    ],
  );
}
