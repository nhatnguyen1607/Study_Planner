import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of AN/AN06.kt. Screen-specific structure is kept here.
class An06Screen extends StatelessWidget {
  const An06Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.an06),
    vm: viewModel,
    title: 'Biểu đồ tháng',
    section: 3,
    gap: 14,
    scrollHeader: true,
    tail: 16,

    body: (s) => [
      const T('Tháng 4, 2024', color: muted),
      bold('102h 20m', 30),
      const T('Trung bình 3h 30m/ngày · ↑ 22%', color: dark),
      KCard([
        const KChart([18, 24, 31, 23], ['T1', 'T2', 'T3', 'T4']),
      ]),
      heading('Top môn học trong tháng'),
      KCard([
        statLine('Toán', '34h 20m · 33%'),
        statLine('Văn', '22h 20m · 22%', color: navy),
        statLine('Anh', '18h 30m · 18%', color: peach),
        statLine('Lập trình', '12h 20m · 12%', color: yellow),
      ]),
    ],
  );
}
