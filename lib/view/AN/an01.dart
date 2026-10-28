import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of AN/AN01.kt. Screen-specific structure is kept here.
class An01Screen extends StatelessWidget {
  const An01Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.an01),
    vm: viewModel,
    title: 'Thống kê học tập',
    section: 3,
    gap: 14,
    scrollHeader: true,
    tail: 16,
    back: false,
    body: (s) => [
      s.tabs(['7 ngày', '30 ngày', 'Học kỳ']),
      metricPair(
        ('Tổng thời gian', '24h 30m', '↑ 21%'),
        ('Đã hoàn thành', '28 / 32', '↑ 25%'),
      ),
      KCard([
        KRow([
          const KRing(76, size: 108, stroke: 11, labelSize: 22),
          Expanded(
            child: KColumn([
              const Icon(Icons.auto_awesome_outlined, color: dark),
              const T(
                'Bạn đang duy trì thói quen học tập rất tốt!',
                size: 16,
                weight: FontWeight.w600,
              ),
            ]),
          ),
        ], gap: 18),
      ]),
      heading('Khám phá chi tiết'),
      navCard(
        Icons.schedule,
        'Thời gian học',
        'Biểu đồ ngày và tuần',
        s.go(D.an02),
      ),
      navCard(Icons.task_alt, 'Nhiệm vụ', 'Tiến độ hoàn thành', s.go(D.an03)),
      navCard(Icons.donut_large, 'Theo môn', 'Phân bổ thời gian', s.go(D.an04)),
      navCard(
        Icons.local_fire_department_outlined,
        'Chuỗi học tập',
        '12 ngày liên tiếp',
        s.go(D.an07),
      ),
      navCard(
        Icons.workspace_premium_outlined,
        'Huy hiệu',
        'Thành tích của bạn',
        s.go(D.an08),
      ),
    ],
  );
}
