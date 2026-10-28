import '../AU/user_profile_gate.dart';
import '../AU/auth_scope.dart';

import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PR/PR01.kt. Screen-specific structure is kept here.
class Pr01Screen extends StatelessWidget {
  const Pr01Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pr01),
    vm: viewModel,
    title: 'Trang cá nhân',
    section: 4,
    gap: 12,
    scrollHeader: true,
    tail: 18,
    back: false,
    body: (s) => [
      KColumn([
        avatar(),
        bold(
          UserProfileScope.maybeOf(context)?.profile?.displayName ??
              AuthScope.maybeOf(context)?.user?.displayName ??
              'Học viên',
          23,
        ),
        T(
          AuthScope.maybeOf(context)?.user?.email ??
              'Học thông minh hơn mỗi ngày',
          color: muted,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: T(
            UserProfileScope.maybeOf(context)?.profile?.bio ??
                'Cập nhật tiểu sử trong Chỉnh sửa hồ sơ.',
            size: 13,
            color: muted,
          ),
        ),
      ], center: true),
      KRow([
        Expanded(
          child: profileStat(
            Icons.local_fire_department_outlined,
            '42',
            'Ngày liên tục',
          ),
        ),
        Expanded(
          child: profileStat(Icons.school_outlined, '128', 'Bài đã học'),
        ),
        Expanded(
          child: profileStat(Icons.emoji_events_outlined, '18', 'Mục tiêu'),
        ),
      ], gap: 10),
      heading('Thành tựu gần đây'),
      settingsRow(
        Icons.emoji_events_outlined,
        'Kiên trì mỗi ngày',
        subtitle: 'Đạt 30 ngày học liên tục',
        tap: s.go(D.an09),
      ),
      settingsRow(Icons.person_outline, 'Hồ sơ cá nhân', tap: s.go(D.pr02)),
      settingsRow(
        Icons.settings_outlined,
        'Cài đặt ứng dụng',
        tap: s.go(D.pr03),
      ),
      settingsRow(Icons.help_outline, 'Trợ giúp & Phản hồi'),
    ],
  );
}
