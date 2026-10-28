import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of HM/HM07.kt.
class Hm07Screen extends StatelessWidget {
  const Hm07Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.hm07),
    vm: viewModel,
    title: 'Thông báo học tập',
    section: 4,
    padding: 14,
    top: (s) => [
      s.tabs(['Tất cả (6)', 'Nhắc nhở (3)', 'Hệ thống (3)']),
      gap(20),
    ],
    body: (s) => [
      for (var i = 0; i < 5; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: KCard(
            [
              KRow([
                iconBox(
                  [
                    Icons.notifications_outlined,
                    Icons.emoji_events_outlined,
                    Icons.assignment_outlined,
                    Icons.smart_toy_outlined,
                    Icons.assignment_outlined,
                  ][i],
                  size: 68,
                  radius: 12,
                  iconSize: 30,
                ),
                Expanded(
                  child: KColumn([
                    bold(
                      [
                        'Nhắc nhở học tập',
                        'Hoàn thành mục tiêu',
                        'Lịch học sắp diễn ra',
                        'Gợi ý từ AI',
                        'Cập nhật kế hoạch',
                      ][i],
                      20,
                    ),
                    T(
                      [
                        'Đến giờ học toán cao cấp',
                        'Bạn đã hoàn thành 3/5 mục tiêu',
                        'Lập trình python - 10:00',
                        'Có tài liệu phù hợp với bạn',
                        'Tuần này có 1 thay đổi',
                      ][i],
                      color: muted,
                    ),
                    const T('1 giờ trước', color: muted),
                  ]),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ], gap: 18),
            ],
            onTap: [
              s.go(D.hm08),
              s.go(D.go08),
              s.go(D.pl16),
              s.external('AI-14 · AI Assistant'),
              s.go(D.pl12),
            ][i],
          ),
        ),
    ],
  );
}
