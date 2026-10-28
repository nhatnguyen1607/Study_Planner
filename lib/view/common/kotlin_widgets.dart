import 'database_frame.dart';

import 'package:flutter/material.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';

import 'study_theme.dart';
import 'study_widgets.dart' show HoverAction;

export 'package:flutter/material.dart';
export 'package:study_planner_flutter/model/study_destination.dart';
export 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';

export 'study_theme.dart';
export 'study_widgets.dart' show HoverAction;

typedef D = StudyDestination;
const green = StudyColors.green500;
const dark = StudyColors.green800;
const muted = StudyColors.textSecondary;
const light = StudyColors.green50;
const pale = StudyColors.green100;
const navy = StudyColors.navy;
const peach = StudyColors.peach;
const yellow = StudyColors.yellow;
const danger = StudyColors.danger;

/// Layout primitives mirror StudyScreen / ScreenHeader / InfoCard in Compose.
/// Each screen owns its widget tree, spacing, data and navigation separately.
class KScreen extends StatefulWidget {
  const KScreen({
    super.key,
    required this.vm,
    required this.body,
    this.live = true,
    this.title,
    this.subtitle,
    this.back = true,
    this.bar = true,
    this.section = 0,
    this.goal = false,
    this.padding = 16,
    this.gap = 0,
    this.top,
    this.bottom,
    this.scrollHeader = false,
    this.tail = 16,
  });
  final bool live;
  final StudyPlannerViewModel vm;
  final List<Widget> Function(KState s) body;
  final List<Widget> Function(KState s)? top, bottom;
  final String? title, subtitle;
  final bool back, bar, goal, scrollHeader;
  final int section;
  final double padding, gap, tail;
  @override
  State<KScreen> createState() => KState();
}

class KState extends State<KScreen> {
  int tab = 0, rating = 5, selected = 24, mode = 0, color = 0, extra = 0;
  final Map<String, bool> flags = {};
  final Set<String> picked = {};
  void change(VoidCallback action) => setState(action);
  bool flag(String key, [bool initial = false]) => flags[key] ?? initial;
  void toggle(String key, [bool initial = false]) =>
      change(() => flags[key] = !flag(key, initial));
  StudyPlannerViewModel get vm => widget.vm;
  VoidCallback go(D dest) =>
      () => vm.navigate(dest);
  VoidCallback external(String code) =>
      () =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Điểm nối $code')));
  Widget tabs(List<String> labels) =>
      KTabs(labels, selected: tab, onSelect: (i) => change(() => tab = i));
  @override
  Widget build(BuildContext context) {
    if (widget.live &&
        vm.database != null &&
        ![D.pr02, D.pr03].contains(vm.destination)) {
      return DatabaseFrame(key: ValueKey(vm.destination), original: widget);
    }
    final header = widget.title == null
        ? <Widget>[]
        : <Widget>[
            KHeader(
              widget.title!,
              back: widget.back ? vm.goBack : null,
              subtitle: widget.subtitle,
            ),
          ];
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: const Color(0xFFF8FBF8),
          child: Opacity(
            opacity: .82,
            child: Image.asset(
              'assets/images/study_planner_bg.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: widget.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!widget.scrollHeader) ...header,
                        ...?widget.top?.call(this),
                        Expanded(
                          child: SingleChildScrollView(
                            child: KColumn([
                              if (widget.scrollHeader) ...header,
                              ...widget.body(this),
                              SizedBox(height: widget.tail),
                            ], gap: widget.gap),
                          ),
                        ),
                        ...?widget.bottom?.call(this),
                      ],
                    ),
                  ),
                ),
                if (widget.bar)
                  KBottom(section: widget.section, goal: widget.goal, vm: vm),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class KHeader extends StatelessWidget {
  const KHeader(this.title, {super.key, this.back, this.subtitle});
  final String title;
  final String? subtitle;
  final VoidCallback? back;
  @override
  Widget build(BuildContext context) => KColumn([
    SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 58),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                height: 1.25,
                letterSpacing: -.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (back != null)
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 58,
                height: 56,
                child: HoverAction(
                  onTap: back,
                  child: Center(
                    child: T('‹', size: 38, weight: FontWeight.w300),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    if (subtitle != null)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        child: T(subtitle!, color: muted),
      ),
  ]);
}

