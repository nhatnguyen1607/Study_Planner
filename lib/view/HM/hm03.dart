import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of HM/HM03.kt.
class Hm03Screen extends StatelessWidget {
  const Hm03Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.hm03),
    vm: viewModel,
    title: 'Việc cần làm hôm nay',
    section: 2,
    padding: 15,
    top: (s) => [
      s.tabs(['Tất cả (6)', 'Đang làm (1)', 'Hoàn thành (1)']),
      gap(22),
    ],
    bottom: (s) => [
      paddedButton(
        'Thêm việc cần làm',
        s.external('TS-04 · Task Management'),
        horizontal: 21,
        vertical: 14,
        leading: '+',
      ),
    ],
    body: (s) => [
      for (final a in [
        ('Làm bài tập Toán cao cấp', 'Chương 3 - Bài 1, 2'),
        ('Đọc tài liệu Python', 'Chương 4 - Hàm nâng cao'),
        ('Xem video bài giảng', 'Listening Unit - 1'),
        ('Ôn từ vựng tiếng anh', 'Unit 6-7'),
        ('Chuẩn bị báo cáo nhóm', 'Nhập môn AI'),
      ])
        if (s.tab == 0 || (s.tab == 2) == s.vm.completedTasks.contains(a.$1))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: KCard([
              KRow([
                Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: s.vm.completedTasks.contains(a.$1)
                        ? green
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      width: 2,
                      color: s.vm.completedTasks.contains(a.$1)
                          ? green
                          : Colors.black,
                    ),
                  ),
                  child: s.vm.completedTasks.contains(a.$1)
                      ? const T(
                          '✓',
                          color: Colors.white,
                          weight: FontWeight.w700,
                        )
                      : null,
                ),
                Expanded(
                  child: KColumn([
                    bold(a.$1, 20),
                    T(a.$2, size: 16, color: muted),
                  ]),
                ),
              ], gap: 20),
            ], onTap: () => s.vm.toggleTask(a.$1)),
          ),
    ],
  );
}
