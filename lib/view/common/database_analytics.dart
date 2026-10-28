part of 'database_frame.dart';

extension _AnalyticsFrames on _DatabaseFrameState {
  List<Widget> analyticsBody() {
    final now = DateTime.now(), done = data.completedSessions;
    final period = screen == D.an02
        ? [1, 7, 30][detailTab.clamp(0, 2)]
        : screen == D.an06
        ? 30
        : detailTab == 2
        ? 36500
        : detailTab == 1
        ? 30
        : 7;
    final first = screen == D.an06
        ? DateTime(now.year, now.month, 1)
        : DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: period - 1));
    final filtered = done
        .where(
          (s) =>
              s.date('completedAt') != null &&
              !s.date('completedAt')!.isBefore(first),
        )
        .toList();
    final minutes = filtered.fold<int>(
      0,
      (total, s) => total + s.number('actualMinutes'),
    );
    final previous = done
        .where(
          (s) =>
              s.date('completedAt') != null &&
              s.date('completedAt')!.isBefore(first) &&
              !s
                  .date('completedAt')!
                  .isBefore(first.subtract(Duration(days: period))),
        )
        .fold<int>(0, (total, s) => total + s.number('actualMinutes'));
    final bySubject = <String, int>{};
    for (final session in filtered) {
      bySubject[session.text('subject')] =
          (bySubject[session.text('subject')] ?? 0) +
          session.number('actualMinutes');
    }
    String duration(int amount) => '${amount ~/ 60}h ${amount % 60}m';
    final growth = previous == 0
        ? '—'
        : '${minutes >= previous ? '+' : ''}${((minutes - previous) / previous * 100).round()}%';
    final days =
        done
            .map((s) => s.date('completedAt'))
            .whereType<DateTime>()
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet()
            .toList()
          ..sort();
    var longest = 0, current = 0;
    DateTime? last;
    for (final day in days) {
      current = last != null && day.difference(last).inDays == 1
          ? current + 1
          : 1;
      if (current > longest) longest = current;
      last = day;
    }
    final badges =
        <
          ({
            String name,
            String description,
            int count,
            int target,
            IconData icon,
          })
        >[
          (
            name: 'Học tập chăm chỉ',
            description: 'Đạt 7 ngày liên tục',
            count: data.streak,
            target: 7,
            icon: Icons.local_fire_department_outlined,
          ),
          (
            name: 'Bậc thầy thời gian',
            description: 'Hoàn thành 50 buổi học',
            count: done.length,
            target: 50,
            icon: Icons.emoji_events_outlined,
          ),
          (
            name: 'Nhà nghiên cứu',
            description: 'Học 7 môn khác nhau',
            count: done.map((s) => s.text('subject')).toSet().length,
            target: 7,
            icon: Icons.menu_book_outlined,
          ),
          (
            name: 'Kỷ luật vàng',
            description: 'Hoàn thành 30 việc cần làm',
            count: data.completedTasks,
            target: 30,
            icon: Icons.star,
          ),
          (
            name: 'Đọc sách chăm chỉ',
            description: 'Hoàn thành 20 việc đọc',
            count: data
                .items('tasks')
                .where(
                  (t) =>
                      t.flag('completed') &&
                      t.text('title').toLowerCase().contains('đọc'),
                )
                .length,
            target: 20,
            icon: Icons.auto_stories_outlined,
          ),
          (
            name: 'Thành thạo ôn tập',
            description: 'Hoàn thành 20 buổi học',
            count: done.length,
            target: 20,
            icon: Icons.school_outlined,
          ),
        ];
    Widget bars(List<int> values, List<String> labels, String title) => KCard([
      bold(title, 14),
      gap(14),
      SizedBox(
        height: 146,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < values.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      T('${values[i]}', size: 10, color: muted, center: true),
                      gap(5),
                      Container(
                        width: 22,
                        height: values.every((v) => v == 0)
                            ? 3
                            : (values[i] /
                                      values.reduce((a, b) => a > b ? a : b) *
                                      88)
                                  .clamp(3, 88)
                                  .toDouble(),
                        decoration: BoxDecoration(
                          color: i == values.length - 1
                              ? dark
                              : const Color(0xFF58B96B),
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      gap(11),
                      SizedBox(
                        height: 18,
                        child: T(
                          labels[i],
                          size: 10,
                          center: true,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ]);
    Widget legend() => KCard([
      for (final entry in bySubject.entries)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: KRow([
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: subjectPalette[subjectFor(entry.key).color % 7],
                shape: BoxShape.circle,
              ),
            ),
            Expanded(child: T(entry.key, size: 12)),
            T(duration(entry.value), size: 12, color: muted),
            T(
              '${minutes == 0 ? 0 : (entry.value / minutes * 100).round()}%',
              size: 12,
              color: dark,
            ),
          ], gap: 9),
        ),
      if (bySubject.isEmpty)
        const T(
          'Hoàn thành buổi học để xem phân bổ thời gian.',
          size: 12,
          color: muted,
          center: true,
        ),
    ]);
    final seven = List.generate(7, (i) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i));
      return done
          .where(
            (s) =>
                s.date('completedAt') != null &&
                sameDay(s.date('completedAt')!, date),
          )
          .fold<int>(0, (total, s) => total + s.number('actualMinutes'));
    });
    final sevenLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return d.weekday == 7 ? 'CN' : 'T${d.weekday + 1}';
    });
    if (screen == D.an08) {
      return [
        segments(
          ['Tất cả', 'Đã đạt', 'Chưa đạt'],
          detailTab,
          (i) => changed(() => detailTab = i),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < badges.length; i++)
                if (detailTab == 0 ||
                    (badges[i].count >= badges[i].target) == (detailTab == 1))
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 158),
                      child: KCard(
                        [
                          Icon(
                            badges[i].icon,
                            size: 36,
                            color: badges[i].count >= badges[i].target
                                ? dark
                                : const Color(0xFF8C9C90),
                          ),
                          gap(12),
                          T(
                            badges[i].name,
                            size: 13,
                            weight: FontWeight.w600,
                            center: true,
                          ),
                          gap(5),
                          T(
                            badges[i].description,
                            size: 11,
                            color: muted,
                            center: true,
                          ),
                        ],
                        onTap: () {
                          draft['badgeIndex'] = i;
                          go(D.an09);
                        },
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ];
    }
    if (screen == D.an09) {
      final badge =
          badges[(draft['badgeIndex'] as int? ?? 0).clamp(
            0,
            badges.length - 1,
          )];
      final earned = badge.count >= badge.target;
      return [
        const Center(child: StudyMascot(pose: 'goals_celebrate', size: 110)),
        Center(
          child: Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              color: earned ? green : pale,
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge.icon,
              color: earned ? Colors.white : muted,
              size: 61,
            ),
          ),
        ),
        T(badge.name, size: 23, weight: FontWeight.w700, center: true),
        T(badge.description, color: muted, center: true),
        KCard([
          KRow([
            Icon(
              earned ? Icons.check_circle : Icons.lock_outline,
              color: green,
            ),
            Expanded(
              child: T(
                earned ? 'Đã đạt được' : 'Đang chinh phục',
                weight: FontWeight.w600,
              ),
            ),
            T('${badge.count}/${badge.target}', size: 13),
          ]),
          gap(14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (badge.count / badge.target).clamp(0, 1),
              minHeight: 10,
              color: green,
              backgroundColor: pale,
            ),
          ),
          gap(10),
          T(
            '${((badge.count / badge.target).clamp(0, 1) * 100).round()}% hoàn thành',
            size: 12,
            color: muted,
          ),
        ]),
        mascotTip(
          'Kiên trì hôm nay',
          'Bạn đang xây những bước tiến cho ngày mai.',
          pose: 'sprout_watering',
        ),
      ];
    }
    if (screen == D.an07) {
      final date = DateTime.tryParse(value('streakMonth')) ?? now;
      return [
        KCard([
          const Center(child: StudyMascot(pose: 'habits_streak', size: 104)),
          T(
            '${data.streak} ngày',
            size: 30,
            center: true,
            weight: FontWeight.w700,
          ),
          const T(
            'Chuỗi học tập liên tục!',
            size: 13,
            center: true,
            color: muted,
          ),
          gap(16),
          mascotTip(
            'Bạn đã rất cố gắng!',
            'Mỗi buổi học hoàn thành là một bước tiến.',
            pose: 'sprout_watering',
          ),
          gap(18),
          plannerStats([
            (Icons.local_fire_department, '${data.streak}', 'Chuỗi hiện tại'),
            (Icons.emoji_events_outlined, '$longest', 'Chuỗi cao nhất'),
            (Icons.task_alt, '${data.progress}%', 'Tỷ lệ hoàn thành'),
          ]),
        ]),
        calendarMonth(
          date,
          onSelect: (day) =>
              changed(() => draft['streakMonth'] = day.toIso8601String()),
          completed: days
              .where((d) => d.year == date.year && d.month == date.month)
              .map((d) => d.day)
              .toSet(),
        ),
        row(
          days.any((d) => sameDay(d, now))
              ? 'Hôm nay đã học tập'
              : 'Giữ nhịp học hôm nay',
          'Tiếp tục duy trì chuỗi của bạn!',
          Icons.event_available_outlined,
          () => go(D.pl01),
        ),
      ];
    }
    if (screen == D.an01 || screen == D.hm05) {
      return [
        segments(
          ['7 ngày', '30 ngày'],
          detailTab,
          (i) => changed(() => detailTab = i),
        ),
        metricPair(
          ('Tổng thời gian', duration(minutes), growth),
          (
            'Đã hoàn thành',
            '${data.completedSessions.length} / ${data.sessions.length}',
            '${data.progress}%',
          ),
        ),
        KRow([
          Expanded(
            child: KCard([
              const T('Tổng tiến độ', size: 12, color: muted),
              gap(14),
              Center(
                child: KRing(
                  data.progress,
                  size: 108,
                  stroke: 12,
                  labelSize: 23,
                ),
              ),
              gap(12),
            ]),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: light,
                borderRadius: BorderRadius.circular(18),
              ),
              child: KColumn([
                const Center(
                  child: StudyMascot(pose: 'focus_report', size: 88),
                ),
                const T(
                  'Mỗi ngày học một chút,\ntiến bộ thêm một bước!',
                  size: 12,
                  color: navy,
                  center: true,
                ),
              ], center: true),
            ),
          ),
        ], gap: 12),
        legend(),
        KCard([
          heading('So sánh kỳ trước'),
          gap(10),
          KRow([
            Expanded(
              child: KColumn([
                const Icon(
                  Icons.calendar_today_outlined,
                  color: green,
                  size: 20,
                ),
                gap(7),
                const T('Thời gian học', size: 10, color: muted, center: true),
                T(
                  growth,
                  size: 13,
                  color: dark,
                  center: true,
                  weight: FontWeight.w600,
                ),
              ]),
            ),
            Expanded(
              child: KColumn([
                const Icon(Icons.done_all, color: green, size: 20),
                gap(7),
                const T(
                  'Buổi hoàn thành',
                  size: 10,
                  color: muted,
                  center: true,
                ),
                T(
                  '${filtered.length}',
                  size: 13,
                  color: dark,
                  center: true,
                  weight: FontWeight.w600,
                ),
              ]),
            ),
            Expanded(
              child: KColumn([
                const Icon(Icons.menu_book_outlined, color: green, size: 20),
                gap(7),
                const T('Số môn đã học', size: 10, color: muted, center: true),
                T(
                  '${bySubject.length}',
                  size: 13,
                  color: dark,
                  center: true,
                  weight: FontWeight.w600,
                ),
              ]),
            ),
          ]),
        ]),
        bars(seven, sevenLabels, 'Biểu đồ học tập tuần'),
        for (final item in [
          ('Thời gian học tập', D.an02, Icons.timer_outlined),
          ('Thống kê nhiệm vụ', D.an03, Icons.task_alt),
          ('Thống kê theo môn', D.an04, Icons.donut_large),
          ('Chuỗi học tập', D.an07, Icons.local_fire_department_outlined),
          ('Huy hiệu', D.an08, Icons.workspace_premium_outlined),
        ])
          row(item.$1, '', item.$3, () => go(item.$2)),
      ];
    }
    if (screen == D.an02) {
      final values = detailTab == 0
          ? List.generate(
              8,
              (i) => filtered
                  .where((s) => (s.date('startAt')?.hour ?? 0) ~/ 3 == i)
                  .fold<int>(
                    0,
                    (total, s) => total + s.number('actualMinutes'),
                  ),
            )
          : seven;
      return [
        segments(
          ['Ngày', 'Tuần', 'Tháng'],
          detailTab,
          (i) => changed(() => detailTab = i),
        ),
        KCard([
          const T('Tổng thời gian', size: 13, color: muted),
          gap(5),
          bold(duration(minutes), 26),
          T(dateLabel(now), size: 12, color: muted),
        ]),
        bars(
          values,
          detailTab == 0 ? List.generate(8, (i) => '${i * 3}h') : sevenLabels,
          'Thời gian học (phút)',
        ),
        heading('Phân bổ thời gian'),
        legend(),
        mascotTip(
          'Tìm nhịp học của bạn',
          'Duy trì thời gian đều đặn để học hiệu quả hơn.',
          pose: 'focus_report',
        ),
      ];
    }
    if (screen == D.an03) {
      final tasks = data.items('tasks'),
          values = List.generate(7, (i) {
            final day = now.subtract(Duration(days: 6 - i));
            return tasks
                .where(
                  (t) =>
                      t.flag('completed') &&
                      t.date('completedAt') != null &&
                      sameDay(t.date('completedAt')!, day),
                )
                .length;
          });
      return [
        segments(
          ['Tuần', 'Tháng', 'Tất cả'],
          detailTab,
          (i) => changed(() => detailTab = i),
        ),
        metricPair(
          (
            'Đã hoàn thành',
            '${data.completedTasks}',
            '${tasks.isEmpty ? 0 : (data.completedTasks / tasks.length * 100).round()}%',
          ),
          (
            'Chưa hoàn thành',
            '${tasks.length - data.completedTasks}',
            'Cần hoàn thành',
          ),
        ),
        bars(values, sevenLabels, 'Tiến độ theo ngày'),
        heading('Trạng thái nhiệm vụ'),
        row(
          'Việc đã hoàn thành',
          '${data.completedTasks}/${tasks.length}',
          Icons.check_circle_outline,
          () => go(D.hm03),
        ),
        row(
          'Việc đang thực hiện',
          '${tasks.length - data.completedTasks} việc',
          Icons.schedule,
          () => go(D.hm03),
        ),
        const Align(
          alignment: Alignment.centerRight,
          child: StudyMascot(pose: 'habits_checklist', size: 100),
        ),
      ];
    }
    if (screen == D.an04) {
      return [
        segments(
          ['Tuần', 'Tháng', 'Tất cả'],
          detailTab,
          (i) => changed(() => detailTab = i),
        ),
        KCard([
          Center(
            child: KRing(
              minutes > 0 ? 100 : 0,
              size: 158,
              stroke: 22,
              labelSize: 25,
            ),
          ),
          gap(12),
          T(duration(minutes), size: 23, weight: FontWeight.w700, center: true),
          const T('Tổng thời gian học', size: 12, color: muted, center: true),
        ]),
        legend(),
        heading('Thời lượng từng môn'),
        for (final entry in bySubject.entries)
          progressLine(
            entry.key,
            minutes == 0 ? 0 : (entry.value / minutes * 100).round(),
          ),
        if (bySubject.isEmpty)
          mascotTip(
            'Chưa có dữ liệu theo môn',
            'Kết quả buổi học đã lưu sẽ xuất hiện ở đây.',
            pose: 'focus_report',
          ),
      ];
    }
    if (screen == D.an05) {
      return [
        row(
          'Tuần học tập',
          '${dateLabel(now.subtract(Duration(days: 6)))} – ${dateLabel(now)}',
          Icons.calendar_today_outlined,
          null,
        ),
        KCard([
          const T('Tổng thời gian', size: 13, color: muted),
          bold(duration(seven.fold(0, (a, b) => a + b)), 26),
        ]),
        bars(seven, sevenLabels, 'Thời gian học (phút)'),
        KCard([
          heading('So sánh kỳ trước'),
          statLine('Thời gian học', growth),
          statLine('Số buổi hoàn thành', '${filtered.length}'),
        ]),
        action('Xem biểu đồ tháng', () => go(D.an06)),
      ];
    }
    final month = done
            .where(
              (s) =>
                  s.date('completedAt')?.month == now.month &&
                  s.date('completedAt')?.year == now.year,
            )
            .toList(),
        weeks = List.generate(
          5,
          (i) => done
              .where(
                (s) =>
                    s.date('completedAt')?.month == now.month &&
                    s.date('completedAt')?.year == now.year &&
                    (s.date('completedAt')!.day - 1) ~/ 7 == i,
              )
              .fold<int>(0, (total, s) => total + s.number('actualMinutes')),
        );
    return [
      T('Tháng ${now.month}, ${now.year}', size: 16, weight: FontWeight.w600),
      KCard([
        const T('Tổng thời gian', size: 13, color: muted),
        bold(
          duration(
            month.fold(0, (total, s) => total + s.number('actualMinutes')),
          ),
          26,
        ),
      ]),
      bars(weeks, ['T1', 'T2', 'T3', 'T4', 'T5'], 'Biểu đồ tháng (phút)'),
      heading('Top môn học trong tháng'),
      legend(),
      const Align(
        alignment: Alignment.centerRight,
        child: StudyMascot(pose: 'focus_report', size: 100),
      ),
    ];
  }
}
