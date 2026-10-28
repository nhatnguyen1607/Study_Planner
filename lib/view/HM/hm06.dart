import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of HM/HM06.kt.
class Hm06Screen extends StatelessWidget {
  const Hm06Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.hm06),
    vm: viewModel,
    title: 'Hoạt động gần đây',
    section: 3,
    padding: 15,
    top: (s) => [
      s.tabs(['Tất cả', 'Học tập', 'Hệ thống']),
      gap(20),
    ],
    body: (s) => [
      for (var i = 0; i < 6; i++)
        HoverAction(
          onTap: [
            s.external('TS-07 · Task Management'),
            s.external('FC-08 · Focus Mode'),
            s.go(D.pl12),
            s.external('TS-07 · Task Management'),
            s.go(D.go08),
            s.go(D.pl16),
          ][i],
          child: KRow(
            [
              KColumn([
                iconBox(
                  i.isEven ? Icons.check : Icons.radio_button_checked,
                  size: 40,
                  radius: 20,
                  bg: StudyColors.green400,
                  color: Colors.white,
                  iconSize: 20,
                ),
                if (i < 5)
                  Container(width: 3, height: 52, color: StudyColors.green400),
              ], center: true),
              Expanded(
                child: KColumn([
                  bold(
                    [
                      'Hoàn thành bài tập',
                      'Đã học 90 phút',
                      'Tạo 1 kế hoạch mới',
                      'Thêm việc cần làm',
                      'Hoàn thành mục tiêu',
                      'Đã tham gia buổi học',
                    ][i],
                    14,
                  ),
                  T(
                    [
                      'Toán cao cấp - chương 3',
                      'Lập trình python',
                      'Lập trình OOP',
                      'Ôn từ vựng tiếng anh',
                      'Đọc 2 tài liệu mới',
                      'Viết báo cáo',
                    ][i],
                    color: muted,
                  ),
                  T(
                    [
                      '2 giờ trước',
                      'Hôm qua',
                      'Hôm qua',
                      '2 ngày trước',
                      '3 ngày trước',
                      '3 ngày trước',
                    ][i],
                    color: muted,
                  ),
                  gap(20),
                ]),
              ),
            ],
            gap: 30,
            start: true,
          ),
        ),
    ],
  );
}
