import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL15.kt.
class Pl15Screen extends StatelessWidget {
  const Pl15Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl15),
    vm: viewModel,
    title: 'Lịch sử học tập',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    body: (s) => [
      s.tabs(['Tất cả', 'Ngày', 'Tuần', 'Tháng']),
      hero(Icons.insights, '75% hoàn thành', 'Tăng 12% so với tuần trước'),
      for (var i = 0; i < 4; i++)
        KRow(
          [
            KColumn([
              iconBox(
                i < 2 ? Icons.check : Icons.schedule,
                size: 34,
                radius: 17,
                iconSize: 18,
                bg: i < 2 ? green : pale,
                color: i < 2 ? Colors.white : dark,
              ),
              if (i < 3) Container(width: 2, height: 58, color: pale),
            ], center: true),
            Expanded(
              child: HoverAction(
                onTap: s.go(D.pl16),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: KColumn([
                    bold(
                      [
                        'Thứ 2, 22/04',
                        'Thứ 4, 24/04',
                        'Thứ 6, 26/04',
                        'Thứ 2, 29/04',
                      ][i],
                      14,
                    ),
                    T(
                      [
                        'Chương 1 · Giới hạn',
                        'Chương 2 · Đạo hàm',
                        'Chương 3 · Ứng dụng',
                        'Chương 4 · Tích phân',
                      ][i],
                      color: muted,
                      size: 13,
                    ),
                    T(
                      [
                        'Đã hoàn thành',
                        'Đang học',
                        'Đã lên lịch',
                        'Chưa bắt đầu',
                      ][i],
                      color: dark,
                      size: 12,
                      weight: FontWeight.w600,
                    ),
                  ]),
                ),
              ),
            ),
          ],
          gap: 12,
          start: true,
        ),
    ],
  );
}
