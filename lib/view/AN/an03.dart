import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of AN/AN03.kt. Screen-specific structure is kept here.
class An03Screen extends StatelessWidget {
  const An03Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.an03),
    vm: viewModel,
    title: 'Thống kê nhiệm vụ',
    section: 3,
    gap: 14,
    scrollHeader: true,
    tail: 16,

    body: (s) => [
      s.tabs(['Tuần', 'Tháng', 'Năm']),
      metricPair(
        ('Đã hoàn thành', '28', '↑ 25%'),
        ('Chưa hoàn thành', '4', '↓ 0%'),
      ),
      heading('Tiến độ theo ngày'),
      KCard([
        const KChart(
          [5, 4, 5, 8, 6, 4, 7],
          ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
        ),
      ]),
      heading('Loại nhiệm vụ'),
      KCard([
        statLine('Học lý thuyết', '12/14 · 86%'),
        statLine('Làm bài tập', '8/10 · 80%', color: navy),
        statLine('Ôn tập', '5/8 · 63%', color: peach),
        statLine('Đọc tài liệu', '2/2 · 100%', color: dark),
      ]),
    ],
  );
}
