import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of HM/HM10.kt.
class Hm10Screen extends StatelessWidget {
  const Hm10Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.hm10),
    vm: viewModel,
    title: 'Kết quả tìm kiếm',
    padding: 18,
    top: (s) => [
      Container(
        height: 63,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(5),
        ),
        child: KRow([
          const Icon(Icons.search, size: 34),
          bold('Python', 21),
        ], gap: 20),
      ),
      gap(14),
      s.tabs(['Tất cả', 'Môn học', 'Bài tập', 'Tài liệu']),
      gap(20),
    ],
    body: (s) => [
      for (var i = 0; i < 4; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: lessonCard(
            (
              [
                'Bài 4- Hàm và module',
                'Tài liệu python cơ bản',
                'Chủ đề hàm trong python',
                'Bài tập python - C2',
              ][i],
              '',
              'Lập trình python\n${['Môn học - Bài giảng', 'Tài liệu - PDF', 'Ghi chú - 12 trang', 'Bài tập - 5 câu'][i]}',
              i == 3 ? 3 : 2,
              false,
            ),
            i == 0
                ? s.go(D.pl16)
                : s.external(
                    i == 3 ? 'TS-07 · Task Management' : 'AI-14 · AI Assistant',
                  ),
            chevron: true,
          ),
        ),
    ],
  );
}
