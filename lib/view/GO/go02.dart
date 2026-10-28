import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of GO/GO02.kt.
class Go02Screen extends StatelessWidget {
  const Go02Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.go02),
    vm: viewModel,
    title: 'Tạo mục tiêu mới',
    section: 2,
    goal: true,
    padding: 22,
    bar: false,
    body: (s) => [
      picture('sprout_watering', height: 145),
      const T(
        'Bắt đầu một mục tiêu mới',
        size: 21,
        weight: FontWeight.w700,
        center: true,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 56),
        child: const T(
          'AI sẽ gợi ý bạn thiết lập mục tiêu\nphù hợp với nhu cầu',
          size: 16,
          center: true,
        ),
      ),
      fieldLabel('Tên mục tiêu', required: true),
      fieldBox('VD : Đạt IELTS 7.0'),
      gap(20),
      fieldLabel('Mô tả (tùy chọn)'),
      fieldBox('Chia sẻ thêm về mục tiêu của bạn...', height: 128),
      paddedButton('Tiếp tục', s.go(D.go03), vertical: 18),
    ],
  );
}
