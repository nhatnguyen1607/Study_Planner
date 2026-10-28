import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of HM/HM02.kt.
class Hm02Screen extends StatelessWidget {
  const Hm02Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.hm02),
    vm: viewModel,
    title: 'Học hôm nay',
    section: 1,
    padding: 14,
    top: (s) => [
      Padding(
        padding: const EdgeInsets.only(left: 13, bottom: 10),
        child: const T('Th2, 20 tháng 10, 2026', size: 17),
      ),
      dayStrip(home: true),
      gap(18),
    ],
    bottom: (s) => [
      paddedButton(
        'Thêm buổi học',
        s.go(D.pl17),
        horizontal: 22,
        vertical: 14,
        leading: '+',
      ),
    ],
    body: (s) => [
      for (final l in homeLessons) ...[lessonCard(l, s.go(D.pl16)), gap(12)],
    ],
  );
}
