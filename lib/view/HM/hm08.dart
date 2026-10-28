import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of HM/HM08.kt.
class Hm08Screen extends StatelessWidget {
  const Hm08Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.hm08),
    vm: viewModel,
    title: 'Chi tiết thông báo',
    padding: 12,
    bar: false,
    body: (s) => [
      Center(child: picture('home_reminder', height: 146, width: 146)),
      const T(
        'Nhắc nhở học tập',
        size: 29,
        weight: FontWeight.w700,
        center: true,
      ),
      gap(12),
      const T('Đến giờ học Toán cao cấp', size: 20, center: true),
      gap(12),
      const T(
        'Thứ 2, ngày 14 tháng 10, 2026',
        size: 18,
        color: muted,
        center: true,
      ),
      gap(12),
      const T('08:00 - 09:30', size: 18, color: muted, center: true),
      gap(28),
      panel(
        KColumn([
          lessonCard((
            'Toán cao cấp',
            '',
            'Chương 3 - Tích phân\nPhòng A2-301',
            0,
            false,
          ), s.go(D.pl16)),
          gap(14),
          KButton('Vào phòng học', s.external('FC-02 · Focus Mode')),
        ]),
        color: const Color(0xFFF1F1F1),
        padding: 16,
        radius: 5,
      ),
      gap(26),
      KCard([
        KRow(
          [
            const Icon(
              Icons.lightbulb_outline,
              size: 34,
              color: Color(0xFFFFC83D),
            ),
            Expanded(
              child: KColumn([
                bold('Mẹo nhỏ', 20),
                const T(
                  'Hãy chuẩn bị đầy đủ tài liệu và nhắc lại lý thuyết về tập học trước khi học nhé !',
                  color: muted,
                ),
              ]),
            ),
          ],
          gap: 14,
          start: true,
        ),
      ]),
    ],
  );
}
