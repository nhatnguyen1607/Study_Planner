import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// A draft is edited locally. Dismissing or cancelling never updates the VM.
Future<int?> showTimeSettingDialog(
  BuildContext context, {
  required String title,
  required int hours,
  required int minimum,
  required int maximum,
  int? allocatedHours,
}) => showDialog<int>(
  context: context,
  builder: (_) => _TimeSettingDialog(
    title: title,
    initialHours: hours,
    minimum: minimum,
    maximum: maximum,
    allocatedHours: allocatedHours,
  ),
);

class _TimeSettingDialog extends StatefulWidget {
  const _TimeSettingDialog({
    required this.title,
    required this.initialHours,
    required this.minimum,
    required this.maximum,
    this.allocatedHours,
  });

  final String title;
  final int initialHours, minimum, maximum;
  final int? allocatedHours;

  @override
  State<_TimeSettingDialog> createState() => _TimeSettingDialogState();
}

class _TimeSettingDialogState extends State<_TimeSettingDialog> {
  late int hours = widget.initialHours;
  bool get weekly => widget.allocatedHours != null;

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
    backgroundColor: const Color(0xFFF0F1EF),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            T(widget.title, size: 22, weight: FontWeight.w700, center: true),
            gap(4),
            T(
              weekly
                  ? 'Đặt quỹ thời gian bạn có thể học'
                  : 'Số giờ học mỗi tuần',
              size: 16,
              color: muted,
              center: true,
            ),
            gap(26),
            Row(
              children: [
                _HourControl(
                  key: const Key('decrease-hours'),
                  icon: Icons.remove,
                  tooltip: 'Giảm 1 giờ',
                  onPressed: hours > widget.minimum
                      ? () => setState(() => hours--)
                      : null,
                ),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: T(
                      '$hours giờ',
                      size: 34,
                      weight: FontWeight.w700,
                      center: true,
                    ),
                  ),
                ),
                _HourControl(
                  key: const Key('increase-hours'),
                  icon: Icons.add,
                  tooltip: 'Tăng 1 giờ',
                  onPressed: hours < widget.maximum
                      ? () => setState(() => hours++)
                      : null,
                ),
              ],
            ),
            if (weekly) ...[
              gap(18),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: widget.allocatedHours! / hours,
                  minHeight: 12,
                  color: StudyColors.green400,
                  backgroundColor: const Color(0xFFDDE1DE),
                ),
              ),
              gap(5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  T(
                    'Đang phân bổ: ${widget.allocatedHours} giờ',
                    size: 11,
                    color: muted,
                  ),
                  T(
                    'Còn lại: ${hours - widget.allocatedHours!} giờ',
                    size: 11,
                    color: dark,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
            ],
            gap(12),
            Text(
              weekly
                  ? 'Quỹ tuần tối thiểu ${widget.minimum} giờ, bằng thời gian đang phân bổ.'
                  : 'Có thể phân bổ từ ${widget.minimum} đến ${widget.maximum} giờ cho môn này.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: muted),
            ),
            gap(18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('cancel-hours'),
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      foregroundColor: dark,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: dark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('confirm-hours'),
                    onPressed: () => Navigator.pop(context, hours),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      weekly ? 'Lưu thay đổi' : 'Xác nhận',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _HourControl extends StatelessWidget {
  const _HourControl({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    onPressed: onPressed,
    tooltip: tooltip,
    iconSize: 32,
    style: IconButton.styleFrom(
      fixedSize: const Size(58, 58),
      foregroundColor: dark,
      backgroundColor: const Color(0xFFD1E8D2),
      disabledForegroundColor: muted.withValues(alpha: .45),
      disabledBackgroundColor: const Color(0xFFE0E6E0),
    ),
    icon: Icon(icon),
  );
}
