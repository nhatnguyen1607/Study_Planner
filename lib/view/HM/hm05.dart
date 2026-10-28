import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of HM/HM05.kt.
class Hm05Screen extends StatelessWidget {
  const Hm05Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.hm05),
    vm: viewModel,
    title: 'Tiến độ tuần',
    section: 3,
    padding: 12,
    body: (s) => [
      Container(
        height: 262,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pale,
          borderRadius: BorderRadius.circular(10),
        ),
        child: KColumn([
          const T('14/10 - 20/10', size: 18, color: muted),
          gap(16),
          const KRing(60, size: 112, stroke: 11, labelSize: 28),
          gap(18),
          const T('Đã hoàn thành', size: 23),
          const T('3/5 mục tiêu', size: 21),
        ], center: true),
      ),
      for (final a in [
        ('Toán cao cấp', 80),
        ('Tiếng anh', 50),
        ('Lập trình python', 30),
        ('Việc cá nhân', 10),
      ])
        progressLine(a.$1, a.$2),
      KCard([
        KRow([
          Expanded(child: bold('Thời gian học\ntuần này', 20)),
          panel(
            const T('+12%', color: dark),
            color: const Color(0xFFA0DBA3),
            padding: 5,
          ),
        ]),
        SizedBox(
          height: 94,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++)
                KColumn([
                  Container(
                    width: 22,
                    height: [48, 30, 50, 72, 50, 48, 51][i].toDouble(),
                    decoration: BoxDecoration(
                      color: i.isEven ? green : pale,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  T(['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][i], size: 12),
                ], center: true),
            ],
          ),
        ),
      ], onTap: s.go(D.an02)),
      paddedButton('Xem phân tích đầy đủ', s.go(D.an01), vertical: 16),
    ],
  );
}
