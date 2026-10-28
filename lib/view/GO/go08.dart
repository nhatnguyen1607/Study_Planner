import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of GO/GO08.kt.
class Go08Screen extends StatelessWidget {
  const Go08Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.go08),
    vm: viewModel,
    title: 'Chi tiết mục tiêu',
    section: 2,
    goal: true,
    padding: 15,
    top: (s) => [
      KCard([
        KRow([
          iconBox(
            Icons.track_changes,
            size: 62,
            radius: 31,
            bg: pale,
            color: green,
            iconSize: 36,
          ),
          Expanded(
            child: KColumn([
              bold('Đạt IELTS 7.0', 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E6E6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const T('còn 6 tháng', color: muted),
                ),
              ),
            ]),
          ),
          iconBox(
            Icons.more_vert,
            size: 36,
            radius: 18,
            bg: const Color(0xFFE7E7E7),
            iconSize: 24,
          ),
        ], gap: 16),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              KColumn([
                bold('5.5', 14),
                const T('Mốc hiện tại', color: muted),
              ], center: true),
              KRing(s.vm.goalProgress, size: 76, stroke: 8, labelSize: 16),
              KColumn([
                bold('7.0', 14),
                const T('Mục tiêu', color: muted),
              ], center: true),
            ],
          ),
        ),
        panel(
          KRow([
            const Icon(Icons.emoji_events_outlined, color: Color(0xFFFFC83D)),
            Expanded(
              child: KColumn([
                bold('Bạn đang đi đúng hướng', 14),
                const T('Tiếp tục duy trì thói quen', color: muted),
              ]),
            ),
          ], gap: 18),
          padding: 10,
          radius: 5,
        ),
      ], onTap: s.go(D.go09)),
      gap(16),
      s.tabs(['Cột mốc', 'Thống kê', 'Ghi chú']),
      gap(16),
    ],
    body: (s) => [
      for (final a in [
        ('Nắm vững ngữ pháp cơ bản', 'Hoàn thành ngày 2/2/2026', true),
        ('Luyện kỹ năng nghe', 'Hoàn thành ngày 2/2/2026', true),
        ('Tăng vốn từ vựng', 'Đang hoàn thành', false),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: KCard([
            KRow([
              Icon(
                a.$3 ? Icons.check_circle : Icons.radio_button_unchecked,
                color: a.$3 ? green : Colors.black,
                size: 28,
              ),
              Expanded(
                child: KColumn([
                  bold(a.$1, 14),
                  T(a.$2, color: muted),
                  if (!a.$3) ...[
                    gap(8),
                    const LinearProgressIndicator(
                      value: .7,
                      minHeight: 10,
                      color: StudyColors.green400,
                      backgroundColor: Colors.black12,
                    ),
                  ],
                ]),
              ),
              if (!a.$3)
                bold('70%', 14)
              else
                const Icon(Icons.chevron_right, color: Colors.grey),
            ], gap: 20),
          ], onTap: s.go(D.go09)),
        ),
    ],
  );
}