class KBottom extends StatelessWidget {
  const KBottom({
    super.key,
    required this.section,
    required this.goal,
    required this.vm,
  });
  final int section;
  final bool goal;
  final StudyPlannerViewModel vm;
  @override
  Widget build(BuildContext context) {
    final labels = [
      'Trang chủ',
      'Lịch',
      goal ? 'Mục tiêu' : 'Việc cần làm',
      'Thống kê',
      'Cá nhân',
    ];
    final icons = [
      Icons.home_outlined,
      Icons.calendar_month_outlined,
      Icons.check_box_outlined,
      Icons.bar_chart_outlined,
      Icons.menu,
    ];
    final dest = [D.hm01, D.pl01, goal ? D.go01 : D.hm03, D.an01, D.pr01];
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .94),
          border: Border.all(color: StudyColors.border.withValues(alpha: .75)),
        ),
        child: KRow([
          for (var i = 0; i < 5; i++)
            Expanded(
              child: HoverAction(
                onTap: () => vm.navigate(dest[i]),
                radius: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: i == section ? light : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[i],
                        size: 25,
                        color: i == section ? dark : muted,
                      ),
                      const SizedBox(height: 3),
                      T(
                        labels[i],
                        size: 10,
                        color: i == section ? dark : muted,
                        weight: i == section
                            ? FontWeight.w600
                            : FontWeight.w500,
                        lines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class T extends StatelessWidget {
  const T(
    this.text, {
    super.key,
    this.size = 14,
    this.color,
    this.weight = FontWeight.w400,
    this.center = false,
    this.lines,
  });
  final String text;
  final double size;
  final Color? color;
  final FontWeight weight;
  final bool center;
  final int? lines;
  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: center ? TextAlign.center : TextAlign.start,
    maxLines: lines,
    overflow: lines == null ? null : TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: size,
      color: color ?? StudyColors.textPrimary,
      fontWeight: weight,
      height: 1.4,
    ),
  );
}

Widget bold(String text, [double size = 16]) =>
    T(text, size: size, weight: FontWeight.w700);
Widget gap(double h) => SizedBox(height: h);
Widget hgap(double w) => SizedBox(width: w);

class KColumn extends StatelessWidget {
  const KColumn(this.children, {super.key, this.gap = 0, this.center = false});
  final List<Widget> children;
  final double gap;
  final bool center;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0 && gap > 0) SizedBox(height: gap),
        children[i],
      ],
    ],
  );
}

class KRow extends StatelessWidget {
  const KRow(this.children, {super.key, this.gap = 0, this.start = false});
  final List<Widget> children;
  final double gap;
  final bool start;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: start
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0 && gap > 0) SizedBox(width: gap),
        children[i],
      ],
    ],
  );
}

class KCard extends StatelessWidget {
  const KCard(
    this.children, {
    super.key,
    this.onTap,
    this.padding = 16,
    this.height,
  });
  final List<Widget> children;
  final VoidCallback? onTap;
  final double padding;
  final double? height;
  @override
  Widget build(BuildContext context) => HoverAction(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StudyColors.border.withValues(alpha: .7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: KColumn(children, gap: 8),
    ),
  );
}

Widget panel(
  Widget child, {
  Color color = light,
  double padding = 14,
  double radius = 6,
}) => Container(
  padding: EdgeInsets.all(padding),
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
  ),
  child: child,
);
Widget iconBox(
  IconData icon, {
  double size = 42,
  Color color = dark,
  Color bg = light,
  double radius = 14,
  double? iconSize,
}) => Container(
  width: size,
  height: size,
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.circular(radius),
  ),
  child: Icon(icon, color: color, size: iconSize ?? size * .55),
);
Widget picture(String name, {double height = 120, double? width}) =>
    Image.asset(
      'assets/images/$name.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
    );

class KButton extends StatelessWidget {
  const KButton(this.label, this.onTap, {super.key, this.leading});
  final String label;
  final String? leading;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(17),
      gradient: const LinearGradient(colors: [green, Color(0xFF6AC77A)]),
      boxShadow: const [
        BoxShadow(
          color: Color(0x30237A38),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: HoverAction(
      onTap: onTap,
      radius: 17,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              T(leading!, color: Colors.white, size: 25),
              hgap(10),
            ],
            T(label, color: Colors.white, size: 17, weight: FontWeight.w600),
          ],
        ),
      ),
    ),
  );
}

