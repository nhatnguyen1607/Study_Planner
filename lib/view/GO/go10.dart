import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of GO/GO10.kt.
class Go10Screen extends StatelessWidget {
  const Go10Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.go10),
    vm: viewModel,
    title: 'Đánh giá mục tiêu',
    section: 2,
    goal: true,
    padding: 15,
    bar: false,
    body: (s) => [
      KRow([
        picture('goals_celebrate', height: 120, width: 120),
        Expanded(
          child: KColumn([
            const T(
              'Chúc mừng !',
              size: 28,
              color: Color(0xFFFFB900),
              weight: FontWeight.w700,
            ),
            const T(
              'Bạn đã hoàn thành mục tiêu này!',
              color: muted,
              weight: FontWeight.w700,
            ),
          ]),
        ),
      ]),
      gap(20),
      KCard([
        KRow([
          iconBox(
            Icons.track_changes,
            size: 50,
            radius: 25,
            bg: pale,
            color: green,
          ),
          bold('Đạt IELTS 7.0', 14),
        ], gap: 12),
        gap(18),
        KRow([
          for (final a in [
            ('5.5', 'Mốc ban đầu'),
            ('7.0', 'Mục tiêu'),
            ('6 tháng', 'Thời gian'),
            ('100%', 'Hoàn thành'),
          ])
            Expanded(
              child: KColumn([
                T(a.$1, size: 20, color: dark, weight: FontWeight.w700),
                T(a.$2, size: 13, color: muted),
              ], center: true),
            ),
        ]),
      ]),
      gap(28),
      heading('Cảm nhận của bạn'),
      gap(24),
      stars(s.vm.rating, s.vm.setRating),
      Padding(
        padding: const EdgeInsets.all(18),
        child: const T(
          'Mục tiêu này rất hữu ích và giúp mình\ncó động lực học tập hơn nhiều !',
          size: 16,
          color: muted,
        ),
      ),
      gap(10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: KButton('Hoàn tất', s.go(D.go01)),
      ),
    ],
  );
}
