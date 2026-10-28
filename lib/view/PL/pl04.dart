import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL04.kt.
class Pl04Screen extends StatelessWidget {
  const Pl04Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl04),
    vm: viewModel,
    title: 'Lịch tháng',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    body: (s) => [
      KRow([
        Expanded(child: bold('Tháng 4, 2024', 20)),
        HoverAction(
          onTap: s.go(D.pl17),
          radius: 21,
          child: iconBox(
            Icons.add,
            size: 42,
            radius: 21,
            color: Colors.white,
            bg: green,
            iconSize: 24,
          ),
        ),
      ]),
      KCard([
        KRow([
          for (final day in ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'])
            Expanded(child: T(day, center: true, size: 11, color: muted)),
        ]),
        for (var start = 1; start <= 35; start += 7)
          KRow([
            for (var day = start; day < start + 7; day++)
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: HoverAction(
                      onTap: () => s.change(() => s.selected = day),
                      radius: 30,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: day == s.selected
                              ? green
                              : [3, 8, 12, 17, 22, 26].contains(day)
                              ? light
                              : Colors.transparent,
                        ),
                        child: T(
                          '$day',
                          size: 12,
                          color: day == s.selected
                              ? Colors.white
                              : StudyColors.textPrimary,
                          weight: day == s.selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
      ]),
      heading('Ngày ${s.selected} tháng 4'),
      for (final l in plannerLessons.take(2))
        lessonCard(l, s.go(D.pl16), planner: true, compact: true),
    ],
  );
}
