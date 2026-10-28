import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of AN/AN04.kt. Screen-specific structure is kept here.
class An04Screen extends StatelessWidget {
  const An04Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.an04),
    vm: viewModel,
    title: 'Thống kê theo môn',
    section: 3,
    gap: 14,
    scrollHeader: true,
    tail: 16,

    body: (s) => [
      s.tabs(['Tuần', 'Tháng', 'Năm']),
      KCard([
        KRow([
          const KRing(76, size: 120, stroke: 14, labelSize: 18),
          Expanded(
            child: KColumn([
              const T('Tổng 24h 30m'),
              statLine('Toán', '34%'),
              statLine('Văn', '22%', color: navy),
              statLine('Anh', '18%', color: peach),
              statLine('Khác', '26%', color: yellow),
            ]),
          ),
        ], gap: 18),
      ], onTap: s.go(D.an06)),
      heading('So với tuần trước'),
      KCard([
        statLine('Toán', '↑ 12%'),
        statLine('Văn', '↑ 8%', color: navy),
        statLine('Tiếng Anh', '↑ 10%', color: peach),
        statLine('Tin học', '↓ 5%', color: danger),
      ]),
    ],
  );
}
