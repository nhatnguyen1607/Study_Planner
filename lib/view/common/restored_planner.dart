part of 'database_frame.dart';

extension _RestoredPlanner on _DatabaseFrameState {
  Future<void> saveSessionReview() async {
    final session = data.session;
    if (session == null) return;
    final planned = session
        .date('endAt')!
        .difference(session.date('startAt')!)
        .inMinutes;
    final minutes = int.tryParse(
      value(
        'sessionMinutes_${session.id}',
        '${session.number('actualMinutes') > 0 ? session.number('actualMinutes') : planned}',
      ),
    );
    if (minutes == null || minutes < 1 || minutes > 1440) {
      message('Nhập thời gian thực học từ 1 đến 1440 phút.');
      return;
    }
    final ok = await data.updateSession({
      'status': 'completed',
      'actualMinutes': minutes,
      'rating': vm.rating,
      'notes': value('sessionReflection_${session.id}', session.text('notes')),
      'completedAt':
          session.data['completedAt'] ?? FieldValue.serverTimestamp(),
    });
    if (ok && mounted) {
      draft.remove('sessionMinutes_${session.id}');
      draft.remove('sessionReflection_${session.id}');
      go(D.pl15);
    }
  }

  void openGemini() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => AiScheduleScreen(
        initialSubjects: data.selectedSubjects.map((s) => s.name).join(', '),
        initialHours: '${vm.allocatedHours}',
        initialObjective: value('planObjective'),
      ),
    ),
  );
  Future<void> editCourseHours(StudySubject subject) async {
    final amount = await showTimeSettingDialog(
      context,
      title: 'Thời lượng ${subject.name}',
      hours: hoursFor(subject),
      minimum: 1,
      maximum: (vm.weeklyHours - vm.allocatedHours + hoursFor(subject)).clamp(
        1,
        168,
      ),
    );
    if (amount != null) data.changeSubjectHours(subject, amount);
  }

  Future<void> editWeeklyBudget() async {
    final amount = await showTimeSettingDialog(
      context,
      title: 'Tổng thời gian học mỗi tuần',
      hours: vm.weeklyHours,
      minimum: vm.allocatedHours,
      maximum: 168,
      allocatedHours: vm.allocatedHours,
    );
    if (amount != null) vm.setWeeklyHours(amount);
  }

  List<Widget> restoredPlannerBody() {
    final p = data.plan, s = data.session;
    switch (screen) {
      case D.pl01:
        final next = data.sessions
            .where(
              (s) =>
                  s.text('status') != 'completed' &&
                  (s.date('startAt')?.isAfter(DateTime.now()) ?? false),
            )
            .take(4)
            .toList();
        return [
          KRow([
            Expanded(
              child: KColumn([
                const T('Xin chào,', size: 15, color: muted),
                T(
                  UserProfileScope.maybeOf(context)?.profile?.displayName ??
                      'Bạn học',
                  size: 25,
                  weight: FontWeight.w700,
                ),
              ]),
            ),
            const StudyMascot(pose: 'home_calendar', size: 82),
          ], gap: 12),
          KCard([
            KRow([
              Expanded(
                child: KColumn([
                  bold('Hôm nay'),
                  T(
                    '${data.sessions.where((s) => s.date('startAt') != null && sameDay(s.date('startAt')!, DateTime.now())).length} buổi học',
                    color: muted,
                  ),
                ]),
              ),
              KRing(data.progress, size: 68, stroke: 7, labelSize: 15),
            ], gap: 14),
          ]),
          plannerStats([
            (
              Icons.task_alt,
              '${data.completedSessions.length}',
              'Đã hoàn thành',
            ),
            (
              Icons.event_note_outlined,
              '${data.sessions.where((s) => s.text('status') != 'completed').length}',
              'Còn lại',
            ),
          ]),
          KRow([
            for (final item in [
              (Icons.today_outlined, 'Ngày', D.pl02),
              (Icons.view_week_outlined, 'Tuần', D.pl03),
              (Icons.calendar_month_outlined, 'Tháng', D.pl04),
              (Icons.list_alt_outlined, 'Kế hoạch', D.pl05),
            ])
              Expanded(
                child: HoverAction(
                  onTap: () => go(item.$3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: KColumn([
                      Icon(item.$1, color: dark),
                      gap(5),
                      T(item.$2, center: true, size: 11),
                    ], center: true),
                  ),
                ),
              ),
          ]),
          heading(
            'Kế hoạch tiếp theo',
            action: 'Xem tất cả',
            tap: () => go(D.pl05),
          ),
          if (next.isEmpty) empty('Bắt đầu bằng một kế hoạch nhỏ cho hôm nay.'),
          ...next.map(sessionRow),
          action('Tạo kế hoạch mới', () => go(D.pl06), icon: Icons.add),
        ];
      case D.pl02:
      case D.pl03:
      case D.pl04:
        final selected =
            DateTime.tryParse(value('calendarDate')) ?? DateTime.now();
        void select(DateTime day) =>
            changed(() => draft['calendarDate'] = day.toIso8601String());
        final weekStart = DateTime(
          selected.year,
          selected.month,
          selected.day,
        ).subtract(Duration(days: selected.weekday - 1));
        final matches = data.sessions.where((s) {
          final day = s.date('startAt');
          return day != null &&
              (screen == D.pl04
                  ? day.year == selected.year && day.month == selected.month
                  : screen == D.pl03
                  ? !day.isBefore(weekStart) &&
                        day.isBefore(weekStart.add(const Duration(days: 7)))
                  : sameDay(day, selected));
        }).toList();
        return [
          if (screen == D.pl04)
            calendarMonth(selected, onSelect: select)
          else ...[
            row(
              'Tháng ${selected.month}, ${selected.year}',
              'Chọn ngày xem lịch',
              Icons.calendar_month_outlined,
              () => chooseDate('calendarDate', current: selected),
            ),
            dateStrip(selected, select),
          ],
          if (screen == D.pl03) weekGrid(weekStart, matches),
          heading(
            screen == D.pl03
                ? 'Các buổi trong tuần'
                : 'Ngày ${dateLabel(selected)}',
          ),
          if (matches.isEmpty)
            mascotTip(
              'Bạn đang có thời gian trống',
              'Thêm một buổi học để bắt đầu.',
              pose: 'home_calendar',
            ),
          ...matches.map(sessionRow),
          action('Thêm buổi học', () {
            if (data.plan == null) {
              go(D.pl05);
            } else {
              editSession();
            }
          }, icon: Icons.add),
        ];
      case D.pl05:
        final plans = data
            .items('plans')
            .where(
              (p) =>
                  planFilter == 0 ||
                  (planFilter == 2) ==
                      (planSessions(p.id).isNotEmpty &&
                          planSessions(p.id)
                              .every((s) => s.text('status') == 'completed')),
            )
            .toList();
        return [
          segments(
            ['Tất cả', 'Đang diễn ra', 'Hoàn thành'],
            planFilter,
            (i) => changed(() => planFilter = i),
          ),
          if (plans.isEmpty) empty('Chưa có kế hoạch trong mục này.'),
          for (final p in plans)
            FigmaSubjectTile(
              subject: subjectFor(
                p.strings('subjects').firstOrNull ?? p.text('title'),
              ),
              selected: false,
              subtitle:
                  '${p.text('title')} · ${planSessions(p.id).length} buổi',
              trailing: const Icon(Icons.chevron_right, color: muted),
              onTap: () {
                data.select('plans', p.id);
                go(D.pl12);
              },
            ),
          action('Tạo kế hoạch mới', () => go(D.pl06), icon: Icons.add),
        ];
      case D.pl06:
        return [
          const Center(child: StudyMascot(pose: 'sprout_books', size: 152)),
          const T(
            'Tạo kế hoạch học tập\nvới AI',
            size: 24,
            weight: FontWeight.w700,
            center: true,
          ),
          const T(
            'Cá nhân hóa theo mục tiêu và nhịp học của bạn',
            size: 13,
            color: muted,
            center: true,
          ),
          field(
            'planTitle',
            'Tên kế hoạch',
            initial: 'Kế hoạch học tập',
            max: 120,
          ),
          field('planObjective', 'Mục tiêu học tập', lines: 2, max: 1000),
          KCard([
            for (final tip in [
              'Cá nhân hóa theo mục tiêu',
              'Gợi ý lịch học tối ưu',
              'Linh hoạt điều chỉnh lịch',
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: KRow([
                  const Icon(
                    Icons.check_circle_outline,
                    size: 19,
                    color: green,
                  ),
                  Expanded(child: T(tip, size: 13)),
                ], gap: 10),
              ),
          ]),
          FigmaButton(
            'Đề xuất kế hoạch với Gemini',
            onTap: openGemini,
            secondary: true,
            icon: Icons.auto_awesome_outlined,
          ),
        ];
      case D.pl07:
        final selected = data.selectedSubjects.map((s) => s.id).toSet();
        final matches = data.subjects
            .where(
              (s) =>
                  s.name.toLowerCase().contains(courseQuery.toLowerCase()) &&
                  (courseFilter == 0 ||
                      s.category ==
                          (courseFilter == 1 ? 'Môn bắt buộc' : 'Kỹ năng')),
            )
            .toList();
        return [
          for (final subject in matches)
            FigmaSubjectTile(
              key: ValueKey('subject-${subject.id}'),
              subject: subject,
              selected: selected.contains(subject.id),
              onTap: data.busy ? null : () => data.toggleSubject(subject),
            ),
          if (matches.isEmpty)
            mascotTip(
              'Chưa tìm thấy môn học',
              'Bạn có thể thêm môn của mình bằng nút phía trên.',
              pose: 'home_search',
            ),
          const Align(
            alignment: Alignment.centerRight,
            child: StudyMascot(pose: 'sprout_pencil', size: 68),
          ),
        ];
      case D.pl08:
        final first = DateTime.tryParse(value('planStart')) ?? DateTime.now(),
            last =
                DateTime.tryParse(value('planEnd')) ??
                DateTime.now().add(const Duration(days: 28));
        return [
          fieldLabel('Chọn khoảng thời gian'),
          KCard([
            plannerDetail(
              Icons.calendar_today_outlined,
              'Thời gian bắt đầu',
              dateLabel(first),
              tap: () => chooseDate('planStart', current: first),
            ),
            const Divider(height: 22),
            plannerDetail(
              Icons.event_outlined,
              'Thời gian kết thúc',
              dateLabel(last),
              tap: () => chooseDate('planEnd', current: last),
            ),
          ]),
          mascotTip(
            'Gợi ý',
            'Chọn lịch vừa sức, rồi tăng dần khi bạn đã quen.',
            pose: 'sprout_watering',
          ),
        ];
      case D.pl09:
        return [
          for (final subject in data.selectedSubjects)
            FigmaSubjectTile(
              subject: subject,
              selected: false,
              subtitle: '${hoursFor(subject)} giờ / tuần',
              trailing: const Icon(Icons.chevron_right, color: dark),
              onTap: () => editCourseHours(subject),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: light,
              borderRadius: BorderRadius.circular(18),
            ),
            child: KColumn([
              KRow([
                Expanded(
                  child: T(
                    'Tổng thời lượng: ${vm.allocatedHours}/${vm.weeklyHours} giờ',
                    weight: FontWeight.w600,
                    color: dark,
                  ),
                ),
                IconButton(
                  key: const Key('edit-week-hours'),
                  tooltip: 'Chỉnh tổng thời gian',
                  onPressed: editWeeklyBudget,
                  icon: const Icon(Icons.edit_outlined, size: 21, color: dark),
                ),
              ]),
              gap(10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (vm.allocatedHours / vm.weeklyHours).clamp(0, 1),
                  minHeight: 9,
                  color: green,
                  backgroundColor: const Color(0xFFDDE6DF),
                ),
              ),
              gap(9),
              T(
                'Còn lại: ${vm.weeklyHours - vm.allocatedHours} giờ',
                size: 12,
                color: dark,
              ),
            ]),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: StudyMascot(pose: 'sprout_pencil', size: 88),
          ),
        ];
      case D.pl10:
        final days = (draft['days'] as List<int>?) ?? [1, 3, 5];
        return [
          heading('Lựa chọn ngày'),
          for (var i = 1; i <= 7; i++)
            HoverAction(
              onTap: () => changed(() {
                final next = List<int>.of(days);
                next.contains(i) ? next.remove(i) : next.add(i);
                draft['days'] = next..sort();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: days.contains(i)
                      ? light
                      : Colors.white.withValues(alpha: .94),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: days.contains(i) ? green : StudyColors.border,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A173C24),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: KRow([
                  Icon(
                    days.contains(i)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: days.contains(i) ? green : muted,
                    size: 24,
                  ),
                  T(
                    i == 7 ? 'Chủ nhật' : 'Thứ ${i + 1}',
                    size: 15,
                    weight: days.contains(i)
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: days.contains(i) ? dark : Colors.black87,
                  ),
                ], gap: 12),
              ),
            ),
          KCard([
            plannerDetail(
              Icons.wb_sunny_outlined,
              'Khung giờ lý tưởng',
              vm.idealTimeLabel,
              tap: () async {
                final slots = await showIdealTimeDialog(
                  context,
                  vm.idealTimeSlots,
                );
                if (slots != null) vm.setIdealTimeSlots(slots);
              },
            ),
            Material(
              type: MaterialType.transparency,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Nhắc nhở tự động',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Trước buổi học 15 phút',
                  style: TextStyle(fontSize: 12),
                ),
                value: draft['planReminder'] != false,
                onChanged: (v) => changed(() => draft['planReminder'] = v),
              ),
            ),
          ]),
          const Align(
            alignment: Alignment.centerRight,
            child: StudyMascot(pose: 'habits_checklist', size: 88),
          ),
        ];
      case D.pl11:
        return [
          const Center(child: StudyMascot(pose: 'goals_celebrate', size: 152)),
          const T(
            'Đây là kế hoạch học tập\ndành cho bạn!',
            center: true,
            size: 22,
            weight: FontWeight.w700,
          ),
          KCard([
            plannerDetail(
              Icons.menu_book_outlined,
              'Môn học',
              '${data.selectedSubjects.length} môn',
            ),
            plannerDetail(
              Icons.schedule,
              'Thời lượng',
              '${vm.allocatedHours} giờ/tuần',
            ),
            plannerDetail(
              Icons.wb_sunny_outlined,
              'Khung giờ',
              vm.idealTimeLabel,
            ),
          ]),
          for (final subject in data.selectedSubjects)
            KRow([
              const Icon(Icons.check_circle, color: green, size: 21),
              Expanded(
                child: T(
                  '${subject.name} · ${hoursFor(subject)} giờ/tuần',
                  size: 14,
                ),
              ),
            ], gap: 12),
          TextButton(
            onPressed: () => go(D.pl07),
            child: const Text('Quay lại chỉnh sửa'),
          ),
        ];
      default:
        return plannerDetailBody(p, s);
    }
  }

  Widget weekGrid(DateTime monday, List<StudyRecord> sessions) => KCard([
    Row(
      children: [
        for (var day = 0; day < 7; day++)
          Expanded(
            child: Column(
              children: [
                T(
                  day == 6 ? 'CN' : 'T${day + 2}',
                  size: 10,
                  center: true,
                  color: muted,
                ),
                gap(7),
                T(
                  '${monday.add(Duration(days: day)).day}',
                  size: 12,
                  center: true,
                  weight: FontWeight.w600,
                ),
                gap(8),
                for (final session in sessions.where(
                  (s) => s.date('startAt')?.weekday == day + 1,
                ))
                  HoverAction(
                    onTap: () => openSession(session),
                    child: Container(
                      height: 76,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 3,
                      ),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color:
                            subjectPalette[subjectFor(session.text('subject'))
                                        .color %
                                    7]
                                .withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '${clockLabel(session.date('startAt')!)}\n${session.text('subject')}',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9, height: 1.3),
                      ),
                    ),
                  ),
                if (!sessions.any((s) => s.date('startAt')?.weekday == day + 1))
                  Container(
                    height: 80,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: pale),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
              ],
            ),
          ),
      ],
    ),
  ]);
  List<Widget> plannerDetailBody(StudyRecord? p, StudyRecord? s) {
    if (screen == D.pl12) {
      if (p == null) {
        return [
          empty('Chọn một kế hoạch để xem chi tiết.'),
          action('Danh sách kế hoạch', () => go(D.pl05)),
        ];
      }
      final sessions = planSessions();
      final done = sessions
          .where((s) => s.text('status') == 'completed')
          .length;
      return [
        KRow([
          Expanded(
            child: KColumn([
              bold(p.text('title'), 21),
              T(p.text('objective'), size: 13, color: muted),
            ]),
          ),
          const StudyMascot(pose: 'sprout_books', size: 80),
        ], gap: 12),
        plannerStats([
          (Icons.schedule, '${p.number('weeklyHours')}', 'Giờ/tuần'),
          (Icons.menu_book_outlined, '${sessions.length}', 'Buổi học'),
          (
            Icons.task_alt,
            '${sessions.isEmpty ? 0 : (done / sessions.length * 100).round()}%',
            'Hoàn thành',
          ),
        ]),
        KCard([
          plannerDetail(
            Icons.date_range,
            'Thời gian',
            '${p.date('startAt') == null ? '' : dateLabel(p.date('startAt')!)} – ${p.date('endAt') == null ? '' : dateLabel(p.date('endAt')!)}',
          ),
          plannerDetail(Icons.track_changes, 'Mục tiêu', p.text('objective')),
        ]),
        KRow([
          for (final item in [
            ('Tổng quan', D.pl12),
            ('Buổi học', D.pl13),
            ('Lịch sử', D.pl15),
          ])
            Expanded(
              child: TextButton(
                onPressed: () => go(item.$2),
                child: Text(item.$1),
              ),
            ),
        ]),
        ...sessions.take(3).map(sessionRow),
        action('Thêm buổi học', () => editSession(), icon: Icons.add),
      ];
    }
    if (screen == D.pl13 || screen == D.pl15) {
      final sessions = planSessions()
          .where((s) => screen == D.pl13 || s.text('status') == 'completed')
          .toList();
      return [
        if (sessions.isEmpty)
          empty(
            screen == D.pl15
                ? 'Chưa có buổi học hoàn thành.'
                : 'Chưa có buổi học.',
          ),
        ...sessions.map(sessionRow),
        if (screen == D.pl13)
          action('Thêm buổi học', () => editSession(), icon: Icons.add),
      ];
    }
    if (screen == D.pl17) {
      return [
        calendarMonth(
          DateTime.tryParse(value('calendarDate')) ??
              s?.date('startAt') ??
              DateTime.now(),
          onSelect: (date) =>
              changed(() => draft['calendarDate'] = date.toIso8601String()),
        ),
        const Center(child: StudyMascot(pose: 'home_calendar', size: 100)),
        action(
          s == null ? 'Thêm buổi học' : 'Đổi lịch buổi học',
          () => editSession(reschedule: s != null),
        ),
      ];
    }
    if (s == null) {
      return [
        empty('Chọn một buổi học trong lịch.'),
        action('Xem lịch học', () => go(D.pl01)),
      ];
    }
    if (screen == D.pl14) {
      final key = 'sessionChecklist_undefined';
      final checklist = (draft[key] as List<String>?) ?? s.strings('checklist');
      final doneKey = 'sessionCompleted_undefined';
      final completed =
          (draft[doneKey] as List<String>?) ?? s.strings('completedItems');
      return [
        calendarMonth(
          s.date('startAt')!,
          onSelect: (day) =>
              changed(() => draft['calendarDate'] = day.toIso8601String()),
        ),
        heading('Nội dung buổi học'),
        T(s.text('title'), weight: FontWeight.w600),
        if (checklist.isEmpty)
          mascotTip(
            'Từng bước nhỏ',
            'Thêm các nội dung bạn muốn hoàn thành trong buổi học.',
            pose: 'habits_checklist',
          ),
        for (final item in checklist)
          KCard([
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item, style: const TextStyle(fontSize: 14)),
              value: completed.contains(item),
              onChanged: (checked) => changed(() {
                final next = List<String>.of(completed);
                if (checked == true) {
                  next.add(item);
                } else {
                  next.remove(item);
                }
                draft[doneKey] = next;
              }),
            ),
          ]),
        FigmaButton(
          'Thêm nội dung',
          icon: Icons.add,
          secondary: true,
          onTap: () async {
            await editData(
              context,
              title: 'Nội dung buổi học',
              fields: [
                const DataInput(
                  'title',
                  'Tên nội dung',
                  required: true,
                  max: 120,
                ),
              ],
              save: (form) async {
                final title = form['title']!.trim();
                if (!checklist.contains(title) && mounted) {
                  changed(() => draft[key] = [...checklist, title]);
                }
                return null;
              },
            );
          },
        ),
        action('Lưu kết quả', () async {
          if (await data.updateSession({
                'checklist': checklist,
                'completedItems': completed,
              }) &&
              mounted) {
            draft.remove(key);
            draft.remove(doneKey);
            go(D.pl18);
          }
        }),
      ];
    }
    if (screen == D.pl18) {
      return [
        const Center(child: StudyMascot(pose: 'goals_celebrate', size: 150)),
        const T(
          'Đánh giá buổi học',
          size: 23,
          center: true,
          weight: FontWeight.w700,
        ),
        T(s.text('title'), center: true, color: muted),
        stars(vm.rating, vm.setRating),
        field(
          'sessionMinutes_${s.id}',
          'Thời gian thực học (phút)',
          initial:
              '${s.number('actualMinutes') > 0 ? s.number('actualMinutes') : s.date('endAt')!.difference(s.date('startAt')!).inMinutes}',
          numeric: true,
        ),
        field(
          'sessionReflection_${s.id}',
          'Ghi chú (tùy chọn)',
          initial: s.text('notes'),
          lines: 4,
          max: 2000,
        ),
        action('Hoàn thành', saveSessionReview),
      ];
    }
    return [
      KRow([
        iconBox(
          figmaSubjectIcon(subjectFor(s.text('subject')).icon),
          size: 50,
          radius: 15,
        ),
        Expanded(
          child: KColumn([
            bold(s.text('subject'), 19),
            T(s.text('title'), color: muted),
          ]),
        ),
      ], gap: 12),
      KCard([
        plannerDetail(
          Icons.calendar_today_outlined,
          'Ngày học',
          dateLabel(s.date('startAt')!),
        ),
        plannerDetail(
          Icons.schedule,
          'Thời gian',
          '${clockLabel(s.date('startAt')!)} – ${clockLabel(s.date('endAt')!)}',
        ),
        plannerDetail(
          Icons.location_on_outlined,
          'Địa điểm',
          s.text('location').isEmpty ? 'Chưa cập nhật' : s.text('location'),
        ),
      ]),
      heading('Nội dung buổi học'),
      KCard([
        T(
          s.text('notes').isEmpty
              ? 'Thêm nội dung để chuẩn bị tốt hơn cho buổi học.'
              : s.text('notes'),
        ),
      ]),
      heading('Tài liệu'),
      row(
        'Tài liệu học tập',
        s.text('materials').isEmpty ? 'Chưa có tài liệu' : s.text('materials'),
        Icons.folder_open_outlined,
        () => editSession(reschedule: true),
      ),
      KRow([
        Expanded(
          child: FigmaButton(
            'Đặt lại lịch',
            secondary: true,
            onTap: () => editSession(reschedule: true),
          ),
        ),
        Expanded(
          child: FigmaButton(
            s.text('status') == 'completed' ? 'Xem kết quả' : 'Bắt đầu học',
            onTap: () => go(s.text('status') == 'completed' ? D.pl18 : D.pl14),
          ),
        ),
      ], gap: 12),
    ];
  }
}
