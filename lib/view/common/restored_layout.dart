part of 'database_frame.dart';

extension _RestoredLayout on _DatabaseFrameState {
  Map<String, dynamic> get allocation => {
    'weeklyHours': vm.weeklyHours,
    'subjectHours': vm.subjectHours,
    'idealTimeSlots': vm.idealTimeSlots.map((s) => s.name).toList(),
  };
  int hoursFor(StudySubject subject) =>
      data.subjectHoursFor(subject, legacy: vm.subjectHours);
  StudySubject subjectFor(String name) =>
      data.subjects.where((s) => s.name == name).firstOrNull ??
      StudySubject(id: name, name: name);
  Future<void> addCourse() async {
    await editData(
      context,
      title: 'Thêm môn học',
      fields: [
        const DataInput('name', 'Tên môn học', required: true, max: 80),
        const DataInput('category', 'Nhóm môn học', value: 'Tự chọn', max: 40),
      ],
      save: (fields) async {
        final ok = await data.addSubject(
          fields['name']!,
          category: fields['category']!.isEmpty
              ? 'Tự chọn'
              : fields['category']!,
          allocation: allocation,
        );
        if (ok && mounted) changed(() => courseQuery = '');
        return ok ? null : data.error;
      },
    );
  }

  Widget segments(
    List<String> labels,
    int selected,
    ValueChanged<int> select,
  ) => KTabs(labels, selected: selected, onSelect: select);
  Widget mascotTip(
    String title,
    String detail, {
    String pose = 'sprout_books',
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: light.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: pale),
    ),
    child: KRow([
      StudyMascot(pose: pose, size: 70),
      Expanded(
        child: KColumn([
          T(title, size: 14, weight: FontWeight.w600, color: dark),
          gap(4),
          T(detail, size: 12, color: muted),
        ]),
      ),
    ], gap: 12),
  );
  List<Widget>? fixedTop() {
    if (screen != D.pl07) return null;
    return [
      gap(14),
      TextField(
        key: const Key('course-search'),
        onChanged: (text) => changed(() => courseQuery = text),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm môn học ...',
          fillColor: Colors.white,
          prefixIcon: IconButton(
            tooltip: 'Quay lại',
            onPressed: vm.goBack,
            icon: const Icon(Icons.chevron_left),
          ),
          suffixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: StudyColors.border),
          ),
        ),
      ),
      gap(14),
      segments(
        ['Tất cả', 'Môn bắt buộc', 'Kỹ năng'],
        courseFilter,
        (i) => changed(() => courseFilter = i),
      ),
      KRow([
        Expanded(
          child: T('${data.subjects.length} môn học', size: 12, color: muted),
        ),
        TextButton.icon(
          key: const Key('add-subject'),
          onPressed: data.busy ? null : addCourse,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Thêm môn học', style: TextStyle(fontSize: 12)),
        ),
      ]),
      gap(6),
    ];
  }

  Widget? fixedFooter() {
    String? label;
    VoidCallback? tap;
    switch (screen) {
      case D.hm02:
        label = 'Thêm buổi học';
        tap = () {
          if (data.plan == null) {
            go(D.pl05);
          } else {
            editSession();
          }
        };
        break;
      case D.hm03:
        label = 'Thêm việc cần làm';
        tap = () => addTask();
        break;
      case D.pl06:
        label = 'Bắt đầu tạo kế hoạch';
        tap = () => go(D.pl07);
        break;
      case D.pl07:
        label = 'Tiếp tục (${data.selectedSubjects.length} môn)';
        tap = () {
          if (data.selectedSubjects.isEmpty) {
            message('Chọn ít nhất một môn học.');
            return;
          }
          go(D.pl08);
        };
        break;
      case D.pl08:
        label = 'Tiếp tục';
        tap = () => go(D.pl09);
        break;
      case D.pl09:
        label = 'Tiếp tục';
        tap = () {
          if (vm.allocatedHours > vm.weeklyHours) {
            message('Tổng phân bổ đang vượt quỹ tuần.');
            return;
          }
          go(D.pl10);
        };
        break;
      case D.pl10:
        label = 'Xem trước kế hoạch';
        tap = () => go(D.pl11);
        break;
      case D.pl11:
        label = 'Tạo kế hoạch';
        tap = createPlan;
        break;
      case D.go02:
        label = 'Tiếp tục';
        tap = () {
          if (value('goalTitle').trim().isEmpty) {
            message('Nhập tên mục tiêu.');
            return;
          }
          go(D.go03);
        };
        break;
      case D.go03:
        label = 'Tiếp tục';
        tap = () => go(D.go04);
        break;
      case D.go04:
        label = 'Tiếp tục';
        tap = () => go(D.go05);
        break;
      case D.go05:
        label = 'Tiếp tục';
        tap = () => go(D.go06);
        break;
      case D.go06:
        label = 'Tiếp tục';
        tap = () => go(D.go07);
        break;
      case D.go07:
        label = 'Tạo mục tiêu';
        tap = saveGoal;
        break;
      default:
        return null;
    }
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 18,
          left: 16,
          right: 16,
        ),
        child: FigmaButton(
          label,
          onTap: data.busy ? null : tap,
          loading: data.busy,
        ),
      ),
    );
  }

  Widget dateStrip(DateTime selected, ValueChanged<DateTime> onSelect) {
    final first = DateTime(
      selected.year,
      selected.month,
      selected.day,
    ).subtract(Duration(days: selected.weekday - 1));
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: HoverAction(
              radius: 12,
              onTap: () => onSelect(first.add(Duration(days: i))),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: sameDay(first.add(Duration(days: i)), selected)
                      ? green
                      : Colors.white.withValues(alpha: .75),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: KColumn([
                  T(
                    i == 6 ? 'CN' : 'T${i + 2}',
                    size: 11,
                    center: true,
                    color: sameDay(first.add(Duration(days: i)), selected)
                        ? Colors.white
                        : muted,
                  ),
                  T(
                    '${first.add(Duration(days: i)).day}',
                    size: 12,
                    center: true,
                    weight: FontWeight.w600,
                    color: sameDay(first.add(Duration(days: i)), selected)
                        ? Colors.white
                        : navy,
                  ),
                ]),
              ),
            ),
          ),
      ],
    );
  }

  Widget calendarMonth(
    DateTime date, {
    required ValueChanged<DateTime> onSelect,
    Set<int> completed = const {},
  }) {
    final first = DateTime(date.year, date.month, 1),
        count = DateTime(date.year, date.month + 1, 0).day;
    return KCard([
      KRow([
        IconButton(
          tooltip: 'Tháng trước',
          onPressed: () => onSelect(DateTime(date.year, date.month - 1, 1)),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: T(
            'Tháng ${date.month}, ${date.year}',
            center: true,
            weight: FontWeight.w600,
          ),
        ),
        IconButton(
          tooltip: 'Tháng sau',
          onPressed: () => onSelect(DateTime(date.year, date.month + 1, 1)),
          icon: const Icon(Icons.chevron_right),
        ),
      ]),
      KRow([
        for (final name in ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'])
          Expanded(child: T(name, size: 11, center: true, color: muted)),
      ]),
      gap(12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ((first.weekday - 1 + count) / 7).ceil() * 7,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) {
          final day = index - first.weekday + 2;
          if (day < 1 || day > count) return const SizedBox();
          return HoverAction(
            onTap: () => onSelect(DateTime(date.year, date.month, day)),
            radius: 20,
            child: Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: day == date.day
                      ? green
                      : completed.contains(day)
                      ? pale
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: T(
                  '$day',
                  size: 12,
                  color: day == date.day ? Colors.white : navy,
                ),
              ),
            ),
          );
        },
      ),
    ]);
  }
}
