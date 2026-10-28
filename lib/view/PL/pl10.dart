import 'package:study_planner_flutter/model/study_time_slot.dart';
import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

import 'ideal_time_dialog.dart';

class Pl10Screen extends StatelessWidget {
  const Pl10Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;

  Future<void> _chooseTimes(BuildContext context) async {
    final selected = await showIdealTimeDialog(
      context,
      viewModel.idealTimeSlots,
    );
    if (selected != null) viewModel.setIdealTimeSlots(selected);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => KScreen(
      key: const ValueKey(D.pl10),
      vm: viewModel,
      title: 'Thiết lập thói quen',
      section: 1,
      gap: 14,
      scrollHeader: true,
      tail: 20,
      bar: false,
      body: (s) => [
        step(5, 'Thói quen'),
        hero(
          Icons.psychology_outlined,
          'Học đúng nhịp của bạn',
          'Chọn những ngày dễ duy trì nhất',
        ),
        heading('Lựa chọn ngày'),
        LayoutBuilder(
          builder: (context, constraints) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'])
                HoverAction(
                  onTap: () => s.toggle(day, ['T2', 'T4', 'T6'].contains(day)),
                  radius: 21,
                  child: Container(
                    width: (constraints.maxWidth / 7 - 2).clamp(0.0, 42.0),
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.flag(day, ['T2', 'T4', 'T6'].contains(day))
                          ? green
                          : Colors.white,
                    ),
                    child: T(
                      day,
                      weight: FontWeight.w700,
                      color: s.flag(day, ['T2', 'T4', 'T6'].contains(day))
                          ? Colors.white
                          : muted,
                    ),
                  ),
                ),
            ],
          ),
        ),
        KCard([
          HoverAction(
            key: const Key('choose-ideal-time'),
            onTap: () => _chooseTimes(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: KRow([
                const Icon(Icons.wb_sunny_outlined, color: dark, size: 21),
                const Expanded(
                  child: T('Khung giờ lý tưởng', size: 13, color: muted),
                ),
                Flexible(
                  child: T(
                    viewModel.idealTimeLabel,
                    size: 13,
                    weight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.chevron_right, color: muted, size: 18),
              ], gap: 12),
            ),
          ),
          if (viewModel.idealTimeSlots.length > 1)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final slot in StudyTimeSlot.values.where(
                  viewModel.idealTimeSlots.contains,
                ))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: light,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: T(
                      '${slot.label} ${slot.range}',
                      size: 11,
                      color: dark,
                    ),
                  ),
              ],
            ),
          KRow([
            const Icon(Icons.notifications_active_outlined, color: dark),
            const Expanded(
              child: KColumn([
                T('Nhắc nhở tự động', weight: FontWeight.w600),
                T('Trước buổi học 15 phút', color: muted),
              ]),
            ),
            Switch(
              value: s.flag('reminder', true),
              onChanged: (_) => s.toggle('reminder', true),
            ),
          ], gap: 12),
        ]),
        KButton('Xem trước kế hoạch', s.go(D.pl11)),
      ],
    ),
  );
}
