import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of GO/GO06.kt.
class Go06Screen extends StatelessWidget {
  const Go06Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.go06),
    vm: viewModel,
    title: 'Thiết lập cột mốc',
    section: 2,
    goal: true,
    padding: 18,
    bar: false,
    subtitle: 'Chia nhỏ mục tiêu thành các giai đoạn để dễ dàng theo dõi',
    top: (s) => [gap(18)],
    body: (s) => [
      for (var i = 0; i < milestoneData.length + s.extra; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: KCard([
            KRow([
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: StudyColors.green400,
                  shape: BoxShape.circle,
                ),
                child: T(
                  '${i + 1}',
                  color: Colors.white,
                  size: 20,
                  weight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: KColumn([
                  bold(
                    i < milestoneData.length
                        ? milestoneData[i].$1
                        : 'Cột mốc mới ${i + 1}',
                    14,
                  ),
                  T(
                    i < milestoneData.length
                        ? milestoneData[i].$2
                        : 'Chạm để chỉnh sửa sau',
                    color: muted,
                  ),
                ]),
              ),
              const Icon(Icons.drag_handle, size: 32),
            ], gap: 18),
          ]),
        ),
      KButton('Thêm cột mốc', () => s.change(() => s.extra++), leading: '+'),
      gap(12),
      KButton('Tiếp tục', s.go(D.go07)),
    ],
  );
}