Widget paddedButton(
  String label,
  VoidCallback tap, {
  double horizontal = 0,
  double vertical = 12,
  String? leading,
}) => Padding(
  padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
  child: KButton(label, tap, leading: leading),
);

class KTabs extends StatelessWidget {
  const KTabs(this.items, {super.key, this.selected = 0, this.onSelect});
  final List<String> items;
  final int selected;
  final ValueChanged<int>? onSelect;
  @override
  Widget build(BuildContext context) => KRow([
    for (var i = 0; i < items.length; i++)
      Expanded(
        child: HoverAction(
          onTap: onSelect == null ? null : () => onSelect!(i),
          radius: 14,
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: i == selected
                  ? green
                  : Colors.white.withValues(alpha: .88),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: i == selected ? green : StudyColors.border,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: T(
                items[i],
                size: 13,
                weight: FontWeight.w600,
                color: i == selected ? Colors.white : muted,
                lines: 1,
              ),
            ),
          ),
        ),
      ),
  ], gap: 10);
}

Widget heading(String title, {String? action, VoidCallback? tap}) => KRow([
  Expanded(child: T(title, size: 19, weight: FontWeight.w600)),
  if (action != null)
    HoverAction(
      onTap: tap,
      child: T(action, size: 14, color: dark, weight: FontWeight.w500),
    ),
]);

class KRing extends StatelessWidget {
  const KRing(
    this.progress, {
    super.key,
    this.size = 76,
    this.stroke = 8,
    this.labelSize = 16,
  });
  final int progress;
  final double size, stroke, labelSize;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _RingPainter(progress, stroke),
      child: Center(
        child: T(
          '$progress%',
          size: labelSize,
          weight: FontWeight.w700,
          color: labelSize < 18 ? StudyColors.green400 : Colors.black,
        ),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.stroke);
  final int progress;
  final double stroke;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE6E7E8);
    canvas.drawArc(rect, -1.570796, 6.283185, false, paint);
    paint.color = StudyColors.green400;
    canvas.drawArc(rect, -1.570796, 6.283185 * progress / 100, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.stroke != stroke;
}

Widget progressLine(String label, int value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 5),
  child: KColumn([
    KRow([
      Expanded(child: T(label, size: 16)),
      T('$value%', size: 15, color: dark, weight: FontWeight.w600),
    ]),
    ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: value / 100,
        minHeight: 12,
        backgroundColor: const Color(0xFFE7E7E7),
        color: value >= 50
            ? StudyColors.green400
            : value >= 20
            ? yellow
            : danger,
      ),
    ),
  ]),
);

class KMetric extends StatelessWidget {
  const KMetric(this.label, this.value, this.trend, {super.key});
  final String label, value, trend;
  @override
  Widget build(BuildContext context) => KCard([
    KColumn([
      KRow([
        iconBox(iconFor(label), size: 32, radius: 10, iconSize: 18),
        Expanded(child: T(label, size: 12, color: muted)),
      ], gap: 8),
      gap(6),
      bold(value, 22),
      T(trend, size: 12, color: dark, weight: FontWeight.w600),
    ]),
  ]);
}

Widget metricPair((String, String, String) a, (String, String, String) b) =>
    KRow([
      Expanded(child: KMetric(a.$1, a.$2, a.$3)),
      Expanded(child: KMetric(b.$1, b.$2, b.$3)),
    ], gap: 12);
Widget statLine(String label, String value, {Color color = green}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: KRow([
    iconBox(
      iconFor(label),
      size: 34,
      radius: 11,
      iconSize: 19,
      color: color,
      bg: color.withValues(alpha: .16),
    ),
    Expanded(child: T(label)),
    T(value, size: 13, color: muted, weight: FontWeight.w600),
  ], gap: 11),
);
IconData iconFor(String label) {
  if (label.contains('Toán')) {
    return Icons.calculate_outlined;
  }
  if (label.contains('Văn') || label.contains('Đọc')) {
    return Icons.menu_book_outlined;
  }
  if (label.contains('Anh')) {
    return Icons.translate_outlined;
  }
  if (label.contains('Lập trình') || label.contains('Tin')) {
    return Icons.code_outlined;
  }
  if (label.contains('nhiệm vụ') ||
      label.contains('bài tập') ||
      label.contains('hoàn thành')) {
    return Icons.task_alt_outlined;
  }
  if (label.contains('thời gian') || label.contains('Ngày')) {
    return Icons.schedule_outlined;
  }
  if (label.contains('Ôn')) {
    return Icons.refresh;
  }
  if (label.contains('Phần thưởng') || label.contains('Chuỗi')) {
    return Icons.emoji_events_outlined;
  }
  if (label.contains('Tiến độ')) {
    return Icons.trending_up;
  }
  return Icons.bar_chart_outlined;
}

