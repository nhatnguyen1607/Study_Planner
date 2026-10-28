part of 'database_frame.dart';

extension _HomeFrames on _DatabaseFrameState {
  Future<void> addTask([StudyRecord? task]) async {
    final id = task?.id ?? data.repository.newId('tasks');
    await editData(
      context,
      title: task == null ? 'Thêm việc cần làm' : 'Sửa việc cần làm',
      fields: [
        DataInput(
          'title',
          'Tên việc',
          value: task?.text('title') ?? '',
          required: true,
          max: 120,
        ),
        DataInput(
          'notes',
          'Mô tả',
          value: task?.text('notes') ?? '',
          lines: 3,
          max: 2000,
        ),
      ],
      save: (v) async =>
          await data.save('tasks', id, {
            'title': v['title'],
            'notes': v['notes'],
            if (task == null) ...{'completed': false, 'archived': false},
          }, existing: task)
          ? null
          : data.error,
    );
  }

  Future<void> searchFor(String value) async {
    if (await data.search(value) && mounted) go(D.hm10);
  }

  List<Widget> homeBody() {
    final today = data.sessions
        .where(
          (s) =>
              s.date('startAt') != null &&
              sameDay(s.date('startAt')!, DateTime.now()),
        )
        .toList();
    switch (screen) {
      case D.hm01:
        final profile = UserProfileScope.maybeOf(context)?.profile;
        return [
          hero(
            Icons.waving_hand_outlined,
            'Xin chào, ${profile?.displayName ?? 'bạn'}!',
            'Lịch và tiến độ riêng của tài khoản bạn.',
            trailing: KRing(data.progress, size: 64, stroke: 7, labelSize: 14),
          ),
          plannerStats([
            (Icons.menu_book, '${data.items('plans').length}', 'Kế hoạch'),
            (Icons.task_alt, '${data.completedTasks}', 'Việc đã xong'),
            (Icons.schedule, '${data.totalMinutes}', 'Phút đã học'),
          ]),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in [
                ('Mục tiêu', D.go01),
                ('Tìm kiếm', D.hm09),
                ('Thông báo', D.hm07),
                ('Thống kê', D.an01),
              ])
                OutlinedButton(onPressed: () => go(a.$2), child: Text(a.$1)),
            ],
          ),
          heading('Học hôm nay'),
          if (today.isEmpty) empty('Hôm nay chưa có buổi học.'),
          ...today.map(sessionRow),
          row(
            'Hoạt động sắp tới',
            'Xem lịch học của bạn',
            Icons.upcoming_outlined,
            () => go(D.hm04),
          ),
          row(
            'Hoạt động gần đây',
            'Kết quả học tập đã lưu',
            Icons.history,
            () => go(D.hm06),
          ),
          action('Tạo kế hoạch học tập', () => go(D.pl06), icon: Icons.add),
        ];
      case D.hm02:
        return [
          if (today.isEmpty) empty('Hôm nay chưa có buổi học.'),
          ...today.map(sessionRow),
          action('Thêm lịch học', () => go(D.pl05), icon: Icons.add),
        ];
      case D.hm03:
        return [
          action('Thêm việc cần làm', () => addTask(), icon: Icons.add),
          if (data.items('tasks').isEmpty) empty('Chưa có việc cần làm.'),
          for (final task in data.items('tasks'))
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
                    bold(task.text('title')),
                    T(task.text('notes'), color: muted),
                  ]),
                ),
                IconButton(
                  tooltip: 'Chỉnh sửa',
                  onPressed: () => addTask(task),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Lưu trữ',
                  onPressed: data.busy
                      ? null
                      : () => data.save('tasks', task.id, {
                          'archived': true,
                        }, existing: task),
                  icon: const Icon(Icons.archive_outlined),
                ),
              ], gap: 6),
            ]),
        ];
      case D.hm04:
        final future = data.sessions
            .where((s) => s.date('startAt')?.isAfter(DateTime.now()) ?? false)
            .toList();
        return [
          if (future.isEmpty) empty('Chưa có hoạt động sắp tới.'),
          ...future.map(sessionRow),
        ];
      case D.hm05:
        return analyticsBody();
      case D.hm06:
        return [
          if (data.completedSessions.isEmpty)
            empty('Chưa có hoạt động hoàn thành.'),
          ...data.completedSessions.reversed.map(sessionRow),
        ];
      case D.hm07:
        return [
          const T(
            'Danh sách thông báo được lưu theo tài khoản. Thông báo đẩy chưa được cấu hình.',
            color: muted,
          ),
          if (data.items('notifications').isEmpty)
            empty('Bạn chưa có thông báo.'),
          for (final n in data.items('notifications'))
            row(
              n.text('title'),
              n.text('body'),
              n.flag('read')
                  ? Icons.notifications_none
                  : Icons.notifications_active_outlined,
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
          if (n == null)
            empty('Chưa chọn thông báo.')
          else ...[
            const Icon(
              Icons.notifications_active_outlined,
              size: 74,
              color: green,
            ),
            bold(n.text('title'), 22),
            T(n.text('body')),
            if (data.find('sessions', n.text('sessionId')) != null)
              action(
                'Xem buổi học',
                () => openSession(data.find('sessions', n.text('sessionId'))!),
              ),
          ],
        ];
      case D.hm09:
        return [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Tìm kế hoạch, môn học, mục tiêu…',
              prefixIcon: Icon(Icons.search),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: searchFor,
          ),
          heading('Tìm kiếm gần đây'),
          for (final q
              in data.find('settings', 'search')?.strings('recent') ??
                  <String>[])
            row(q, '', Icons.history, () => searchFor(q)),
          TextButton(
            onPressed: () => data.setting('search', {'recent': <String>[]}),
            child: const Text('Xóa lịch sử tìm kiếm'),
          ),
        ];
      case D.hm10:
        final query = data.query.toLowerCase();
        final results = <Widget>[];
        for (final kind in ['plans', 'sessions', 'goals', 'tasks']) {
          for (final r
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
                r.text('title'),
                {
                  'plans': 'Kế hoạch',
                  'sessions': 'Buổi học',
                  'goals': 'Mục tiêu',
                  'tasks': 'Việc cần làm',
                }[kind]!,
                Icons.search,
                () {
                  if (kind == 'tasks') {
                    addTask(r);
                    return;
                  }
                  data.select(kind, r.id);
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
          bold('Kết quả cho “${data.query}”'),
          if (results.isEmpty) empty('Không tìm thấy dữ liệu phù hợp.'),
          ...results,
        ];
      default:
        return [];
    }
  }
}
