import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of GO/GO09.kt.
class Go09Screen extends StatelessWidget {
  const Go09Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.go09),
    vm: viewModel,
    title: 'Cập nhật tiến độ',
    section: 2,
    goal: true,
    padding: 14,
    top: (s) => [
      s.tabs(['Hôm nay', 'Tuần', 'Tháng', 'Tùy chỉnh']),
      gap(38),
      heading('Tiến độ tổng thể'),
      gap(24),
      KCard([
        KRow([
          KRing(s.vm.goalProgress, size: 78, stroke: 8, labelSize: 16),
          Expanded(
            child: KColumn([
              bold('Đạt IELTS 7.0', 20),
              const T('còn 6 tháng', color: muted),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: pale,
              borderRadius: BorderRadius.circular(9),
            ),
            child: KColumn([
              const T('+ 5%', color: dark, weight: FontWeight.w700),
              const T('So với tuần trước', color: muted, size: 12),
            ], center: true),
          ),
        ], gap: 16),
      ]),
      gap(24),
      heading('Cập nhật mới'),
      gap(20),
    ],
    bottom: (s) => [
      paddedButton(
        s.vm.goalProgress >= 100 ? 'Đánh giá mục tiêu' : 'Đánh dấu hoàn thành',
        () {
          s.vm.updateGoalProgress(100);
          s.vm.navigate(D.go10);
        },
        vertical: 12,
      ),
    ],
    body: (s) => [
      for (final a in [
        ('Hoàn thành cột mốc', 'Đã nộp bài xong'),
        ('Giao bài tập từ mới', 'Thêm 50 từ'),
        ('Tham gia thử thách', 'Lưu 3 bài học tập'),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: KCard([
            KRow([
              iconBox(Icons.book_outlined, size: 66, radius: 10, iconSize: 31),
              Expanded(child: KColumn([bold(a.$1, 20), T(a.$2, color: muted)])),
              const T('+5%', color: dark, weight: FontWeight.w700),
            ], gap: 18),
          ], onTap: () => s.vm.updateGoalProgress(5)),
        ),
    ],
  );
}