class KChart extends StatelessWidget {
  const KChart(this.values, this.labels, {super.key, this.height = 150});
  final List<double> values;
  final List<String> labels;
  final double height;
  @override
  Widget build(BuildContext context) => KColumn([
    SizedBox(
      height: height,
      child: ClipRect(
        child: CustomPaint(size: Size.infinite, painter: _ChartPainter(values)),
      ),
    ),
    KRow([
      for (final label in labels)
        Expanded(child: T(label, center: true, size: 11, color: muted)),
    ]),
  ], gap: 8);
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.values);
  final List<double> values;
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.isEmpty) return;
    final max = values
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, double.infinity);
    final step = size.width / values.length;
    for (var i = 0; i < values.length; i++) {
      final paint = Paint()
        ..color = i == values.length - 1 ? dark : StudyColors.green400;
      final width = (step * .42).clamp(0.0, 28.0);
      final barHeight =
          (size.height - 12).clamp(0.0, double.infinity) *
          values[i].clamp(0.0, max) /
          max;
      if (barHeight == 0) continue;
      // Rounded strokes extend beyond their endpoints. Filled bars keep both
      // rounded ends inside the plot, clear of the axis labels below it.
      final rect = Rect.fromLTWH(
        step * i + (step - width) / 2,
        size.height - barHeight,
        width,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(width / 2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.values != values;
}

Widget navCard(
  IconData icon,
  String title,
  String subtitle,
  VoidCallback? tap, {
  double iconSize = 44,
  double titleSize = 16,
}) => KCard([
  KRow([
    iconBox(icon, size: iconSize),
    Expanded(
      child: KColumn([
        T(title, size: titleSize, weight: FontWeight.w600),
        T(subtitle, size: 12, color: muted),
      ]),
    ),
    if (tap != null) const Icon(Icons.chevron_right, color: muted),
  ], gap: 13),
], onTap: tap);
Widget settingsRow(
  IconData icon,
  String title, {
  String? subtitle,
  String? value,
  VoidCallback? tap,
}) => KCard([
  KRow([
    iconBox(icon, size: 42, iconSize: 23),
    Expanded(
      child: KColumn([
        T(title, size: 16, weight: FontWeight.w600),
        if (subtitle != null) T(subtitle, size: 12, color: muted),
      ]),
    ),
    if (value != null) T(value, size: 13, color: muted),
    if (tap != null) const Icon(Icons.chevron_right, color: muted),
  ], gap: 14),
], onTap: tap);
Widget avatar({double size = 112, double iconSize = 92}) => Center(
  child: iconBox(
    Icons.account_circle_outlined,
    size: size,
    iconSize: iconSize,
    radius: size / 2,
    bg: pale,
  ),
);
Widget profileStat(IconData icon, String value, String label) => KCard([
  KColumn(
    [
      iconBox(icon, size: 34, radius: 11, iconSize: 20),
      bold(value, 18),
      Builder(
        builder: (context) => SizedBox(
          height: MediaQuery.textScalerOf(context).scale(10) * 2.8,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, height: 1.4, color: muted),
            ),
          ),
        ),
      ),
    ],
    center: true,
    gap: 6,
  ),
], padding: 12);
Widget plannerStats(List<(IconData, String, String)> values) => KRow([
  for (final v in values)
    Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .88),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: StudyColors.border),
        ),
        child: KColumn([
          Icon(v.$1, size: 22, color: dark),
          bold(v.$2, 18),
          T(v.$3, size: 10, color: muted, center: true),
        ], center: true),
      ),
    ),
], gap: 10);
Widget hero(IconData icon, String title, String subtitle, {Widget? trailing}) =>
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: light,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: pale),
      ),
      child: KRow([
        iconBox(
          icon,
          size: 54,
          iconSize: 29,
          radius: 18,
          bg: green,
          color: Colors.white,
        ),
        Expanded(
          child: KColumn([
            bold(title, 20),
            T(subtitle, size: 13, color: muted),
          ]),
        ),
        ?trailing,
      ], gap: 14),
    );
