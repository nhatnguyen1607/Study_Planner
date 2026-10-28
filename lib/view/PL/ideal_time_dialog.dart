import 'package:study_planner_flutter/model/study_time_slot.dart';
import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

Future<Set<StudyTimeSlot>?> showIdealTimeDialog(
  BuildContext context,
  Set<StudyTimeSlot> selected,
) => showDialog<Set<StudyTimeSlot>>(
  context: context,
  builder: (_) => _IdealTimeDialog(initial: selected),
);

class _IdealTimeDialog extends StatefulWidget {
  const _IdealTimeDialog({required this.initial});
  final Set<StudyTimeSlot> initial;
  @override
  State<_IdealTimeDialog> createState() => _IdealTimeDialogState();
}

class _IdealTimeDialogState extends State<_IdealTimeDialog> {
  late final Set<StudyTimeSlot> selected = {...widget.initial};

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
    backgroundColor: const Color(0xFFF8FBF8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: KColumn([
          const T(
            'Chọn khung giờ học lý tưởng',
            size: 21,
            weight: FontWeight.w700,
            center: true,
          ),
          gap(6),
          const T('Chọn 1 hoặc nhiều khung giờ', color: muted, center: true),
          gap(20),
          KRow([
            for (final slot in StudyTimeSlot.values)
              Expanded(
                child: Semantics(
                  selected: selected.contains(slot),
                  button: true,
                  label: '${slot.label}, ${slot.range}',
                  child: HoverAction(
                    key: Key('time-slot-${slot.name}'),
                    onTap: () => setState(() {
                      if (!selected.add(slot)) selected.remove(slot);
                    }),
                    radius: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selected.contains(slot) ? pale : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected.contains(slot)
                              ? green
                              : StudyColors.border,
                          width: selected.contains(slot) ? 1.5 : 1,
                        ),
                      ),
                      child: KColumn([
                        Icon(
                          selected.contains(slot)
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: selected.contains(slot) ? dark : muted,
                          size: 24,
                        ),
                        gap(8),
                        T(
                          slot.label,
                          size: 16,
                          weight: FontWeight.w600,
                          center: true,
                        ),
                        gap(4),
                        T(slot.range, size: 10, color: muted, center: true),
                      ], center: true),
                    ),
                  ),
                ),
              ),
          ], gap: 8),
          gap(14),
          T(
            selected.isEmpty
                ? 'Vui lòng chọn ít nhất một khung giờ.'
                : 'Lịch học sẽ ưu tiên các khung giờ bạn đã chọn.',
            size: 12,
            color: selected.isEmpty ? danger : muted,
            center: true,
          ),
          gap(18),
          KRow([
            Expanded(
              child: OutlinedButton(
                key: const Key('cancel-time-slots'),
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  foregroundColor: dark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Hủy'),
              ),
            ),
            Expanded(
              child: FilledButton(
                key: const Key('save-time-slots'),
                onPressed: selected.isEmpty
                    ? null
                    : () => Navigator.pop(
                        context,
                        Set<StudyTimeSlot>.of(selected),
                      ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  backgroundColor: dark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Xác nhận'),
              ),
            ),
          ], gap: 12),
        ]),
      ),
    ),
  );
}
