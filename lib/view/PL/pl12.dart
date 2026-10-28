import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL12.kt.
class Pl12Screen extends StatelessWidget {
  const Pl12Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl12),
    vm: viewModel,
    title: 'Chi tiết kế hoạch',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    body: (s) => [
      hero(
        Icons.calculate_outlined,
        'Toán cao cấp',
        'Chương 3 · 3 giờ/tuần',
        trailing: const KRing(75, size: 58, stroke: 7, labelSize: 13),
      ),
      plannerStats([
        (Icons.event_available_outlined, '3', 'Buổi/tuần'),
        (Icons.menu_book_outlined, '18', 'Bài học'),
        (Icons.task_alt, '75%', 'Hoàn thành'),
      ]),
      KCard([
        plannerDetail(Icons.date_range, 'Thời gian', '24/04 — 15/06'),
        plannerDetail(
          Icons.location_on_outlined,
          'Địa điểm',
          'Thư viện · P204',
        ),
        plannerDetail(
          Icons.folder_open_outlined,
          'Tài liệu',
          'Giáo trình, bài tập',
        ),
        plannerDetail(Icons.track_changes, 'Mục tiêu', 'Nắm vững kiến thức'),
      ]),
      KRow([
        for (final a in [
          (Icons.list_alt, 'Buổi học', D.pl13),
          (Icons.task_alt, 'Tiến độ', D.pl14),
          (Icons.history, 'Lịch sử', D.pl15),
        ])
          Expanded(
            child: HoverAction(
              onTap: s.go(a.$3),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: KColumn([
                  Icon(a.$1, color: dark),
                  T(a.$2, size: 12, weight: FontWeight.w600),
                ], center: true),
              ),
            ),
          ),
      ], gap: 10),
      KButton('Bắt đầu học ngay', s.go(D.pl16), leading: '▶'),
    ],
  );
}
