import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of AN/AN05.kt. Screen-specific structure is kept here.
class An05Screen extends StatelessWidget {
  const An05Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.an05),
    vm: viewModel,
    title: 'Biểu đồ tuần',
    section: 3,
    gap: 14,
    scrollHeader: true,
    tail: 16,

    body: (s) => [
      const T('15 - 21 Tháng 4, 2024', color: muted),
      bold('24h 30m', 30),
      const T('↑ 18% so với tuần trước', color: dark),
      KCard([
        const KChart(
          [3, 2, 4, 3.5, 5, 4, 4.5],
          ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
        ),
      ]),
      metricPair(
        ('Thời gian học', '+18%', 'Tăng tốt'),
        ('Số nhiệm vụ', '+12%', 'Đúng tiến độ'),
      ),
    ],
  );
}