Widget plannerDetail(
  IconData icon,
  String label,
  String value, {
  VoidCallback? tap,
}) => HoverAction(
  onTap: tap,
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: KRow([
      Icon(icon, size: 21, color: dark),
      Expanded(child: T(label, size: 13, color: muted)),
      Flexible(child: T(value, size: 13, weight: FontWeight.w600)),
      if (tap != null) const Icon(Icons.chevron_right, size: 18, color: muted),
    ], gap: 12),
  ),
);
Widget selectRow(
  IconData icon,
  String title,
  String subtitle, {
  bool selected = false,
  VoidCallback? tap,
}) => HoverAction(
  onTap: tap,
  radius: 17,
  child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: selected ? light : Colors.white.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: selected ? green : StudyColors.border),
    ),
    child: KRow([
      iconBox(icon, size: 42, iconSize: 23, bg: pale, radius: 13),
      Expanded(
        child: KColumn([
          T(title, size: 15, weight: FontWeight.w600),
          T(subtitle, size: 12, color: muted),
        ]),
      ),
      Icon(
        selected ? Icons.check_circle_outline : Icons.radio_button_unchecked,
        color: selected ? green : muted,
      ),
    ], gap: 12),
  ),
);
Widget step(int number, String label) => KColumn([
  KRow([
    Expanded(
      child: T(
        'Bước $number/6',
        size: 13,
        color: dark,
        weight: FontWeight.w700,
      ),
    ),
    T(label, size: 12, color: muted),
  ]),
  gap(8),
  ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: LinearProgressIndicator(
      value: number / 6,
      minHeight: 7,
      color: green,
      backgroundColor: pale,
    ),
  ),
]);

class KField extends StatelessWidget {
  const KField(
    this.label, {
    super.key,
    this.value = '',
    this.hint,
    this.lines = 1,
    this.icon,
    this.labelOutside = false,
    this.onChanged,
  });
  final String label, value;
  final String? hint;
  final int lines;
  final IconData? icon;
  final bool labelOutside;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => KColumn([
    if (labelOutside) ...[T(label, size: 14, weight: FontWeight.w600), gap(6)],
    TextFormField(
      initialValue: value,
      minLines: lines,
      maxLines: lines == 1 ? 1 : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelOutside ? null : label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  ]);
}

Widget fieldBox(String hint, {double height = 64}) => Padding(
  padding: const EdgeInsets.only(top: 10),
  child: Container(
    height: height - 10,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: StudyColors.border),
    ),
    child: T(hint, size: 15, color: const Color(0xFF89938C)),
  ),
);
Widget fieldLabel(String title, {bool required = false}) => KRow([
  Flexible(child: T(title, size: 16, weight: FontWeight.w600)),
  if (required)
    const T(' *', size: 16, color: Color(0xFFD45555), weight: FontWeight.w600),
]);
Widget dayStrip({bool home = false, int selected = 2}) => LayoutBuilder(
  builder: (context, limits) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      for (var i = 0; i < 7; i++)
        Container(
          width: (limits.maxWidth / 7 - 3).clamp(0, home ? 44 : 43),
          height: home ? 62 : null,
          padding: home ? null : const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: i == (home ? 0 : selected)
                ? green
                : Colors.white.withValues(alpha: .9),
            borderRadius: BorderRadius.circular(home ? 16 : 15),
            border: home ? Border.all(color: StudyColors.border) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              T(
                ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][i],
                size: 11,
                color: i == (home ? 0 : selected) ? Colors.white : muted,
              ),
              if (home) gap(6),
              T(
                '${(home ? 12 : 22) + i}',
                size: 16,
                weight: FontWeight.w700,
                color: i == (home ? 0 : selected)
                    ? Colors.white
                    : StudyColors.textPrimary,
              ),
            ],
          ),
        ),
    ],
  ),
);

