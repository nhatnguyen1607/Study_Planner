import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PR/PR05.kt. Screen-specific structure is kept here.
class Pr05Screen extends StatelessWidget {
  const Pr05Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pr05),
    vm: viewModel,
    title: 'Cài đặt giao diện',
    section: 4,
    gap: 12,
    scrollHeader: true,
    tail: 18,

    body: (s) => [
      heading('Chế độ giao diện'),
      KRow([
        for (var i = 0; i < 3; i++)
          Expanded(
            child: KCard([
              KColumn([
                Icon(
                  [
                    Icons.light_mode_outlined,
                    Icons.dark_mode_outlined,
                    Icons.settings_brightness_outlined,
                  ][i],
                  color: s.mode == i ? dark : muted,
                ),
                T(
                  ['Sáng', 'Tối', 'Tự động'][i],
                  weight: FontWeight.w600,
                  color: s.mode == i ? dark : StudyColors.textPrimary,
                ),
              ], center: true),
            ], onTap: () => s.change(() => s.mode = i)),
          ),
      ], gap: 10),
      heading('Màu chủ đạo'),
      KRow([
        for (var i = 0; i < 4; i++)
          HoverAction(
            onTap: () => s.change(() => s.color = i),
            radius: 24,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: [
                  green,
                  const Color(0xFFBDE6C6),
                  const Color(0xFFD8F4ED),
                  const Color(0xFF303236),
                ][i],
                border: Border.all(
                  width: s.color == i ? 3 : 1,
                  color: s.color == i ? dark : StudyColors.border,
                ),
              ),
            ),
          ),
      ], gap: 18),
      heading('Kiểu hiển thị'),
      settingsRow(Icons.light_mode_outlined, 'Cỡ chữ', value: 'Trung bình'),
      settingsRow(
        Icons.settings_brightness_outlined,
        'Định dạng giờ',
        value: '24 giờ',
      ),
      heading('Hình nền ứng dụng'),
      KRow([
        for (final color in [
          const Color(0xFF77C788),
          const Color(0xFFCDE9D1),
          const Color(0xFFE5CCE8),
          const Color(0xFF9EB9D2),
        ])
          Expanded(
            child: HoverAction(
              onTap: () {},
              child: Container(
                height: 96,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
      ], gap: 10),
    ],
  );
}
