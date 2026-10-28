import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PL/PL16.kt.
class Pl16Screen extends StatelessWidget {
  const Pl16Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pl16),
    vm: viewModel,
    title: 'Chi tiết buổi học',
    section: 1,
    gap: 14,
    scrollHeader: true,
    tail: 20,
    bar: false,
    body: (s) => [
      hero(Icons.calculate_outlined, 'Toán cao cấp', 'Chương 2 · Đạo hàm'),
      KCard([
        plannerDetail(Icons.calendar_today, 'Ngày học', 'Thứ 4, 24/04/2024'),
        plannerDetail(Icons.schedule, 'Thời gian', '10:00 - 11:30'),
        plannerDetail(
          Icons.location_on_outlined,
          'Địa điểm',
          'Thư viện · Phòng 204',
        ),
      ]),
      heading('Nội dung buổi học'),
      KCard([
        for (var i = 0; i < 3; i++)
          KRow([
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: green,
              ),
              child: T(
                '${i + 1}',
                color: Colors.white,
                weight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: T(
                [
                  'Ôn lại định nghĩa đạo hàm',
                  'Luyện quy tắc tính nhanh',
                  'Hoàn thành 5 bài ứng dụng',
                ][i],
              ),
            ),
          ], gap: 12),
      ]),
      heading('Tài liệu'),
      selectRow(
        Icons.picture_as_pdf_outlined,
        'Giáo trình chương 2',
        'PDF · 4.2 MB',
        tap: () {},
      ),
      selectRow(
        Icons.play_circle_outline,
        'Video đạo hàm',
        '18 phút',
        tap: () {},
      ),
      KRow([
        Expanded(
          child: OutlinedButton(
            onPressed: s.go(D.pl17),
            child: const Text('Đặt lại lịch'),
          ),
        ),
        Expanded(
          child: FilledButton(
            onPressed: s.go(D.pl18),
            child: const Text('Bắt đầu học'),
          ),
        ),
      ], gap: 12),
    ],
  );
}
