import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of AN/AN07.kt. Screen-specific structure is kept here.
class An07Screen extends StatelessWidget {
  const An07Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.an07),
    vm: viewModel,
    title: 'Chuỗi học tập',
    section: 3,
    gap: 14,
    scrollHeader: true,
    tail: 16,

    body: (s) => [
      KColumn([
        const Icon(
          Icons.local_fire_department_outlined,
          color: Color(0xFFFF8A35),
          size: 68,
        ),
        bold('12 ngày', 32),
        const T('Chuỗi học tập liên tục!', color: muted),
      ], center: true),
      metricPair(
        ('Chuỗi hiện tại', '12', 'ngày'),
        ('Chuỗi cao nhất', '28', 'ngày'),
      ),
      KCard([
        const T('Tháng 4, 2024', weight: FontWeight.w600),
        gap(12),
        for (var start = 1; start <= 30; start += 7) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var j = 0; j < 7; j++)
                start + j <= 30
                    ? Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: start + j <= 12 || start + j == 26
                              ? StudyColors.green400
                              : const Color(0xFFE8ECE9),
                        ),
                        child: T(
                          '${start + j}',
                          size: 12,
                          color: start + j <= 12 || start + j == 26
                              ? Colors.white
                              : muted,
                        ),
                      )
                    : const SizedBox.square(dimension: 34),
            ],
          ),
          gap(8),
        ],
      ]),
    ],
  );
}