typedef Lesson = (String, String, String, int, bool);
const homeLessons = <Lesson>[
  ('Toán cao cấp', '10:00-11:30', 'Chương 3 - tích phân', 0, true),
  ('Tiếng anh', '12:00-14:00', 'Unit-8', 1, false),
  ('Lập trình java', '12:00-14:00', 'OOP for newbie', 2, false),
  ('Đa nền tảng', '15:00-17:00', 'Flutter', 2, false),
];
const plannerLessons = <Lesson>[
  ('Toán cao cấp', '10:00 - 11:30', 'Chương 3 · Đạo hàm', 0, false),
  ('Tiếng Anh', '13:30 - 15:00', 'Unit 8 · Speaking', 1, false),
  ('Lập trình Python', '19:00 - 21:00', 'Bài 4 · Hàm và module', 2, false),
];
const subjects = <(String, String, IconData)>[
  ('Toán cao cấp', '3 giờ/tuần', Icons.calculate_outlined),
  ('Tiếng Anh', '2 giờ/tuần', Icons.translate),
  ('Lập trình Python', '4 giờ/tuần', Icons.code),
];
Widget subjectIcon(int kind, {double size = 58}) => iconBox(
  [
    Icons.school_outlined,
    Icons.translate,
    Icons.terminal,
    Icons.school_outlined,
  ][kind],
  size: size,
  iconSize: 30,
  radius: 16,
  bg: [navy, peach, StudyColors.green400, danger][kind].withValues(alpha: .88),
  color: kind == 3 ? Colors.white : StudyColors.textPrimary,
);
Widget lessonCard(
  Lesson l,
  VoidCallback tap, {
  bool chevron = false,
  bool planner = false,
  bool compact = false,
}) => KCard(
  [
    KRow([
      subjectIcon(l.$4, size: planner ? (compact ? 46 : 54) : 58),
      Expanded(
        child: KColumn([
          if (!planner && l.$2.isNotEmpty) T(l.$2, size: 13, color: muted),
          T(
            l.$1,
            size: planner ? (compact ? 15 : 17) : 17,
            weight: FontWeight.w600,
            lines: planner ? 1 : 2,
          ),
          if (planner) T(l.$2, size: 12, color: dark, weight: FontWeight.w500),
          if (l.$3.isNotEmpty)
            T(l.$3, size: planner ? 12 : 13, color: muted, lines: 1),
        ]),
      ),
      if (chevron || planner)
        const Icon(Icons.chevron_right, color: muted)
      else
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: l.$5 ? green : Colors.black, width: 2),
            color: l.$5 ? green : Colors.transparent,
          ),
          child: l.$5
              ? const T('✓', color: Colors.white, weight: FontWeight.w700)
              : null,
        ),
    ], gap: planner ? 13 : 14),
  ],
  onTap: tap,
  padding: planner ? 16 : 14,
);

const milestoneData = <(String, String)>[
  ('Nắm vững ngữ pháp cơ bản', 'Hoàn thành trong 1 tháng'),
  ('Tăng vốn từ vựng', 'Hoàn thành trong 1 tháng'),
  ('Luyện kỹ năng nghe', 'Đạt 6.5 trong 2 tháng'),
  ('Luyện kĩ năng đọc', 'Hoàn thành trong 1 tháng'),
  ('Luyện kĩ năng viết', 'Hoàn thành trong 1 tháng'),
  ('Luyện kĩ năng nói', 'Hoàn thành trong 1 tháng'),
];
Widget stars(
  int rating,
  ValueChanged<int> set, {
  double size = 42,
  bool center = false,
}) => Row(
  mainAxisAlignment: center
      ? MainAxisAlignment.center
      : MainAxisAlignment.start,
  children: [
    for (var i = 1; i <= 5; i++)
      HoverAction(
        onTap: () => set(i),
        child: T(
          i <= rating ? '★' : '☆',
          color: const Color(0xFFFFC002),
          size: size,
        ),
      ),
  ],
);
Widget notificationSwitch(
  KState s,
  String title,
  String subtitle,
  bool initial,
) => KCard([
  KRow([
    Expanded(
      child: KColumn([
        T(title, weight: FontWeight.w600),
        T(subtitle, color: muted),
      ]),
    ),
    Switch(
      value: s.flag(title, initial),
      onChanged: (_) => s.toggle(title, initial),
      activeTrackColor: green,
      activeThumbColor: Colors.white,
    ),
  ]),
], onTap: () => s.toggle(title, initial));
