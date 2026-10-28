import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of GO/GO01.kt.
class Go01Screen extends StatelessWidget {
  const Go01Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.go01),
    vm: viewModel,
    title: 'Mục tiêu học tập',
    section: 2,
    goal: true,
    back: false,
    padding: 15,
    top: (s) => [
      s.tabs(['Tất cả', 'Đang thực hiện', 'Hoàn thành']),
      paddedButton(
        'Tạo mục tiêu mới',
        s.go(D.go02),
        horizontal: 23,
        vertical: 16,
        leading: '+',
      ),
    ],
    body: (s) => [
      for (var i = 0; i < 4; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: KCard([
            KRow([
              iconBox(
                Icons.emoji_events_outlined,
                size: 50,
                radius: 16,
                bg: green,
                color: Colors.white,
              ),
              Expanded(
                child: KColumn([
                  T(
                    [
                      'Đạt IELTS 7.0',
                      'Hoàn thành CT toán',
                      'Phân tích dữ liệu',
                      'Đọc 12 cuốn sách',
                    ][i],
                    size: 18,
                    weight: FontWeight.w600,
                  ),
                  T(
                    ['Tiếng anh', 'Đại học', 'Data Science', 'Kỹ năng sống'][i],
                    color: muted,
                  ),
                ]),
              ),
              KRing(
                i == 0 ? s.vm.goalProgress : [60, 30, 0, 75][i],
                size: 76,
                stroke: 8,
                labelSize: 15,
              ),
            ], gap: 20),
          ], onTap: s.go(D.go08)),
        ),
    ],
  );
}
