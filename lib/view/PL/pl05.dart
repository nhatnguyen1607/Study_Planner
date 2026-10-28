import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL05.kt.
class Pl05Screen extends StatelessWidget {
  const Pl05Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl05),
    vm: viewModel,
    title: 'Danh sách kế hoạch',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    body: (s) => [
      s.tabs(['Tất cả', 'Đang diễn ra', 'Hoàn thành']),
      hero(
        Icons.auto_awesome_outlined,
        'Kế hoạch thông minh',
        'AI giúp cân bằng 3 môn và 9 giờ/tuần',
      ),
      for (final a in [
        ('Toán cao cấp', 'Thứ 2, 4, 6 · 10:00', Icons.calculate_outlined),
        ('Tiếng Anh', 'Thứ 3, 5 · 13:30', Icons.translate),
        ('Lập trình Python', 'Thứ 7 · 19:00', Icons.code),
        ('Văn học', 'Chủ nhật · 14:00', Icons.menu_book_outlined),
      ])
        selectRow(
          a.$3,
          a.$1,
          a.$2,
          selected: a.$1 == 'Toán cao cấp',
          tap: s.go(D.pl12),
        ),
      KButton('Tạo kế hoạch mới', s.go(D.pl06), leading: '+'),
    ],
  );
}
