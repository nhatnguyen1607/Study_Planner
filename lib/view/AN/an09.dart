import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of AN/AN09.kt. Screen-specific structure is kept here.
class An09Screen extends StatelessWidget {
  const An09Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.an09),
    vm: viewModel,
    title: 'Chi tiết huy hiệu',
    section: 3,
    gap: 14,
    scrollHeader: true,
    tail: 16,

    body: (s) => [
      KColumn([
        const Icon(
          Icons.local_fire_department_outlined,
          color: Color(0xFFFF8A35),
          size: 86,
        ),
        bold('Học tập chăm chỉ', 25),
        const T('Phổ biến', color: dark),
      ], center: true),
      KCard([
        const T(
          'Duy trì thói quen học tập liên tục trong nhiều ngày.',
          color: muted,
        ),
        gap(18),
        statLine('Đã đạt được', '12/7 ngày'),
        statLine('Tiến độ', '100%'),
        statLine('Ngày đạt được', '12/04/2024'),
        statLine('Phần thưởng', '+ Ảnh hiệu bản thân'),
      ]),
      KButton('Chia sẻ thành tích', viewModel.goBack),
    ],
  );
}
