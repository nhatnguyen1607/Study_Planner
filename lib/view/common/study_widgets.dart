import 'package:flutter/material.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/view/common/study_theme.dart';

typedef DestinationCallback = void Function(StudyDestination destination);

class HoverAction extends StatefulWidget {
  const HoverAction({
    super.key,
    required this.child,
    this.onTap,
    this.radius = 18,
  });
  final Widget child;
  final VoidCallback? onTap;
  final double radius;

  @override
  State<HoverAction> createState() => _HoverActionState();
}

class _HoverActionState extends State<HoverAction> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        scale: hovered && widget.onTap != null ? 1.012 : 1,
        duration: const Duration(milliseconds: 140),
        child: Material(
          color: hovered && widget.onTap != null
              ? StudyColors.green50
              : Colors.transparent,
          borderRadius: BorderRadius.circular(widget.radius),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.radius),
            hoverColor: StudyColors.green100.withAlpha(110),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class StudyCard extends StatelessWidget {
  const StudyCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return HoverAction(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(240),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: StudyColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class PrimaryStudyButton extends StatelessWidget {
  const PrimaryStudyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [StudyColors.green500, Color(0xFF6AC77A)],
          ),
          borderRadius: BorderRadius.circular(17),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2836A653),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: HoverAction(
          onTap: onPressed,
          radius: 17,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 9),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
    ],
  );
}

class ProgressRing extends StatelessWidget {
  const ProgressRing(this.progress, {super.key, this.size = 62});
  final int progress;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.square(
          dimension: size,
          child: CircularProgressIndicator(
            value: progress / 100,
            strokeWidth: 7,
            backgroundColor: StudyColors.green100,
            color: StudyColors.green500,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          '$progress%',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: StudyColors.green800,
          ),
        ),
      ],
    ),
  );
}

class StudyBottomBar extends StatelessWidget {
  const StudyBottomBar({
    super.key,
    required this.current,
    required this.onNavigate,
  });
  final StudyDestination current;
  final DestinationCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, IconData, StudyDestination)>[
      ('Trang chủ', Icons.home_outlined, StudyDestination.hm01),
      ('Lịch', Icons.calendar_month_outlined, StudyDestination.pl01),
      ('Việc cần làm', Icons.check_box_outlined, StudyDestination.hm03),
      ('Thống kê', Icons.bar_chart_outlined, StudyDestination.an01),
      ('Cá nhân', Icons.person_outline, StudyDestination.pr01),
    ];
    final flow = current.name.substring(0, 2);
    int selected = switch (flow) {
      'pl' => 1,
      'an' => 3,
      'pr' => 4,
      _ when current == StudyDestination.hm03 => 2,
      _ => 0,
    };
    return NavigationBar(
      height: 70,
      backgroundColor: Colors.white.withAlpha(245),
      indicatorColor: StudyColors.green100,
      selectedIndex: selected,
      onDestinationSelected: (index) => onNavigate(entries[index].$3),
      destinations: [
        for (final item in entries)
          NavigationDestination(icon: Icon(item.$2), label: item.$1),
      ],
    );
  }
}
