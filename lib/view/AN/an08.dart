import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of AN/AN08.kt. Screen-specific structure is kept here.
class An08Screen extends StatelessWidget {
  const An08Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.an08),
    vm: viewModel,
    title: 'Huy hiệu thành tích',
    section: 3,
    gap: 14,
    scrollHeader: true,
    tail: 16,

    body: (s) => [
      s.tabs(['Tất cả', 'Đã đạt', 'Chưa đạt']),
      for (final row in [
        [
          (
            Icons.local_fire_department_outlined,
            'Học tập chăm chỉ',
            'Đạt 7 ngày liên tục',
          ),
          (
            Icons.emoji_events_outlined,
            'Bậc thầy thời gian',
            'Hoàn thành 50 nhiệm vụ',
          ),
        ],
        [
          (Icons.menu_book_outlined, 'Nhà nghiên cứu', 'Học 7 môn khác nhau'),
          (Icons.star_outline, 'Kỷ luật vàng', 'Hoàn thành 30 ngày'),
        ],
        [
          (Icons.lock_outline, 'Đọc sách chăm chỉ', 'Đọc 20 tài liệu mới'),
          (Icons.lock_clock_outlined, 'Thành thạo ôn tập', 'Ôn 20 lần'),
        ],
      ])
        KRow([
          for (final badge in row)
            Expanded(
              child: KCard([
                KColumn(
                  [
                    Icon(badge.$1, size: 40, color: dark),
                    T(
                      badge.$2,
                      size: 14,
                      weight: FontWeight.w600,
                      center: true,
                    ),
                    T(badge.$3, size: 11, color: muted, center: true),
                  ],
                  gap: 6,
                  center: true,
                ),
              ], onTap: s.go(D.an09)),
            ),
        ], gap: 12),
    ],
  );
}
