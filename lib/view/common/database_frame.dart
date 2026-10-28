import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/study_record.dart';
import '../../model/study_time_slot.dart';
import '../../viewmodel/study_data_view_model.dart';
import '../AU/user_profile_gate.dart';
import '../PL/ai_schedule_screen.dart';
import 'database_forms.dart';
import 'kotlin_widgets.dart';

part 'database_planner.dart';
part 'database_goals.dart';
part 'database_home.dart';
part 'database_analytics.dart';
part 'database_profile.dart';

/// The frame files retain their layout shell; live content shares the same UI kit.
class DatabaseFrame extends StatefulWidget {
  const DatabaseFrame({super.key, required this.original});
  final KScreen original;
  @override
  State<DatabaseFrame> createState() => _DatabaseFrameState();
}

class _DatabaseFrameState extends State<DatabaseFrame> {
  StudyPlannerViewModel get vm => widget.original.vm;
  StudyDataViewModel get data => vm.database!;
  D get screen => vm.destination;
  Map<String, dynamic> get draft => data.drafts;
  void go(D next) {
    if (data.busy) return;
    if ((screen.name.startsWith('pl') &&
            screen.index >= D.pl06.index &&
            screen.index <= D.pl11.index) ||
        (screen.index >= D.go02.index && screen.index <= D.go07.index)) {
      data
          .setting('editor', {
            'values': Map<String, dynamic>.of(draft),
            'allocation': {
              'weeklyHours': vm.weeklyHours,
              'subjectHours': vm.subjectHours,
              'idealTimeSlots': vm.idealTimeSlots.map((s) => s.name).toList(),
            },
          })
          .then((ok) {
            if (ok && mounted) vm.navigate(next);
          });
    } else {
      vm.navigate(next);
    }
  }

  void changed(VoidCallback action) => setState(action);
  Future<bool> commit(Future<bool> future, [D? next]) async {
    final ok = await future;
    if (ok && mounted && next != null) go(next);
    return ok;
  }

  Widget action(String label, VoidCallback tap, {IconData? icon}) =>
      FilledButton.icon(
        onPressed: data.busy ? null : tap,
        icon: Icon(icon ?? Icons.check_circle_outline, size: 20),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(data.busy ? 'Đang lưu…' : label),
        ),
      );
  Widget empty(String label) => KCard([
    const Icon(Icons.eco_outlined, size: 38, color: green),
    gap(12),
    T(label, center: true, color: muted),
  ]);
  Widget row(
    String title,
    String detail,
    IconData icon,
    VoidCallback? tap, {
    Widget? trailing,
  }) => KCard([
    KRow([
      iconBox(icon, size: 42, radius: 14),
      Expanded(child: KColumn([bold(title), gap(4), T(detail, color: muted)])),
      trailing ?? const Icon(Icons.chevron_right, color: muted),
    ], gap: 12),
  ], onTap: tap);
  Widget field(
    String key,
    String label, {
    String initial = '',
    bool numeric = false,
    int lines = 1,
    int max = 200,
  }) => TextFormField(
    key: ValueKey(key),
    initialValue: draft[key]?.toString() ?? initial,
    onChanged: (value) => draft[key] = value,
    maxLength: max,
    maxLines: lines,
    decoration: InputDecoration(labelText: label, counterText: ''),
    keyboardType: numeric
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
  );
  String value(String key, [String fallback = '']) =>
      draft[key]?.toString() ?? fallback;
  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> get content {
    if (screen.name.startsWith('pl')) return plannerBody();
    if (screen.name.startsWith('go')) return goalsBody();
    if (screen.name.startsWith('an')) return analyticsBody();
    if (screen.name.startsWith('pr')) return profileBody();
    return homeBody();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: data,
    builder: (context, _) => PopScope(
      canPop: !data.busy,
      child: KScreen(
        key: ValueKey('live-${screen.name}'),
        vm: vm,
        live: false,
        title: widget.original.title,
        back: widget.original.back,
        bar: widget.original.bar,
        section: widget.original.section,
        goal: false,
        gap: 14,
        padding: 16,
        scrollHeader: true,
        body: (_) => [
          if (data.error != null)
            KCard([Text(data.error!, style: const TextStyle(color: danger))]),
          ...content,
        ],
      ),
    ),
  );
}
