import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL18.kt.
class Pl18Screen extends StatelessWidget {
  const Pl18Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl18),
    vm: viewModel,
    title: 'Đánh giá buổi học',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    bar: false,
    body: (s) => [
      KColumn([
        const Icon(
          Icons.celebration_outlined,
          size: 82,
          color: Color(0xFFFFB300),
        ),
        bold('Buổi học hoàn thành!', 23),
        const T(
          'Bạn đã hoàn thành mục tiêu ngày hôm nay',
          color: muted,
          center: true,
        ),
      ], center: true),
      plannerStats([
        (Icons.timer_outlined, "90'", 'Thời gian'),
        (Icons.task_alt, '3/3', 'Nội dung'),
        (Icons.bolt, '+50', 'XP'),
      ]),
      heading('Cảm nhận của bạn'),
      stars(
        s.rating,
        (i) => s.change(() => s.rating = i),
        size: 39,
        center: true,
      ),
      KRow([
        for (var i = 0; i < 3; i++)
          Expanded(
            child: ActionChip(
              onPressed: () => s.change(() => s.rating = i * 2 + 1),
              label: T(['Cần thử lại', 'Ổn', 'Rất tốt'][i], size: 12),
              avatar: Icon(
                [
                  Icons.refresh,
                  Icons.sentiment_satisfied_outlined,
                  Icons.thumb_up_outlined,
                ][i],
                size: 18,
              ),
            ),
          ),
      ], gap: 9),
      const KField('Ghi chú (tùy chọn)', lines: 3),
      KButton('Hoàn thành', s.go(D.pl12), leading: '✓'),
    ],
  );
}
