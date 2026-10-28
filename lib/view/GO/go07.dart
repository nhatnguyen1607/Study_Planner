import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of GO/GO07.kt.
class Go07Screen extends StatelessWidget {
  const Go07Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.go07),
    vm: viewModel,
    title: 'Xem trước mục tiêu',
    section: 2,
    goal: true,
    padding: 19,
    subtitle: 'Kiểm tra lại thông tin trước khi tạo',
    body: (s) => [
      gap(22),
      KCard([
        KRow([
          iconBox(
            Icons.track_changes,
            size: 60,
            radius: 30,
            bg: pale,
            color: green,
            iconSize: 34,
          ),
          Expanded(
            child: KColumn([
              bold('Đạt IELTS 7.0', 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: pale,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const T('Tiếng anh', color: dark),
                ),
              ),
            ]),
          ),
        ], gap: 16),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: const T(
            'Mình muốn trình độ tiếng anh đạt\nIELTS 7',
            color: muted,
          ),
        ),
        for (final a in [
          ('◎', 'Chỉ tiêu', '7.0 IELTS Overall'),
          ('⚑', 'Mốc hiện tại', '5.5'),
          ('◷', 'Thời hạn', '6 Tháng\n15 Tháng 6, 2026'),
          ('⚑', 'Số cột mốc', '6 Cột mốc'),
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: KRow([
              SizedBox(width: 38, child: T(a.$1, size: 25)),
              Expanded(child: T(a.$2, color: muted)),
              Flexible(
                child: SizedBox(width: 145, child: T(a.$3, color: muted)),
              ),
            ], start: true),
          ),
      ]),
      gap(22),
      KCard([
        heading('Các cột mốc chính'),
        for (final a in milestoneData.take(3))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: KRow([
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: StudyColors.green400,
                ),
                child: const T('✓', color: Colors.white),
              ),
              Expanded(child: T(a.$1, size: 18, color: muted)),
            ], gap: 15),
          ),
        const T('+3 cột mốc khác', size: 20, color: muted),
      ], onTap: s.go(D.go08)),
      paddedButton('Tạo mục tiêu', s.go(D.go08), vertical: 15),
    ],
  );
}
