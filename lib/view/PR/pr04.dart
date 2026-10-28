import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of PR/PR04.kt. Screen-specific structure is kept here.
class Pr04Screen extends StatelessWidget {
  const Pr04Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.pr04),
    vm: viewModel,
    title: 'Cài đặt thông báo',
    section: 4,
    gap: 12,
    scrollHeader: true,
    tail: 18,

    body: (s) => [
      notificationSwitch(
        s,
        'Nhận thông báo',
        'Duy trì động lực học tập hiệu quả',
        true,
      ),
      heading('Thông báo học tập'),
      notificationSwitch(
        s,
        'Nhắc nhở học tập',
        'Nhắc nhở theo kế hoạch đã đặt',
        true,
      ),
      notificationSwitch(
        s,
        'Thông báo mục tiêu',
        'Thông báo khi hoàn thành',
        true,
      ),
      notificationSwitch(
        s,
        'Nhắc nhở ngày giữa hạn',
        'Nhắc khi có bài thi và deadline',
        true,
      ),
      heading('Thông báo khác'),
      notificationSwitch(
        s,
        'Thông báo từ AI',
        'Gợi ý, động viên học tập',
        true,
      ),
      notificationSwitch(
        s,
        'Cập nhật tính năng',
        'Thông tin phiên bản mới',
        false,
      ),
      notificationSwitch(
        s,
        'Tin tức & nội dung',
        'Mẹo học tập, bài viết hữu ích',
        false,
      ),
    ],
  );
}
