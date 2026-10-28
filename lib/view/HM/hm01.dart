import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of HM/HM01.kt.
class Hm01Screen extends StatelessWidget {
  const Hm01Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.hm01),
    vm: viewModel,
    back: false,
    padding: 15,
    tail: 0,
    body: (s) => [
      SizedBox(
        height: 102,
        child: KRow([
          Expanded(
            child: KColumn([
              const T('Xin chào,', size: 20, weight: FontWeight.w600),
              bold('Nguyễn 👋', 26),
            ]),
          ),
          IconButton(
            tooltip: 'Tìm kiếm',
            onPressed: s.go(D.hm09),
            icon: const Icon(Icons.search),
            padding: const EdgeInsets.all(7),
            constraints: const BoxConstraints.tightFor(width: 42, height: 42),
          ),
          IconButton(
            tooltip: 'Thông báo',
            onPressed: s.go(D.hm07),
            icon: const Icon(Icons.notifications_outlined),
            padding: const EdgeInsets.all(7),
            constraints: const BoxConstraints.tightFor(width: 42, height: 42),
          ),
          HoverAction(
            onTap: s.external('AI-01 · AI Assistant'),
            child: picture('home_welcome', height: 82, width: 82),
          ),
        ]),
      ),
      dayStrip(home: true),
      gap(9),
      KCard(
        [
          SizedBox(
            height: 122,
            child: KRow([
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: KColumn([
                    const T(
                      'Tiến độ tuần',
                      size: 21,
                      color: dark,
                      weight: FontWeight.w700,
                    ),
                    const T('3/5 mục tiêu', size: 16),
                  ]),
                ),
              ),
              const KRing(60, size: 102, stroke: 11, labelSize: 24),
            ]),
          ),
        ],
        onTap: s.go(D.hm05),
        height: 156,
      ),
      gap(20),
      KRow([
        for (var i = 0; i < 4; i++)
          Expanded(
            child: HoverAction(
              onTap: s.go([D.pl01, D.hm03, D.an01, D.an01][i]),
              radius: 10,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEBEBEB)),
                ),
                child: Center(
                  child: KColumn([
                    bold(['3', '2', '4h', '85%'][i], 20),
                    T(
                      ['môn học', 'bài tập', 'thời gian học', 'hiệu suất'][i],
                      size: i == 2 ? 10 : 12,
                      lines: 1,
                    ),
                  ], center: true),
                ),
              ),
            ),
          ),
      ], gap: 18),
      gap(26),
      heading('Học hôm nay', action: 'Xem tất cả ›', tap: s.go(D.hm02)),
      gap(10),
      for (final l in homeLessons.take(3))
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: lessonCard(l, s.go(D.hm02)),
        ),
      for (final a in [
        (Icons.access_time, 'Hoạt động sắp diễn ra', D.hm04),
        (Icons.assignment_outlined, 'Hoạt động gần đây', D.hm06),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: KCard([
            KRow([
              Icon(a.$1, color: dark),
              Expanded(child: bold(a.$2, 14)),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ], gap: 12),
          ], onTap: s.go(a.$3)),
        ),
      Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: KButton('Tạo kế hoạch mới', s.go(D.pl06), leading: '+'),
      ),
    ],
  );
}
