import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

import 'time_setting_dialog.dart';

class Pl09Screen extends StatelessWidget {
  const Pl09Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;

  Future<void> _editSubject(BuildContext context, int index) async {
    final hours = await showTimeSettingDialog(
      context,
      title: 'Thời lượng ${subjects[index].$1}',
      hours: viewModel.subjectHours[index],
      minimum: 1,
      maximum: viewModel.maxHoursForSubject(index),
    );
    if (hours != null) viewModel.setSubjectHours(index, hours);
  }

  Future<void> _editWeek(BuildContext context) async {
    final hours = await showTimeSettingDialog(
      context,
      title: 'Tổng thời gian học mỗi tuần',
      hours: viewModel.weeklyHours,
      minimum: viewModel.allocatedHours,
      maximum: StudyPlannerViewModel.maxWeeklyHours,
      allocatedHours: viewModel.allocatedHours,
    );
    if (hours != null) viewModel.setWeeklyHours(hours);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => KScreen(
      key: const ValueKey(D.pl09),
      vm: viewModel,
      title: 'Phân bổ thời lượng',
      section: 1,
      gap: 14,
      scrollHeader: true,
      tail: 16,
      bar: false,
      bottom: (s) => [
        paddedButton('Tiếp tục', s.go(D.pl10), horizontal: 20, vertical: 16),
      ],
      body: (s) => [
        step(4, 'Thời lượng'),
        for (var i = 0; i < subjects.length; i++)
          HoverAction(
            key: Key('subject-hours-$i'),
            onTap: () => _editSubject(context, i),
            child: Container(
              constraints: const BoxConstraints(minHeight: 104),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F4E9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFB7C6B9)),
              ),
              child: KRow([
                iconBox(
                  subjects[i].$3,
                  size: 52,
                  radius: 26,
                  bg: const Color(0xFFD1E8D2),
                  iconSize: 28,
                ),
                Expanded(
                  child: KColumn([
                    T(subjects[i].$1, size: 19, weight: FontWeight.w700),
                    T('${viewModel.subjectHours[i]} giờ / tuần', size: 16),
                  ]),
                ),
                const Icon(Icons.chevron_right, color: dark),
              ], gap: 14),
            ),
          ),
        gap(4),
        Container(
          key: const Key('weekly-allocation-summary'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: light,
            borderRadius: BorderRadius.circular(18),
          ),
          child: KColumn([
            KRow([
              Expanded(
                child: T(
                  'Tổng thời lượng: ${viewModel.allocatedHours}/${viewModel.weeklyHours} giờ',
                  size: 16,
                  color: dark,
                  weight: FontWeight.w600,
                ),
              ),
              IconButton(
                key: const Key('edit-week-hours'),
                tooltip: 'Chỉnh tổng thời gian mỗi tuần',
                onPressed: () => _editWeek(context),
                style: IconButton.styleFrom(
                  backgroundColor: pale,
                  foregroundColor: dark,
                ),
                icon: const Icon(Icons.edit_outlined, size: 22),
              ),
            ]),
            gap(8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: viewModel.allocatedHours / viewModel.weeklyHours,
                minHeight: 12,
                color: StudyColors.green400,
                backgroundColor: const Color(0xFFDDE1DE),
              ),
            ),
            gap(10),
            T(
              'Còn lại: ${viewModel.remainingHours} giờ',
              color: dark,
              size: 13,
            ),
          ]),
        ),
      ],
    ),
  );
}
