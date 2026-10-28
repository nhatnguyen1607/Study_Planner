import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL13.kt.
class Pl13Screen extends StatelessWidget {
  const Pl13Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl13),
    vm: viewModel,
    title: 'Các buổi học',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    body: (s) => [
      hero(
        Icons.calendar_month_outlined,
        'Lộ trình 6 tuần',
        '4/6 buổi đã hoàn thành',
      ),
      for (var i = 0; i < 5; i++)
        KRow(
          [
            KColumn([
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < 2 ? green : Colors.white,
                ),
                child: T(
                  '${i + 1}',
                  weight: FontWeight.w700,
                  color: i < 2 ? Colors.white : dark,
                ),
              ),
              if (i < 4) Container(width: 2, height: 62, color: pale),
            ], center: true),
            Expanded(
              child: KCard([
                T(
                  [
                    'Bài 1 · Giới hạn',
                    'Bài 2 · Đạo hàm',
                    'Bài 3 · Ứng dụng đạo hàm',
                    'Bài 4 · Tích phân',
                    'Bài 5 · Phương trình',
                  ][i],
                  size: 15,
                  weight: FontWeight.w600,
                ),
                T(
                  [
                    'Thứ 2, 22/04 · Đã hoàn thành',
                    'Thứ 4, 24/04 · Đang học',
                    'Thứ 6, 26/04 · 10:00',
                    'Thứ 2, 29/04 · 10:00',
                    'Thứ 4, 01/05 · 10:00',
                  ][i],
                  size: 12,
                  color: muted,
                ),
              ], onTap: s.go(D.pl16)),
            ),
          ],
          gap: 12,
          start: true,
        ),
      KButton('Thêm buổi học', s.go(D.pl17), leading: '+'),
    ],
  );
}
