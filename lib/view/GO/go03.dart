import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of GO/GO03.kt.
class Go03Screen extends StatelessWidget {
  const Go03Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.go03),
    vm: viewModel,
    title: 'Chọn loại mục tiêu',
    section: 2,
    goal: true,
    padding: 14,
    subtitle: 'Chọn danh mục phù hợp với mục tiêu của bạn',
    top: (s) => [gap(36)],
    body: (s) => [
      for (final a in [
        ('Nhắc nhở học tập', 'TOEIC, IELTS, giao tiếp,...'),
        ('Toán học', 'Đại học, phổ thông,...'),
        ('Lập trình', 'Python, Data,...'),
        ('Kiến thức chuyên sâu', 'Kinh tế, Maketing,...'),
        ('Kỹ năng', 'Giao tiếp, tư duy,...'),
        ('Khác', 'Mục tiêu cá nhân khác...'),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: KCard([
            KRow([
              Container(
                width: 66,
                height: 66,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StudyColors.border),
                ),
                child: const Icon(Icons.book_outlined, size: 31),
              ),
              Expanded(
                child: KColumn([
                  bold(a.$1, 20),
                  T(a.$2, size: 16, color: muted),
                ]),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ], gap: 18),
          ], onTap: s.go(D.go04)),
        ),
    ],
  );
}
