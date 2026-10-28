import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL03.kt.
class Pl03Screen extends StatelessWidget {
  const Pl03Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl03),
    vm: viewModel,
    title: 'Lịch tuần',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    body: (s) => [
      const T(
        '22 - 28 Tháng 4',
        size: 16,
        color: dark,
        weight: FontWeight.w700,
      ),
      KCard([
        KRow([
          hgap(36),
          for (final day in ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'])
            Expanded(
              child: T(day, center: true, size: 11, weight: FontWeight.w600),
            ),
        ]),
        for (var row = 0; row < 4; row++)
          SizedBox(
            height: 58,
            child: KRow([
              SizedBox(
                width: 36,
                child: T(
                  ['08h', '10h', '14h', '19h'][row],
                  size: 10,
                  color: muted,
                ),
              ),
              for (var day = 0; day < 7; day++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: [(0, 2), (1, 4), (2, 3), (3, 1)].contains((row, day))
                        ? HoverAction(
                            onTap: s.go(D.pl16),
                            radius: 9,
                            child: Container(
                              height: 54,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: [
                                  pale,
                                  const Color(0xFFFFE1D8),
                                  const Color(0xFFDCEBFF),
                                ][row % 3],
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: T(
                                ['Toán', 'Anh', 'Python'][row % 3],
                                size: 9,
                                weight: FontWeight.w700,
                              ),
                            ),
                          )
                        : const SizedBox(height: 54),
                  ),
                ),
            ]),
          ),
      ]),
      heading('Tổng quan tuần'),
      plannerStats([
        (Icons.schedule, '9 giờ', 'Thời lượng'),
        (Icons.event, '6', 'Buổi học'),
        (Icons.task_alt, '67%', 'Hoàn thành'),
      ]),
    ],
  );
}
