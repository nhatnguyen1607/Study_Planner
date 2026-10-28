import 'package:flutter/material.dart';

import '../../model/study_subject.dart';
import 'study_theme.dart';
import 'study_widgets.dart' show HoverAction;

class StudyMascot extends StatelessWidget {
  const StudyMascot({super.key, this.pose = 'home_welcome', this.size = 96});
  final String pose;
  final double size;
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/$pose.png',
    width: size,
    height: size,
    fit: BoxFit.contain,
    semanticLabel: 'Linh vật mầm cây Study Planner',
  );
}

class FigmaButton extends StatelessWidget {
  const FigmaButton(
    this.label, {
    super.key,
    this.onTap,
    this.icon,
    this.loading = false,
    this.secondary = false,
  });
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading, secondary;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null && !loading,
    child: Opacity(
      opacity: onTap == null && !loading ? .55 : 1,
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        width: double.infinity,
        decoration: BoxDecoration(
          color: secondary ? Colors.white : null,
          gradient: secondary
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF2FA64B), Color(0xFF66C778)],
                ),
          borderRadius: BorderRadius.circular(14),
          border: secondary ? Border.all(color: StudyColors.border) : null,
          boxShadow: secondary
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x192E7D32),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: HoverAction(
          onTap: loading ? null : onTap,
          radius: 14,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 9),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    size: 19,
                    color: secondary ? StudyColors.green800 : Colors.white,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    loading ? 'Đang lưu…' : label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: secondary ? StudyColors.green800 : Colors.white,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

const subjectPalette = [
  Color(0xFF375F7F),
  Color(0xFFE19579),
  Color(0xFF66BB6A),
  Color(0xFFD73555),
  Color(0xFF49C6B1),
  Color(0xFF8D67CE),
  Color(0xFFC6BD34),
];
IconData figmaSubjectIcon(String key) => switch (key) {
  'math' => Icons.functions,
  'language' => Icons.translate,
  'code' => Icons.terminal,
  'history' => Icons.account_balance_outlined,
  'science' => Icons.science_outlined,
  _ => Icons.menu_book_outlined,
};

class FigmaSubjectTile extends StatelessWidget {
  const FigmaSubjectTile({
    super.key,
    required this.subject,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });
  final StudySubject subject;
  final bool selected;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => HoverAction(
    onTap: onTap,
    radius: 17,
    child: Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: selected ? const Color(0xFFB6DCBA) : StudyColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D173426),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 60,
            margin: const EdgeInsets.only(right: 13),
            decoration: BoxDecoration(
              color: subjectPalette[subject.color % subjectPalette.length],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              figmaSubjectIcon(subject.icon),
              color: Colors.white,
              size: 28,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: StudyColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected
                    ? StudyColors.green800
                    : const Color(0xFF91A795),
                size: 24,
              ),
        ],
      ),
    ),
  );
}
