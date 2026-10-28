import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL06.kt.
class Pl06Screen extends StatelessWidget {
  const Pl06Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl06),
    vm: viewModel,
    title: 'Tạo kế hoạch với AI',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    bar: false,
    body: (s) => [
      step(1, 'Mục tiêu'),
      KColumn([
        const Icon(Icons.smart_toy_outlined, size: 86, color: green),
        const T(
          'Kế hoạch dành riêng cho bạn',
          size: 22,
          weight: FontWeight.w700,
          center: true,
        ),
        const T(
          'AI sẽ sắp xếp lịch học cân bằng theo mục tiêu và quỹ thời gian của bạn.',
          color: muted,
          center: true,
        ),
      ], center: true),
      const KField(
        'Mục tiêu học tập',
        value: 'Học đều 3 môn và chuẩn bị cho kỳ thi',
        icon: Icons.track_changes,
        lines: 3,
      ),
      KCard([
        plannerDetail(Icons.auto_awesome_outlined, 'AI đề xuất', '9 giờ/tuần'),
        plannerDetail(Icons.balance, 'Nhịp học', 'Cân bằng'),
        plannerDetail(
          Icons.notifications_active_outlined,
          'Nhắc nhở',
          'Tự động',
        ),
      ]),
      KButton('Bắt đầu tạo kế hoạch', s.go(D.pl07), leading: '✦'),
    ],
  );
}
