import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/study_record.dart';
import '../../model/study_subject.dart';
import '../../viewmodel/study_data_view_model.dart';
import '../AU/user_profile_gate.dart';
import '../PL/ai_schedule_screen.dart';
import '../PL/time_setting_dialog.dart';
import '../PL/ideal_time_dialog.dart';
import 'database_forms.dart';
import 'figma_widgets.dart';
import 'kotlin_widgets.dart';

part 'database_planner.dart';
part 'database_goals.dart';
part 'database_home.dart';
part 'database_analytics.dart';
part 'database_profile.dart';
part 'restored_layout.dart';
part 'restored_planner.dart';
part 'restored_home.dart';
part 'restored_goals.dart';

/// Authenticated frame shell. Each flow keeps its own composition and live data.
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
  String courseQuery = '';
  int courseFilter = 0, planFilter = 0, goalsFilter = 0, detailTab = 0;
  void go(D next) {
    if (data.busy) return;
    if ((screen.index >= D.pl06.index && screen.index <= D.pl11.index) ||
        (screen.index >= D.go02.index && screen.index <= D.go07.index)) {
      data
          .setting('editor', {
            'values': Map<String, dynamic>.of(draft),
            'allocation': allocation,
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
      FigmaButton(
        label,
        onTap: data.busy ? null : tap,
        icon: icon,
        loading: data.busy,
      );
  Widget empty(String label) => KColumn([
    const Center(child: StudyMascot(pose: 'sprout_books', size: 118)),
    T(label, center: true, color: muted, size: 13),
    gap(8),
  ], center: true);
  Widget row(
    String title,
    String detail,
    IconData icon,
    VoidCallback? tap, {
    Widget? trailing,
  }) => KCard(
    [
      KRow([
        Container(
          width: 44,
          height: 46,
          decoration: BoxDecoration(
            color: subjectPalette[icon.codePoint % 7].withValues(alpha: .15),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: subjectPalette[icon.codePoint % 7],
            size: 24,
          ),
        ),
        Expanded(
          child: KColumn([
            T(title, size: 14, weight: FontWeight.w600),
            if (detail.isNotEmpty) ...[
              gap(4),
              T(detail, size: 12, color: muted),
            ],
          ]),
        ),
        trailing ?? const Icon(Icons.chevron_right, color: muted, size: 20),
      ], gap: 12),
    ],
    onTap: tap,
    padding: 13,
  );
  Widget field(
    String key,
    String label, {
    String initial = '',
    bool numeric = false,
    int lines = 1,
    int max = 200,
  }) => KColumn([
    T(label, size: 13, weight: FontWeight.w600),
    gap(7),
    TextFormField(
      key: ValueKey(key),
      initialValue: draft[key]?.toString() ?? initial,
      onChanged: (value) => draft[key] = value,
      maxLength: max,
      maxLines: lines,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(fontSize: 14, height: 1.4),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: Colors.white.withValues(alpha: .95),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: StudyColors.border),
        ),
      ),
    ),
  ]);
  String value(String key, [String fallback = '']) =>
      draft[key]?.toString() ?? fallback;
  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
    builder: (context, _) {
      final footer = fixedFooter(), children = List<Widget>.of(content);
      if (footer != null && children.isNotEmpty && children.last is FigmaButton) {
        children.removeLast();
      }
      return PopScope(
        canPop: !data.busy,
        child: KScreen(
          key: ValueKey('live-${screen.name}'),
          vm: vm,
          live: false,
          title: [D.pl01, D.pl07].contains(screen)
              ? null
              : widget.original.title,
          back: widget.original.back,
          bar: footer == null && widget.original.bar,
          section: widget.original.section,
          goal: false,
          gap: 12,
          padding: 16,
          scrollHeader: false,
          top: fixedTop() == null ? null : (_) => fixedTop()!,
          bottom: footer == null ? null : (_) => [footer],
          body: (_) => [
            if (data.error != null)
              KCard([
                Text(
                  data.error!,
                  style: const TextStyle(color: danger, fontSize: 13),
                ),
              ]),
            ...children,
          ],
        ),
      );
    },
  );
}
