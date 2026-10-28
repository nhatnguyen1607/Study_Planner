import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL14.kt.
class Pl14Screen extends StatelessWidget {
  const Pl14Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl14),
    vm: viewModel,
    title: 'Đánh dấu hoàn thành',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    bar: false,
    body: (s) => [
      hero(
        Icons.fact_check_outlined,
        'Hôm nay · 24 tháng 4',
        'Hoàn thành từng phần của buổi học',
      ),
      dayStrip(selected: 2),
      KCard([
        for (var i = 0; i < 4; i++)
          KRow([
            Checkbox(
              value: s.flag('done$i', i < 2),
              onChanged: (_) => s.toggle('done$i', i < 2),
            ),
            Expanded(
              child: KColumn([
                T(
                  [
                    'Đọc lý thuyết',
                    'Làm bài tập',
                    'Ôn tập kiến thức',
                    'Ghi chú nội dung khó',
                  ][i],
                  weight: FontWeight.w600,
                ),
                T(
                  ['30 phút', '60 phút', '30 phút', '15 phút'][i],
                  color: muted,
                ),
              ]),
            ),
            Icon(
              s.flag('done$i', i < 2)
                  ? Icons.check_circle_outline
                  : Icons.schedule,
              color: green,
            ),
          ]),
      ]),
      plannerStats([
        (
          Icons.task_alt,
          '${List.generate(4, (i) => s.flag('done$i', i < 2)).where((v) => v).length}/4',
          'Đã xong',
        ),
        (Icons.timer_outlined, "90'", 'Đã học'),
        (Icons.bolt, '+45', 'XP'),
      ]),
      KButton('Lưu kết quả', s.go(D.pl15)),
    ],
  );
}
