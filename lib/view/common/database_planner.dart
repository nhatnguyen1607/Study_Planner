part of 'database_frame.dart';

extension _PlannerFrames on _DatabaseFrameState {
  List<StudyRecord> planSessions([String? id]) => data.sessions
      .where((s) => s.text('planId') == (id ?? data.selectedPlanId))
      .toList();
  void openSession(StudyRecord session) {
    data.select('sessions', session.id);
    vm.setRating(session.number('rating') > 0 ? session.number('rating') : 5);
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
    final chosen = data.selectedSubjects.map((s) => s.name).toList();
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
    if (vm.allocatedHours > vm.weeklyHours) {
      message('Tổng thời lượng vượt quỹ tuần. Hãy chỉnh lại phân bổ.');
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
        final index = chosen.indexOf(name);
        final hours = hoursFor(subjectFor(name));
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
      'subjectHours': {for (final c in chosen) c: hoursFor(subjectFor(c))},
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
    var date =
        (screen == D.pl17 ? DateTime.tryParse(value('calendarDate')) : null) ??
        current?.date('startAt') ??
        DateTime.now();
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

  List<Widget> plannerBody() => restoredPlannerBody();
}
