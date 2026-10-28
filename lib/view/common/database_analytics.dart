part of 'database_frame.dart';

extension _AnalyticsFrames on _DatabaseFrameState {
  List<Widget> analyticsBody() {
    final now = DateTime.now(), done = data.completedSessions;
    final subjectMinutes = <String, int>{};
    for (final s in done) {
      final subject = s.text('subject');
      subjectMinutes[subject] =
          (subjectMinutes[subject] ?? 0) + s.number('actualMinutes');
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
            description: 'Học liên tục 7 ngày',
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
            description: 'Hoàn thành buổi học ở 7 môn',
            count: subjectMinutes.length,
            target: 7,
            icon: Icons.menu_book_outlined,
          ),
          (
            name: 'Kỷ luật vàng',
            description: 'Hoàn thành 30 việc cần làm',
            count: data.completedTasks,
            target: 30,
            icon: Icons.star_outline,
          ),
        ];
    final period =
        int.tryParse(value('analyticsDays', screen == D.an06 ? '30' : '7')) ??
        7;
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: period - 1));
    final filtered = done
        .where(
          (s) =>
              s.date('completedAt') != null &&
              !s.date('completedAt')!.isBefore(start),
        )
        .toList();
    final minutes = filtered.fold<int>(
      0,
      (total, s) => total + s.number('actualMinutes'),
    );
    final daily = List.generate(period, (i) {
      final date = start.add(Duration(days: i));
      return screen == D.an03
          ? data
                .items('tasks')
                .where(
                  (t) =>
                      t.flag('completed') &&
                      t.date('completedAt') != null &&
                      sameDay(t.date('completedAt')!, date),
                )
                .length
          : filtered
                .where((s) => sameDay(s.date('completedAt')!, date))
                .fold<int>(0, (total, s) => total + s.number('actualMinutes'));
    });
    Widget chart() => KCard([
      bold(screen == D.an03 ? 'Việc hoàn thành mỗi ngày' : 'Phút học mỗi ngày'),
      gap(16),
      SizedBox(
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < daily.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (daily.length <= 7) T('${daily[i]}', size: 10),
                      gap(4),
                      Container(
                        height: daily.every((v) => v == 0)
                            ? 2
                            : (daily[i] /
                                      daily.reduce((a, b) => a > b ? a : b) *
                                      95)
                                  .clamp(2, 95)
                                  .toDouble(),
                        decoration: BoxDecoration(
                          color: green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      gap(8),
                      T('${start.add(Duration(days: i)).day}', size: 9),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ]);
    if (screen == D.an08) {
      return [
        for (var i = 0; i < badges.length; i++)
          row(
            badges[i].name,
            '${badges[i].description}\n${badges[i].count}/${badges[i].target} · ${badges[i].count >= badges[i].target ? 'Đã đạt' : 'Chưa đạt'}',
            badges[i].icon,
            () {
              draft['badgeIndex'] = i;
              go(D.an09);
            },
          ),
      ];
    }
    if (screen == D.an09) {
      final b =
          badges[(draft['badgeIndex'] as int? ?? 0).clamp(
            0,
            badges.length - 1,
          )];
      return [
        Icon(b.icon, size: 100, color: green),
        bold(b.name, 24),
        T(b.description),
        LinearProgressIndicator(value: (b.count / b.target).clamp(0, 1)),
        T(
          '${b.count}/${b.target} · ${b.count >= b.target ? 'Đã đạt' : 'Tiếp tục cố gắng'}',
        ),
        const T(
          'Huy hiệu được tính từ kết quả học tập đã lưu của tài khoản.',
          color: muted,
        ),
      ];
    }
    if (screen == D.an07) {
      return [
        const Icon(Icons.local_fire_department, size: 80, color: Colors.orange),
        T(
          '${data.streak} ngày',
          size: 30,
          center: true,
          weight: FontWeight.w700,
        ),
        const T(
          'Chuỗi ngày liên tiếp có buổi học hoàn thành.',
          center: true,
          color: muted,
        ),
        KCard([
          heading('30 ngày gần đây'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 29; i >= 0; i--)
                Container(
                  width: 38,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        done.any(
                          (s) =>
                              s.date('completedAt') != null &&
                              sameDay(
                                s.date('completedAt')!,
                                now.subtract(Duration(days: i)),
                              ),
                        )
                        ? pale
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: T(
                    '${now.subtract(Duration(days: i)).day}',
                    color: dark,
                  ),
                ),
            ],
          ),
        ]),
        action(
          'Xem huy hiệu',
          () => go(D.an08),
          icon: Icons.military_tech_outlined,
        ),
      ];
    }
    return [
      if (screen == D.an01 || screen == D.hm05)
        hero(
          Icons.insights,
          'Tiến độ học tập',
          '${data.sessions.length} buổi đã lên lịch',
          trailing: KRing(data.progress, size: 64, stroke: 7, labelSize: 15),
        ),
      Wrap(
        spacing: 8,
        children: [
          for (final days in [7, 30])
            ChoiceChip(
              label: Text('$days ngày'),
              selected: period == days,
              onSelected: (_) =>
                  changed(() => draft['analyticsDays'] = '$days'),
            ),
        ],
      ),
      plannerStats([
        (Icons.schedule, '${minutes ~/ 60}h ${minutes % 60}m', 'Thời gian học'),
        (Icons.event_available, '${filtered.length}', 'Buổi hoàn thành'),
      ]),
      if (screen == D.an03)
        KCard([
          bold('Thống kê việc cần làm'),
          T(
            '${data.completedTasks}/${data.items('tasks').length} việc đã hoàn thành',
          ),
          gap(12),
          LinearProgressIndicator(
            value: data.items('tasks').isEmpty
                ? 0
                : data.completedTasks / data.items('tasks').length,
          ),
        ]),
      if (screen != D.an04) chart(),
      heading('Phân bổ theo môn · toàn bộ thời gian'),
      if (subjectMinutes.isEmpty)
        empty(
          'Chưa có dữ liệu học tập. Hoàn thành một buổi học để xem thống kê.',
        ),
      for (final e in subjectMinutes.entries)
        KCard([
          KRow([
            iconBox(Icons.menu_book_outlined, size: 36, radius: 12),
            Expanded(child: T(e.key, weight: FontWeight.w600)),
            T('${e.value ~/ 60}h ${e.value % 60}m'),
          ], gap: 10),
          gap(10),
          LinearProgressIndicator(
            value: data.totalMinutes == 0 ? 0 : e.value / data.totalMinutes,
          ),
        ]),
      if (screen == D.an01 || screen == D.hm05) ...[
        for (final a in [
          ('Theo thời gian học', D.an02, Icons.timer_outlined),
          ('Theo nhiệm vụ', D.an03, Icons.task_alt),
          ('Theo môn', D.an04, Icons.auto_stories_outlined),
          ('Biểu đồ tuần', D.an05, Icons.bar_chart),
          ('Biểu đồ tháng', D.an06, Icons.calendar_month),
          ('Chuỗi học tập', D.an07, Icons.local_fire_department_outlined),
          ('Huy hiệu', D.an08, Icons.military_tech_outlined),
        ])
          row(a.$1, '', a.$3, () => go(a.$2)),
      ],
    ];
  }
}
