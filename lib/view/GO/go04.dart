import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of GO/GO04.kt.
class Go04Screen extends StatelessWidget {
  const Go04Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.go04),
    vm: viewModel,
    title: 'Đặt chỉ tiêu cụ thể',
    section: 2,
    goal: true,
    padding: 9,
    bar: false,
    subtitle: 'Xác định mục tiêu với các chỉ số rõ ràng,\nđể đo lường.',
    body: (s) => [
      Align(
        alignment: Alignment.centerRight,
        child: picture('goals_target', height: 128, width: 128),
      ),
      fieldLabel('Chỉ tiêu đạt được', required: true),
      fieldBox('7.0'),
      gap(18),
      fieldLabel('Đơn vị'),
      fieldBox('IELTS Overall'),
      gap(18),
      KRow([
        Expanded(child: KColumn([fieldLabel('Mốc hiện tại'), fieldBox('5.5')])),
        SizedBox(
          width: 72,
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: const T('→', size: 34, center: true),
          ),
        ),
        Expanded(child: KColumn([fieldLabel('Mục tiêu'), fieldBox('7.0')])),
      ]),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: bold('Cần 1.5 điểm để đạt mục tiêu', 18),
      ),
      panel(
        KRow(
          [
            const Icon(
              Icons.lightbulb_outline,
              size: 34,
              color: Color(0xFFFFC83D),
            ),
            Expanded(
              child: KColumn([
                bold('AI gợi ý', 21),
                const T(
                  'Với lộ trình phù hợp bạn hoàn toàn có thể đạt 7.0 trong 3-6 tháng',
                  color: muted,
                ),
              ]),
            ),
          ],
          gap: 12,
          start: true,
        ),
      ),
      paddedButton('Tiếp tục →', s.go(D.go05), horizontal: 27, vertical: 13),
    ],
  );
}
