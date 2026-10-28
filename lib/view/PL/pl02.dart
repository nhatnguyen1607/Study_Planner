import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL02.kt.
class Pl02Screen extends StatelessWidget {
  const Pl02Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl02),
    vm: viewModel,
    title: 'Lịch ngày',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    body: (s) => [
      dayStrip(selected: 2),
      heading('Thứ Tư, 24 tháng 4'),
      for (var i = 0; i < plannerLessons.length; i++)
        KRow(
          [
            KColumn([
              T(plannerLessons[i].$2.split(' -').first, size: 11, color: muted),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: green,
                  shape: BoxShape.circle,
                ),
              ),
              if (i < plannerLessons.length - 1)
                Container(width: 2, height: 70, color: pale),
            ], center: true),
            Expanded(
              child: lessonCard(
                plannerLessons[i],
                s.go(D.pl16),
                planner: true,
                compact: true,
              ),
            ),
          ],
          gap: 10,
          start: true,
        ),
      Align(
        alignment: Alignment.centerRight,
        child: HoverAction(
          onTap: s.go(D.pl17),
          radius: 26,
          child: iconBox(
            Icons.add,
            size: 52,
            radius: 26,
            color: Colors.white,
            bg: green,
            iconSize: 24,
          ),
        ),
      ),
    ],
  );
}
