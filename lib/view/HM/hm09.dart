import 'package:study_planner_flutter/view/common/kotlin_widgets.dart';

/// Port of HM/HM09.kt.
class Hm09Screen extends StatelessWidget {
  const Hm09Screen({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;
  @override
  Widget build(BuildContext context) => KScreen(
    key: const ValueKey(D.hm09),
    vm: viewModel,
    title: 'Tìm kiếm',
    padding: 22,
    body: (s) => [
      TextField(
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Nhập môn AI, toán, lịch học,...',
          prefixIcon: Icon(Icons.search),
        ),
        onSubmitted: (query) {
          FocusScope.of(context).unfocus();
          if (query.trim().isNotEmpty) s.vm.navigate(D.hm10);
        },
      ),
      gap(20),
      heading('Gợi ý nhanh'),
      gap(14),
      for (final row in [
        ['Toán cao cấp', 'Python', 'Tiếng Anh'],
        ['Việc cần làm', 'Ghi chú', 'Tài liệu'],
        ['AI', 'Video'],
      ]) ...[
        KRow([
          for (final label in row)
            Expanded(
              child: HoverAction(
                onTap: s.go(D.hm10),
                radius: 50,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5E6E8),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: T(label, color: muted),
                ),
              ),
            ),
          for (var i = row.length; i < 3; i++)
            const Expanded(child: SizedBox()),
        ], gap: 8),
        gap(8),
      ],
      gap(12),
      heading('Tìm kiếm gần đây', action: 'Xóa tất cả'),
      gap(16),
      for (final label in [
        'Hàm python',
        'Đề thi Toán',
        'Từ vựng unit 4',
        'Viết báo cáo 2',
      ]) ...[
        HoverAction(
          onTap: s.go(D.hm10),
          radius: 12,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: KRow([
              const Icon(Icons.access_time),
              Expanded(child: T(label, color: muted)),
              const Icon(Icons.chevron_right),
            ], gap: 14),
          ),
        ),
        gap(10),
      ],
    ],
  );
}
