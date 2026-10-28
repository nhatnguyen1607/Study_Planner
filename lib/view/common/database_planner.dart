part of 'database_frame.dart';

const _courseNames = ['Toán cao cấp', 'Tiếng Anh', 'Lập trình Python'];

extension _PlannerFrames on _DatabaseFrameState {
  List<StudyRecord> planSessions([String? id]) => data.sessions
      .where((s) => s.text('planId') == (id ?? data.selectedPlanId))
      .toList();
  void openSession(StudyRecord session) {
    data.select('sessions', session.id);
    go(D.pl16);
  }

  Widget sessionRow(StudyRecord s) => row(
    s.text('title'),
    '${s.date('startAt') == null ? '' : dateLabel(s.date('startAt')!)} · ${s.date('startAt') == null ? '' : clockLabel(s.date('startAt')!)}–${s.date('endAt') == null ? '' : clockLabel(s.date('endAt')!)}\n${s.text('location')} · ${s.text('status') == 'completed' ? 'Đã hoàn thành' : 'Đã lên lịch'}',
    s.text('status') == 'completed' ? Icons.task_alt : Icons.event_outlined,
    () => openSession(s),
  );
  Future<void> chooseDate(String key, {DateTime? current}) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.tryParse(value(key)) ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (selected != null && mounted) {
      changed(() => draft[key] = selected.toIso8601String());
    }
  }

  Future<void> createPlan() async {
    final start = DateTime.tryParse(value('planStart')) ?? DateTime.now();
    final end =
        DateTime.tryParse(value('planEnd')) ??
        start.add(const Duration(days: 28));
    final days = (draft['days'] as List<int>?) ?? [1, 3, 5];
    final chosen = (draft['courses'] as List<String>?) ?? List.of(_courseNames);
    if (chosen.isEmpty ||
        days.isEmpty ||
        end.isBefore(start) ||
        end.difference(start).inDays > 90) {
      message(
        'Chọn môn, ít nhất một ngày học và khoảng thời gian tối đa 90 ngày.',
      );
      return;
    }
    final id = value('planDraftId', data.repository.newId('plans'));
    draft['planDraftId'] = id;
    final title = value('planTitle', 'Kế hoạch học tập').trim();
    if (title.isEmpty) {
      message('Nhập tên kế hoạch.');
      return;
    }
    final sessions = <StudyRecord>[];
    for (
      var day = DateTime(start.year, start.month, start.day);
      !day.isAfter(DateTime(end.year, end.month, end.day));
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      if (!days.contains(day.weekday)) continue;
      var minute = switch (vm.idealTimeSlots.first.name) {
        'morning' => 7 * 60,
        'afternoon' => 13 * 60,
        _ => 18 * 60,
      };
      for (final name in chosen) {
        final index = _courseNames.indexOf(name);
        final hours = index < 0 ? 1 : vm.subjectHours[index];
        final duration = (hours * 60 / days.length).round();
        if (duration > 240 || minute + duration > 22 * 60) {
          message(
            'Thời lượng không vừa khung giờ. Hãy chọn thêm ngày hoặc giảm số giờ mỗi môn.',
          );
          return;
        }
        final begin = DateTime(
          day.year,
          day.month,
          day.day,
          minute ~/ 60,
          minute % 60,
        );
        final sid =
            '${id}_${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}_$index';
        sessions.add(
          StudyRecord(sid, {
            'planId': id,
            'title': name,
            'subject': name,
            'startAt': Timestamp.fromDate(begin),
            'endAt': Timestamp.fromDate(begin.add(Duration(minutes: duration))),
            'status': 'scheduled',
            'actualMinutes': 0,
            'rating': 0,
            'notes': '',
            'location': '',
            'materials': '',
            'checklist': <String>[],
            'completedItems': <String>[],
            'archived': false,
          }),
        );
        minute += duration + 10;
      }
    }
    if (sessions.isEmpty) {
      message('Khoảng thời gian không có ngày học đã chọn.');
      return;
    }
    final plan = StudyRecord(id, {
      'title': title,
      'objective': value('planObjective'),
      'source': 'manual',
      'status': 'active',
      'subjects': chosen,
      'startAt': Timestamp.fromDate(
        DateTime(start.year, start.month, start.day),
      ),
      'endAt': Timestamp.fromDate(
        DateTime(end.year, end.month, end.day, 23, 59),
      ),
      'weeklyHours': vm.weeklyHours,
      'subjectHours': {
        for (final c in chosen) c: vm.subjectHours[_courseNames.indexOf(c)],
      },
      'weekdays': days,
      'idealTimeSlots': vm.idealTimeSlots.map((s) => s.name).toList(),
      'reminderEnabled': draft['planReminder'] ?? true,
      'archived': false,
    });
    if (await commit(
      data.saveCalendar(plan: plan, sessions: sessions),
      D.pl12,
    )) {
      data.selectedPlanId = id;
      draft.remove('planDraftId');
    }
  }

  Future<void> editSession({bool reschedule = false}) async {
    final current = reschedule ? data.session : null;
    final parent = data.plan;
    if (parent == null) {
      message('Hãy tạo hoặc chọn một kế hoạch trước.');
      return;
    }
    var date = current?.date('startAt') ?? DateTime.now();
    final chosen = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (chosen == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(date),
    );
    if (time == null || !mounted) return;
    date = DateTime(
      chosen.year,
      chosen.month,
      chosen.day,
      time.hour,
      time.minute,
    );
    final sid = current?.id ?? data.repository.newId('sessions');
    await editData(
      context,
      title: reschedule ? 'Đổi lịch buổi học' : 'Thêm buổi học',
      fields: [
        DataInput(
          'title',
          'Tên buổi học',
          value: current?.text('title') ?? '',
          required: true,
          max: 120,
        ),
        DataInput(
          'subject',
          'Môn học',
          value:
              current?.text('subject') ??
              parent.strings('subjects').firstOrNull ??
              '',
          required: true,
          max: 80,
        ),
        DataInput(
          'duration',
          'Số phút (1–240)',
          value: current == null
              ? '60'
              : '${current.date('endAt')!.difference(current.date('startAt')!).inMinutes}',
          numeric: true,
          required: true,
        ),
        DataInput(
          'location',
          'Địa điểm',
          value: current?.text('location') ?? '',
        ),
        DataInput(
          'materials',
          'Tài liệu / đường dẫn',
          value: current?.text('materials') ?? '',
          max: 2000,
        ),
        DataInput(
          'notes',
          'Nội dung',
          value: current?.text('notes') ?? '',
          lines: 3,
          max: 2000,
        ),
      ],
      save: (values) async {
        final minutes = int.tryParse(values['duration']!);
        if (minutes == null || minutes < 1 || minutes > 240) {
          return 'Thời lượng từ 1 đến 240 phút.';
        }
        final lower = parent.date('startAt'), upper = parent.date('endAt');
        if (lower != null &&
                date.isBefore(DateTime(lower.year, lower.month, lower.day)) ||
            upper != null &&
                date.isAfter(
                  DateTime(upper.year, upper.month, upper.day, 23, 59),
                )) {
          return 'Ngày học phải nằm trong thời hạn kế hoạch.';
        }
        final record = StudyRecord(sid, {
          ...?current?.data,
          'planId': parent.id,
          'title': values['title'],
          'subject': values['subject'],
          'location': values['location'],
          'materials': values['materials'],
          'notes': values['notes'],
          'startAt': Timestamp.fromDate(date),
          'endAt': Timestamp.fromDate(date.add(Duration(minutes: minutes))),
          if (current == null) ...{
            'status': 'scheduled',
            'actualMinutes': 0,
            'rating': 0,
            'checklist': <String>[],
            'completedItems': <String>[],
            'archived': false,
          },
        });
        final ok = await data.saveCalendar(sessions: [record]);
        if (ok) {
          data.selectedSessionId = sid;
        }
        return ok ? null : data.error;
      },
    );
  }

  Future<void> completeSession() async {
    final s = data.session;
    if (s == null) return;
    await editData(
      context,
      title: 'Lưu kết quả buổi học',
      fields: [
        DataInput(
          'minutes',
          'Số phút thực học',
          value:
              '${s.number('actualMinutes', 60) == 0 ? 60 : s.number('actualMinutes', 60)}',
          numeric: true,
          required: true,
        ),
        DataInput(
          'rating',
          'Đánh giá (1–5)',
          value: '${s.number('rating') == 0 ? 5 : s.number('rating')}',
          numeric: true,
          required: true,
        ),
        DataInput(
          'notes',
          'Ghi chú',
          value: s.text('notes'),
          lines: 3,
          max: 2000,
        ),
      ],
      save: (v) async {
        final minutes = int.tryParse(v['minutes']!),
            rating = int.tryParse(v['rating']!);
        if (minutes == null ||
            minutes < 1 ||
            minutes > 1440 ||
            rating == null ||
            rating < 1 ||
            rating > 5) {
          return 'Kiểm tra số phút (1–1440) và đánh giá (1–5).';
        }
        final ok = await data.updateSession({
          'status': 'completed',
          'actualMinutes': minutes,
          'rating': rating,
          'notes': v['notes'],
          'completedAt': s.data['completedAt'] ?? FieldValue.serverTimestamp(),
        });
        if (ok && mounted) go(D.pl15);
        return ok ? null : data.error;
      },
    );
  }

  List<Widget> plannerBody() {
    final p = data.plan, s = data.session;
    switch (screen) {
      case D.pl01:
        return [
          hero(
            Icons.event_note_outlined,
            'Kế hoạch của bạn',
            '${data.items('plans').length} kế hoạch · ${data.sessions.length} buổi học',
            trailing: KRing(data.progress, size: 60, stroke: 7, labelSize: 14),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in [
                ('Ngày', D.pl02),
                ('Tuần', D.pl03),
                ('Tháng', D.pl04),
                ('Kế hoạch', D.pl05),
              ])
                OutlinedButton(onPressed: () => go(a.$2), child: Text(a.$1)),
            ],
          ),
          heading('Buổi học tiếp theo'),
          if (data.sessions
              .where(
                (s) =>
                    s.text('status') != 'completed' &&
                    (s.date('startAt')?.isAfter(DateTime.now()) ?? false),
              )
              .isEmpty)
            empty('Chưa có lịch học sắp tới.'),
          ...data.sessions
              .where(
                (s) =>
                    s.text('status') != 'completed' &&
                    (s.date('startAt')?.isAfter(DateTime.now()) ?? false),
              )
              .take(5)
              .map(sessionRow),
          action('Tạo kế hoạch mới', () => go(D.pl06), icon: Icons.add),
        ];
      case D.pl02:
      case D.pl03:
      case D.pl04:
        final date = DateTime.tryParse(value('calendarDate')) ?? DateTime.now();
        final start = DateTime(
          date.year,
          date.month,
          date.day,
        ).subtract(Duration(days: screen == D.pl03 ? date.weekday - 1 : 0));
        final matches = data.sessions.where((s) {
          final d = s.date('startAt');
          return d != null &&
              (screen == D.pl04
                  ? d.year == date.year && d.month == date.month
                  : screen == D.pl03
                  ? !d.isBefore(start) &&
                        d.isBefore(start.add(const Duration(days: 7)))
                  : sameDay(d, date));
        }).toList();
        return [
          row(
            'Ngày đang xem',
            dateLabel(date),
            Icons.calendar_month,
            () => chooseDate('calendarDate', current: date),
          ),
          if (matches.isEmpty)
            empty('Không có buổi học trong khoảng thời gian này.'),
          ...matches.map(sessionRow),
          action('Tạo kế hoạch', () => go(D.pl06), icon: Icons.add),
        ];
      case D.pl05:
        return [
          if (data.items('plans').isEmpty)
            empty('Chưa có kế hoạch. Tạo kế hoạch đầu tiên của bạn.'),
          for (final plan in data.items('plans'))
            row(
              plan.text('title'),
              '${planSessions(plan.id).length} buổi · ${plan.text('source') == 'gemini' ? 'AI' : 'Tự tạo'}',
              Icons.menu_book_outlined,
              () {
                data.select('plans', plan.id);
                go(D.pl12);
              },
            ),
          action('Tạo kế hoạch mới', () => go(D.pl06), icon: Icons.add),
        ];
      case D.pl06:
        return [
          step(1, 'Mục tiêu'),
          const Icon(Icons.smart_toy_outlined, size: 80, color: green),
          field(
            'planTitle',
            'Tên kế hoạch',
            initial: 'Kế hoạch học tập',
            max: 120,
          ),
          field('planObjective', 'Mục tiêu học tập', lines: 3, max: 1000),
          action('Chọn môn học', () => go(D.pl07)),
          action(
            'Đề xuất lịch với AI',
            () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AiScheduleScreen(
                  initialSubjects:
                      ((draft['courses'] as List<String>?) ?? _courseNames)
                          .join(', '),
                  initialHours: '${vm.allocatedHours}',
                  initialObjective: value('planObjective'),
                ),
              ),
            ),
            icon: Icons.auto_awesome,
          ),
        ];
      case D.pl07:
        final chosen =
            (draft['courses'] as List<String>?) ?? List.of(_courseNames);
        return [
          step(2, 'Môn học'),
          for (final name in _courseNames)
            CheckboxListTile(
              value: chosen.contains(name),
              title: Text(name),
              onChanged: (_) => changed(() {
                final next = List<String>.of(chosen);
                next.contains(name) ? next.remove(name) : next.add(name);
                draft['courses'] = next;
              }),
            ),
          action('Tiếp tục (${chosen.length} môn)', () {
            if (chosen.isEmpty) {
              message('Chọn ít nhất một môn.');
              return;
            }
            go(D.pl08);
          }),
        ];
      case D.pl08:
        final start = DateTime.tryParse(value('planStart')) ?? DateTime.now(),
            end =
                DateTime.tryParse(value('planEnd')) ??
                DateTime.now().add(const Duration(days: 28));
        return [
          step(3, 'Thời hạn'),
          row(
            'Ngày bắt đầu',
            dateLabel(start),
            Icons.today,
            () => chooseDate('planStart', current: start),
          ),
          row(
            'Ngày kết thúc',
            dateLabel(end),
            Icons.event,
            () => chooseDate('planEnd', current: end),
          ),
          const T(
            'Mỗi kế hoạch tối đa 90 ngày. Giờ học lưu theo thời điểm cụ thể và hiển thị theo múi giờ thiết bị.',
            color: muted,
          ),
          action('Phân bổ thời lượng', () => go(D.pl09)),
        ];
      case D.pl09:
        return [
          for (var i = 0; i < _courseNames.length; i++)
            if (((draft['courses'] as List<String>?) ?? _courseNames).contains(
              _courseNames[i],
            ))
              row(
                _courseNames[i],
                '${vm.subjectHours[i]} giờ/tuần',
                Icons.timer_outlined,
                () async {
                  await editData(
                    context,
                    title: 'Thời lượng ${_courseNames[i]}',
                    fields: [
                      DataInput(
                        'hours',
                        'Giờ mỗi tuần',
                        value: '${vm.subjectHours[i]}',
                        numeric: true,
                        required: true,
                      ),
                    ],
                    save: (v) async {
                      final h = int.tryParse(v['hours']!);
                      if (h == null || !vm.setSubjectHours(i, h)) {
                        return 'Số giờ phải dương và không vượt quỹ tuần.';
                      }
                      return null;
                    },
                  );
                },
              ),
          row(
            'Quỹ học tập mỗi tuần',
            '${vm.allocatedHours}/${vm.weeklyHours} giờ',
            Icons.edit_calendar_outlined,
            () async {
              await editData(
                context,
                title: 'Quỹ thời gian tuần',
                fields: [
                  DataInput(
                    'hours',
                    'Tổng giờ',
                    value: '${vm.weeklyHours}',
                    numeric: true,
                  ),
                ],
                save: (v) async {
                  final h = int.tryParse(v['hours']!);
                  return h != null && vm.setWeeklyHours(h)
                      ? null
                      : 'Quỹ tuần cần ≥ tổng phân bổ và ≤ 168 giờ.';
                },
              );
            },
          ),
          action('Thiết lập ngày học', () => go(D.pl10)),
        ];
      case D.pl10:
        final days = (draft['days'] as List<int>?) ?? [1, 3, 5];
        return [
          heading('Ngày học trong tuần'),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 1; i <= 7; i++)
                FilterChip(
                  label: Text(i == 7 ? 'CN' : 'T${i + 1}'),
                  selected: days.contains(i),
                  onSelected: (_) => changed(() {
                    final next = List<int>.of(days);
                    next.contains(i) ? next.remove(i) : next.add(i);
                    draft['days'] = next..sort();
                  }),
                ),
            ],
          ),
          heading('Khung giờ ưu tiên'),
          for (final slot in vm.idealTimeSlots)
            T('${slot.label} · ${slot.range}'),
          Wrap(
            spacing: 8,
            children: [
              for (final slot in StudyTimeSlot.values)
                FilterChip(
                  label: Text(slot.label),
                  selected: vm.idealTimeSlots.contains(slot),
                  onSelected: (_) {
                    final next = vm.idealTimeSlots.toSet();
                    next.contains(slot) ? next.remove(slot) : next.add(slot);
                    vm.setIdealTimeSlots(next);
                  },
                ),
            ],
          ),
          SwitchListTile(
            title: const Text('Nhắc trước buổi học 15 phút'),
            subtitle: const Text('Lưu tùy chọn; chưa gửi thông báo đẩy.'),
            value: draft['planReminder'] != false,
            onChanged: (v) => changed(() => draft['planReminder'] = v),
          ),
          action('Xem trước', () => go(D.pl11)),
        ];
      case D.pl11:
        return [
          const Icon(Icons.fact_check_outlined, size: 72, color: green),
          bold(value('planTitle', 'Kế hoạch học tập'), 22),
          T(value('planObjective')),
          KCard([
            T(
              'Môn học: ${((draft['courses'] as List<String>?) ?? _courseNames).join(', ')}',
            ),
            gap(8),
            T(
              'Ngày học: ${((draft['days'] as List<int>?) ?? [1, 3, 5]).map((v) => v == 7 ? 'CN' : 'T${v + 1}').join(' · ')}',
            ),
            gap(8),
            T('Quỹ tuần: ${vm.weeklyHours} giờ · ${vm.idealTimeLabel}'),
            gap(8),
            const T(
              'Hệ thống tạo từng buổi học và kiểm tra trùng giờ trước khi lưu.',
              color: muted,
            ),
          ]),
          action('Tạo kế hoạch và lưu lịch', createPlan),
        ];
      case D.pl12:
        if (p == null) {
          return [
            empty('Hãy chọn kế hoạch trong danh sách.'),
            action('Danh sách kế hoạch', () => go(D.pl05)),
          ];
        }
        return [
          hero(Icons.menu_book_outlined, p.text('title'), p.text('objective')),
          plannerStats([
            (Icons.event, '${planSessions().length}', 'Buổi học'),
            (
              Icons.task_alt,
              '${planSessions().where((s) => s.text('status') == 'completed').length}',
              'Hoàn thành',
            ),
          ]),
          for (final a in [
            ('Các buổi học', D.pl13),
            ('Lịch sử học tập', D.pl15),
          ])
            row(a.$1, '', Icons.list_alt, () => go(a.$2)),
          action('Thêm buổi học', () => editSession(), icon: Icons.add),
          action('Sửa tên / mục tiêu', () async {
            await editData(
              context,
              title: 'Chỉnh kế hoạch',
              fields: [
                DataInput(
                  'title',
                  'Tên',
                  value: p.text('title'),
                  required: true,
                  max: 120,
                ),
                DataInput(
                  'objective',
                  'Mục tiêu',
                  value: p.text('objective'),
                  lines: 3,
                  max: 1000,
                ),
              ],
              save: (v) async =>
                  await data.saveCalendar(
                    plan: StudyRecord(p.id, {...p.data, ...v}),
                    sessions: [],
                    existingPlan: p,
                  )
                  ? null
                  : data.error,
            );
          }, icon: Icons.edit_outlined),
        ];
      case D.pl13:
        return [
          if (planSessions().isEmpty)
            empty('Chưa có buổi học trong kế hoạch này.'),
          ...planSessions().map(sessionRow),
          action('Thêm buổi học', () => editSession(), icon: Icons.add),
        ];
      case D.pl14:
      case D.pl16:
        if (s == null) {
          return [
            empty('Chưa chọn buổi học.'),
            action('Xem lịch', () => go(D.pl01)),
          ];
        }
        return [
          hero(Icons.school_outlined, s.text('title'), s.text('subject')),
          row(
            'Thời gian',
            '${dateLabel(s.date('startAt')!)} · ${clockLabel(s.date('startAt')!)} – ${clockLabel(s.date('endAt')!)}',
            Icons.schedule,
            () => editSession(reschedule: true),
          ),
          KCard([
            bold('Địa điểm'),
            T(s.text('location', 'Chưa cập nhật')),
            gap(12),
            bold('Nội dung'),
            T(s.text('notes')),
            gap(12),
            bold('Tài liệu'),
            T(s.text('materials')),
          ]),
          if (s.text('status') == 'completed')
            row(
              'Đã hoàn thành',
              '${s.number('actualMinutes')} phút · ${s.number('rating')}/5',
              Icons.task_alt,
              null,
            ),
          action(
            'Đổi lịch / sửa buổi học',
            () => editSession(reschedule: true),
            icon: Icons.edit_calendar_outlined,
          ),
          action(
            s.text('status') == 'completed'
                ? 'Sửa kết quả'
                : 'Hoàn thành và đánh giá',
            () => go(D.pl18),
          ),
        ];
      case D.pl15:
        return [
          if (planSessions()
              .where((s) => s.text('status') == 'completed')
              .isEmpty)
            empty('Chưa có buổi học hoàn thành.'),
          ...planSessions()
              .where((s) => s.text('status') == 'completed')
              .map(sessionRow),
        ];
      case D.pl17:
        return [
          T(
            p == null
                ? 'Chọn một kế hoạch để thêm lịch.'
                : 'Kế hoạch: ${p.text('title')}',
          ),
          action('Chọn kế hoạch', () => go(D.pl05)),
          if (p != null)
            action(
              'Chọn ngày giờ và lưu buổi học',
              () => editSession(),
              icon: Icons.add,
            ),
        ];
      case D.pl18:
        return [
          if (s == null)
            empty('Chưa chọn buổi học.')
          else ...[
            const Icon(Icons.celebration_outlined, size: 90, color: green),
            bold(s.text('title'), 22),
            const T(
              'Nhập thời gian thực học và đánh giá. Chỉ tính thống kê sau khi lưu thành công.',
              color: muted,
            ),
            action('Lưu kết quả buổi học', completeSession),
          ],
        ];
      default:
        return [];
    }
  }
}
