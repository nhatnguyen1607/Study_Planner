part of 'database_frame.dart';

extension _RestoredHome on _DatabaseFrameState {
  List<Widget> restoredHomeBody() {
    final day = DateTime.tryParse(value('homeDate')) ?? DateTime.now();
    final today = data.sessions
        .where(
          (s) => s.date('startAt') != null && sameDay(s.date('startAt')!, day),
        )
        .toList();
    final profile = UserProfileScope.maybeOf(context)?.profile;
    switch (screen) {
      case D.hm01:
        return [
          KRow([
            Expanded(
              child: KColumn([
                const T('Xin chào,', size: 15),
                T(
                  '${profile?.displayName ?? 'Bạn học'} 👋',
                  size: 23,
                  weight: FontWeight.w700,
                ),
                const T(
                  'Hôm nay là một ngày tốt để học tập!',
                  size: 12,
                  color: muted,
                ),
              ]),
            ),
            KColumn([
              IconButton(
                tooltip: 'Tìm kiếm',
                onPressed: () => go(D.hm09),
                icon: const Icon(Icons.search, size: 22),
              ),
              IconButton(
                tooltip: 'Thông báo',
                onPressed: () => go(D.hm07),
                icon: const Icon(Icons.notifications_outlined, size: 22),
              ),
            ], center: true),
            HoverAction(
              onTap: () => go(D.pl06),
              child: const StudyMascot(size: 74),
            ),
          ], gap: 7),
          dateStrip(
            day,
            (d) => changed(() => draft['homeDate'] = d.toIso8601String()),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: light,
              borderRadius: BorderRadius.circular(18),
            ),
            child: KRow([
              Expanded(
                child: KColumn([
                  bold('Tiến độ học tập', 17),
                  gap(6),
                  T(
                    '${data.completedSessions.length}/${data.sessions.length} buổi đã hoàn thành',
                    size: 12,
                    color: muted,
                  ),
                ]),
              ),
              KRing(data.progress, size: 76, stroke: 8, labelSize: 18),
            ], gap: 10),
          ),
          plannerStats([
            (
              Icons.menu_book_outlined,
              '${data.sessions.map((s) => s.text('subject')).toSet().length}',
              'Môn học',
            ),
            (
              Icons.task_alt,
              '${data.items('tasks').length - data.completedTasks}',
              'Việc cần làm',
            ),
            (Icons.schedule, '${data.totalMinutes ~/ 60}h', 'Đã học'),
            (Icons.insights, '${data.progress}%', 'Tiến độ'),
          ]),
          heading('Học hôm nay', action: 'Xem tất cả ›', tap: () => go(D.hm02)),
          if (today.isEmpty)
            mascotTip(
              'Một khởi đầu nhỏ',
              'Hôm nay chưa có buổi học. Tạo một kế hoạch cho mình nhé.',
              pose: 'home_calendar',
            ),
          ...today.take(3).map(sessionRow),
          row(
            'Hoạt động sắp diễn ra',
            'Xem lịch học tiếp theo',
            Icons.event_available_outlined,
            () => go(D.hm04),
          ),
          row(
            'Hoạt động gần đây',
            'Nhìn lại những điều bạn đã hoàn thành',
            Icons.history,
            () => go(D.hm06),
          ),
          row(
            'Mục tiêu học tập',
            'Theo dõi lộ trình của bạn',
            Icons.track_changes,
            () => go(D.go01),
          ),
          action('Tạo kế hoạch mới', () => go(D.pl06), icon: Icons.add),
        ];
      case D.hm02:
        return [
          T(dateLabel(day), size: 14, color: muted),
          dateStrip(
            day,
            (d) => changed(() => draft['homeDate'] = d.toIso8601String()),
          ),
          if (today.isEmpty) empty('Chưa có buổi học cho ngày này.'),
          ...today.map(sessionRow),
        ];
      case D.hm03:
        final tasks = data
            .items('tasks')
            .where(
              (t) => detailTab == 0 || t.flag('completed') == (detailTab == 2),
            )
            .toList();
        return [
          segments(
            [
              'Tất cả (${data.items('tasks').length})',
              'Đang làm',
              'Hoàn thành',
            ],
            detailTab,
            (i) => changed(() => detailTab = i),
          ),
          if (tasks.isEmpty) empty('Danh sách việc cần làm đang trống.'),
          for (final task in tasks)
            KCard([
              KRow([
                Checkbox(
                  value: task.flag('completed'),
                  onChanged: data.busy
                      ? null
                      : (v) => data.save('tasks', task.id, {
                          'completed': v,
                          'completedAt': v == true
                              ? FieldValue.serverTimestamp()
                              : null,
                        }, existing: task),
                ),
                Expanded(
                  child: KColumn([
                    T(task.text('title'), size: 14, weight: FontWeight.w600),
                    if (task.text('notes').isNotEmpty) ...[
                      gap(4),
                      T(task.text('notes'), size: 12, color: muted),
                    ],
                  ]),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Tùy chọn việc cần làm',
                  onSelected: (choice) {
                    if (choice == 'edit') {
                      addTask(task);
                    } else {
                      data.save('tasks', task.id, {
                        'archived': true,
                      }, existing: task);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                    PopupMenuItem(value: 'archive', child: Text('Lưu trữ')),
                  ],
                ),
              ], gap: 6),
            ], padding: 10),
        ];
      case D.hm04:
        final upcoming = data.sessions
            .where((s) => s.date('startAt')?.isAfter(DateTime.now()) ?? false)
            .toList();
        final dates = upcoming
            .map(
              (s) => DateTime(
                s.date('startAt')!.year,
                s.date('startAt')!.month,
                s.date('startAt')!.day,
              ),
            )
            .toSet();
        return [
          segments(
            ['Tất cả', 'Học tập', 'Khác'],
            detailTab,
            (i) => changed(() => detailTab = i),
          ),
          if (upcoming.isEmpty || detailTab == 2)
            empty('Chưa có hoạt động sắp diễn ra.'),
          if (detailTab != 2)
            for (final date in dates) ...[
              heading(dateLabel(date)),
              ...upcoming
                  .where((s) => sameDay(s.date('startAt')!, date))
                  .map(sessionRow),
            ],
        ];
      case D.hm05:
        return analyticsBody();
      case D.hm06:
        final completed = List<StudyRecord>.of(data.completedSessions)
          ..sort(
            (a, b) => (b.date('completedAt') ?? DateTime(2000)).compareTo(
              a.date('completedAt') ?? DateTime(2000),
            ),
          );
        return [
          segments(
            ['Tất cả', 'Học tập', 'Hệ thống'],
            detailTab,
            (i) => changed(() => detailTab = i),
          ),
          if (completed.isEmpty || detailTab == 2)
            empty('Những hoạt động hoàn thành sẽ xuất hiện ở đây.'),
          if (detailTab != 2)
            for (final session in completed)
              KRow(
                [
                  KColumn([
                    iconBox(
                      Icons.check,
                      size: 34,
                      radius: 17,
                      bg: green,
                      color: Colors.white,
                      iconSize: 20,
                    ),
                    Container(width: 2, height: 58, color: pale),
                  ], center: true),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: HoverAction(
                        onTap: () => openSession(session),
                        child: KColumn([
                          bold('Hoàn thành buổi học', 14),
                          T(session.text('subject'), size: 13, color: muted),
                          T(
                            '${session.number('actualMinutes')} phút · ${session.date('completedAt') == null ? '' : dateLabel(session.date('completedAt')!)}',
                            size: 12,
                            color: muted,
                          ),
                        ]),
                      ),
                    ),
                  ),
                ],
                gap: 16,
                start: true,
              ),
        ];
      case D.hm07:
        final notifications = data
            .items('notifications')
            .where(
              (n) =>
                  detailTab == 0 ||
                  n.text('kind') == (detailTab == 1 ? 'reminder' : 'system'),
            )
            .toList();
        return [
          segments(
            ['Tất cả', 'Nhắc nhở', 'Hệ thống'],
            detailTab,
            (i) => changed(() => detailTab = i),
          ),
          if (notifications.isEmpty)
            mascotTip(
              'Bạn đã cập nhật mọi thứ',
              'Thông báo mới sẽ xuất hiện tại đây.',
              pose: 'home_reminder',
            ),
          for (final n in notifications)
            row(
              n.text('title'),
              n.text('body'),
              Icons.notifications_outlined,
              () async {
                data.select('notifications', n.id);
                if (!n.flag('read')) {
                  await data.save('notifications', n.id, {
                    'read': true,
                  }, existing: n);
                }
                if (mounted) go(D.hm08);
              },
            ),
        ];
      case D.hm08:
        final n = data.find('notifications', data.selectedNotificationId);
        return [
          const Center(child: StudyMascot(pose: 'home_reminder', size: 140)),
          if (n == null)
            const T(
              'Chọn một thông báo để xem chi tiết.',
              center: true,
              color: muted,
            )
          else ...[
            T(n.text('title'), size: 23, weight: FontWeight.w700, center: true),
            T(n.text('body'), center: true),
            if (n.date('createdAt') != null)
              T(dateLabel(n.date('createdAt')!), center: true, color: muted),
            if (data.find('sessions', n.text('sessionId')) != null) ...[
              sessionRow(data.find('sessions', n.text('sessionId'))!),
              action(
                'Vào buổi học',
                () => openSession(data.find('sessions', n.text('sessionId'))!),
              ),
            ],
          ],
          mascotTip(
            'Chuẩn bị một chút nhé',
            'Xem lại tài liệu trước buổi học giúp bạn tự tin hơn.',
            pose: 'sprout_pencil',
          ),
        ];
      case D.hm09:
        return [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nhập môn học, kế hoạch...',
              prefixIcon: Icon(Icons.search),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: searchFor,
          ),
          heading('Gợi ý nhanh'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in data.subjects.take(6).map((s) => s.name))
                ActionChip(label: Text(name), onPressed: () => searchFor(name)),
            ],
          ),
          heading(
            'Tìm kiếm gần đây',
            action: 'Xóa tất cả',
            tap: () => data.setting('search', {'recent': <String>[]}),
          ),
          for (final query
              in data.find('settings', 'search')?.strings('recent') ??
                  <String>[])
            row(query, '', Icons.history, () => searchFor(query)),
          const Align(
            alignment: Alignment.centerRight,
            child: StudyMascot(pose: 'home_search', size: 112),
          ),
        ];
      case D.hm10:
        final query = data.query.toLowerCase();
        final results = <Widget>[];
        for (final kind in ['plans', 'sessions', 'goals', 'tasks']) {
          for (final record
              in data
                  .items(kind)
                  .where(
                    (r) =>
                        query.isNotEmpty &&
                        '${r.text('title')} ${r.text('subject')} ${r.text('notes')}'
                            .toLowerCase()
                            .contains(query),
                  )) {
            results.add(
              row(
                record.text('title'),
                {
                  'plans': 'Kế hoạch',
                  'sessions': 'Buổi học',
                  'goals': 'Mục tiêu',
                  'tasks': 'Việc cần làm',
                }[kind]!,
                Icons.search,
                () {
                  if (kind == 'tasks') {
                    addTask(record);
                    return;
                  }
                  data.select(kind, record.id);
                  go(
                    kind == 'plans'
                        ? D.pl12
                        : kind == 'sessions'
                        ? D.pl16
                        : D.go08,
                  );
                },
              ),
            );
          }
        }
        return [
          row(data.query, 'Từ khóa tìm kiếm', Icons.search, () => go(D.hm09)),
          if (results.isEmpty)
            mascotTip(
              'Chưa tìm thấy kết quả',
              'Thử một tên môn hoặc từ khóa khác.',
              pose: 'home_search',
            ),
          ...results,
        ];
      default:
        return [];
    }
  }
}
