import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL07.kt.
class Pl07Screen extends StatelessWidget {
  const Pl07Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl07),
    vm: viewModel,
    title: 'Chọn môn học',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    bar: false,
    body: (s) => [
      step(2, 'Môn học'),
      for (var i = 0; i < 6; i++)
        selectRow(
          [
            Icons.calculate_outlined,
            Icons.translate,
            Icons.code,
            Icons.menu_book_outlined,
            Icons.account_balance_outlined,
            Icons.science_outlined,
          ][i],
          [
            'Toán cao cấp',
            'Tiếng Anh',
            'Lập trình Python',
            'Văn học',
            'Lịch sử',
            'Vật lý',
          ][i],
          [
            'Môn bắt buộc',
            'Kỹ năng',
            'Môn chuyên ngành',
            'Tự chọn',
            'Tự chọn',
            'Môn bắt buộc',
          ][i],
          selected: s.flag('subject$i', i < 3),
          tap: () => s.toggle('subject$i', i < 3),
        ),
      KButton(
        'Tiếp tục (${List.generate(6, (i) => s.flag('subject$i', i < 3)).where((v) => v).length} môn)',
        s.go(D.pl08),
      ),
    ],
  );
}
