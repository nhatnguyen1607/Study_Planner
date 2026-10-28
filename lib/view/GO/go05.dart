import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of GO/GO05.kt.
class Go05Screen extends StatelessWidget {
  const Go05Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.go05),
    vm: viewModel,
    title: 'Chọn thời hạn',
    section: 2,
    goal: true,
    padding: 16,
    subtitle: 'Khi nào bạn muốn đạt được\nmục tiêu này ?',
    top: (s) => [
      Align(
        alignment: Alignment.centerRight,
        child: picture('sprout_books', height: 126, width: 126),
      ),
    ],
    bottom: (s) => [paddedButton('Tiếp tục', s.go(D.go06), vertical: 12)],
    body: (s) => [
      for (final a in [
        ('1 Tháng', 'Phù hợp cho mục tiêu nhỏ'),
        ('3 Tháng', 'Có thể thấy kết quả rõ ràng'),
        ('6 Tháng', 'Phù hợp cho mục tiêu trung bình'),
        ('1 năm', 'Phù hợp cho mục tiêu lớn'),
        ('Tùy chỉnh', 'Chọn ngày cụ thể'),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: s.vm.selectedDuration.toLowerCase() == a.$1.toLowerCase()
                  ? Border.all(color: green, width: 1.5)
                  : null,
            ),
            child: KCard([
              KRow([
                Icon(
                  s.vm.selectedDuration.toLowerCase() == a.$1.toLowerCase()
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: green,
                  size: 24,
                ),
                Expanded(
                  child: KColumn([
                    T(a.$1, size: 17, weight: FontWeight.w600),
                    T(a.$2, size: 13, color: muted),
                  ]),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ], gap: 18),
            ], onTap: () => s.vm.setDuration(a.$1)),
          ),
        ),
      KCard([
        KRow([
          const Icon(Icons.calendar_month_outlined, size: 31),
          Expanded(
            child: KColumn([
              const T('Ngày hoàn thành', color: muted),
              bold('15 Tháng 6, 2026', 20),
            ]),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ], gap: 28),
      ], onTap: () => s.vm.setDuration('Tùy chỉnh')),
    ],
  );
}
