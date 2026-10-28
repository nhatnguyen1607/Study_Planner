part of 'database_frame.dart';

extension _RestoredGoals on _DatabaseFrameState {
  void newGoal() {
    for (final key in draft.keys.where((k) => k.startsWith('goal')).toList()) {
      draft.remove(key);
    }
    draft.remove('milestones');
    go(D.go02);
  }

  List<Widget> restoredGoalsBody() {
    final goal = data.goal;
    switch (screen) {
      case D.go01:
        final goals = data
            .items('goals')
            .where(
              (g) =>
                  goalsFilter == 0 ||
                  (goalPercent(g) >= 100) == (goalsFilter == 2),
            )
            .toList();
        return [
          segments(
            ['Tất cả', 'Đang thực hiện', 'Hoàn thành'],
            goalsFilter,
            (i) => changed(() => goalsFilter = i),
          ),
          action('Tạo mục tiêu mới', newGoal, icon: Icons.add),
          if (goals.isEmpty)
            mascotTip(
              'Mục tiêu nhỏ, tiến bộ lớn',
              'Đặt một mục tiêu để bắt đầu hành trình của bạn.',
              pose: 'goals_new_seed',
            ),
          for (final g in goals)
            KCard(
              [
                KRow([
                  iconBox(
                    Icons.track_changes,
                    size: 46,
                    radius: 13,
                    color: Colors.white,
                    bg: green,
                  ),
                  Expanded(
                    child: KColumn([
                      T(g.text('title'), size: 15, weight: FontWeight.w600),
                      gap(5),
                      T(g.text('category'), size: 12, color: muted),
                    ]),
                  ),
                  KRing(
                    goalPercent(g).round(),
                    size: 62,
                    stroke: 7,
                    labelSize: 14,
                  ),
                ], gap: 14),
              ],
              onTap: () {
                data.select('goals', g.id);
                go(D.go08);
              },
            ),
        ];
      case D.go02:
        return [
          const Center(child: StudyMascot(pose: 'goals_new_seed', size: 150)),
          const T(
            'Bắt đầu một mục tiêu mới',
            size: 21,
            weight: FontWeight.w700,
            center: true,
          ),
          const T(
            'Chia nhỏ mục tiêu, tiến bộ từng ngày cùng bạn.',
            color: muted,
            size: 13,
            center: true,
          ),
          field('goalTitle', 'Tên mục tiêu', max: 120),
          field('goalDescription', 'Mô tả (tùy chọn)', lines: 3, max: 1000),
        ];
      case D.go03:
        return [
          const T(
            'Chọn danh mục phù hợp với mục tiêu của bạn',
            color: muted,
            size: 13,
          ),
          for (final category in [
            ('Tiếng Anh', 'TOEIC, IELTS, giao tiếp', Icons.translate, 0),
            ('Toán học', 'Đại học, phổ thông', Icons.functions, 3),
            ('Lập trình', 'Python, Web, Data', Icons.code, 2),
            (
              'Kiến thức chuyên ngành',
              'Kiến thức và nghiên cứu',
              Icons.menu_book_outlined,
              1,
            ),
            ('Kỹ năng', 'Giao tiếp, tư duy', Icons.bar_chart, 4),
            (
              'Chứng chỉ',
              'MOS, tin học, chứng chỉ',
              Icons.workspace_premium_outlined,
              6,
            ),
            ('Khác', 'Mục tiêu của riêng bạn', Icons.more_horiz, 5),
          ])
            KCard(
              [
                KRow([
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: subjectPalette[category.$4].withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.$3,
                      color: subjectPalette[category.$4],
                    ),
                  ),
                  Expanded(
                    child: KColumn([
                      bold(category.$1, 14),
                      T(category.$2, size: 12, color: muted),
                    ]),
                  ),
                  Icon(
                    value('goalCategory', 'Khác') == category.$1
                        ? Icons.check_circle
                        : Icons.chevron_right,
                    color: green,
                    size: 22,
                  ),
                ], gap: 12),
              ],
              onTap: () => changed(() => draft['goalCategory'] = category.$1),
              padding: 13,
            ),
        ];
      case D.go04:
        return [
          const Align(
            alignment: Alignment.centerRight,
            child: StudyMascot(pose: 'goals_target', size: 110),
          ),
          const T(
            'Đặt những chỉ tiêu rõ ràng để dễ theo dõi tiến độ.',
            size: 13,
            color: muted,
          ),
          field(
            'goalTarget',
            'Chỉ tiêu đạt được',
            initial: '100',
            numeric: true,
          ),
          field('goalUnit', 'Đơn vị', initial: 'đơn vị', max: 80),
          KRow([
            Expanded(
              child: field(
                'goalCurrent',
                'Mốc hiện tại',
                initial: '0',
                numeric: true,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Icon(Icons.arrow_forward, color: muted),
            ),
            Expanded(
              child: KColumn([
                const T('Mục tiêu', size: 13, weight: FontWeight.w600),
                gap(8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: light,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: T(
                    value('goalTarget', '100'),
                    weight: FontWeight.w600,
                    color: dark,
                  ),
                ),
              ]),
            ),
          ], gap: 16),
          mascotTip(
            'Đi từng bước nhỏ',
            'Chọn chỉ tiêu cao hơn mốc hiện tại, phù hợp với thời gian bạn có.',
            pose: 'sprout_watering',
          ),
        ];
      case D.go05:
        final end =
            DateTime.tryParse(value('goalDeadline')) ??
            DateTime.now().add(const Duration(days: 180));
        return [
          const T(
            'Khi nào bạn muốn đạt được mục tiêu này?',
            size: 13,
            color: muted,
          ),
          for (final option in [
            (30, '1 tháng', 'Phù hợp cho mục tiêu nhỏ'),
            (90, '3 tháng', 'Từng bước thấy sự thay đổi'),
            (180, '6 tháng', 'Dành thời gian để tiến bộ'),
            (365, '1 năm', 'Cho mục tiêu dài hạn'),
          ])
            selectRow(
              Icons.calendar_today_outlined,
              option.$2,
              option.$3,
              selected: (draft['goalDays'] as int? ?? 180) == option.$1,
              tap: () => changed(() {
                draft['goalDays'] = option.$1;
                draft['goalDeadline'] = DateTime.now()
                    .add(Duration(days: option.$1))
                    .toIso8601String();
              }),
            ),
          row(
            'Ngày hoàn thành',
            dateLabel(end),
            Icons.calendar_month_outlined,
            () => chooseDate('goalDeadline', current: end),
          ),
        ];
      case D.go06:
        final milestones =
            (draft['milestones'] as List<Map<String, dynamic>>?) ?? [];
        return [
          const T(
            'Chia nhỏ mục tiêu thành các giai đoạn để dễ dàng theo dõi.',
            color: muted,
            size: 13,
          ),
          if (milestones.isEmpty)
            mascotTip(
              'Bước nhỏ đầu tiên',
              'Thêm các cột mốc bạn muốn hoàn thành trên hành trình.',
              pose: 'goals_roadmap',
            ),
          for (var i = 0; i < milestones.length; i++)
            KCard([
              KRow([
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: green,
                    shape: BoxShape.circle,
                  ),
                  child: T(
                    '${i + 1}',
                    color: Colors.white,
                    weight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: KColumn([
                    bold(milestones[i]['title'] as String, 14),
                    T(
                      milestones[i]['notes'] as String? ?? '',
                      size: 12,
                      color: muted,
                    ),
                  ]),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Tùy chọn cột mốc',
                  onSelected: (choice) => changed(() {
                    final list = List<Map<String, dynamic>>.of(milestones);
                    if (choice == 'up' && i > 0) {
                      final item = list.removeAt(i);
                      list.insert(i - 1, item);
                    }
                    if (choice == 'remove') list.removeAt(i);
                    draft['milestones'] = list;
                  }),
                  itemBuilder: (_) => [
                    if (i > 0)
                      const PopupMenuItem(
                        value: 'up',
                        child: Text('Di chuyển lên'),
                      ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Xóa cột mốc'),
                    ),
                  ],
                  icon: const Icon(Icons.drag_handle, color: muted),
                ),
              ], gap: 12),
            ]),
          FigmaButton(
            'Thêm cột mốc',
            secondary: true,
            onTap: addMilestone,
            icon: Icons.add,
          ),
        ];
      case D.go07:
        return [
          const T(
            'Kiểm tra lại thông tin trước khi tạo.',
            size: 13,
            color: muted,
          ),
          KCard([
            KRow([
              iconBox(
                Icons.track_changes,
                size: 54,
                radius: 27,
                color: Colors.white,
                bg: green,
              ),
              Expanded(
                child: KColumn([
                  bold(value('goalTitle'), 18),
                  T(value('goalCategory', 'Khác'), size: 13, color: muted),
                ]),
              ),
            ], gap: 12),
            gap(18),
            T(value('goalDescription'), size: 13, color: muted),
            gap(14),
            plannerDetail(
              Icons.flag_outlined,
              'Chỉ tiêu',
              '${value('goalTarget', '100')} ${value('goalUnit', 'đơn vị')}',
            ),
            plannerDetail(
              Icons.insights,
              'Mốc hiện tại',
              value('goalCurrent', '0'),
            ),
            plannerDetail(
              Icons.calendar_month_outlined,
              'Thời hạn',
              dateLabel(
                DateTime.tryParse(value('goalDeadline')) ??
                    DateTime.now().add(const Duration(days: 180)),
              ),
            ),
            plannerDetail(
              Icons.route_outlined,
              'Cột mốc',
              '${((draft['milestones'] as List?) ?? []).length} cột mốc',
            ),
          ]),
          heading('Các cột mốc chính'),
          for (final milestone
              in ((draft['milestones'] as List<Map<String, dynamic>>?) ?? [])
                  .take(3))
            KRow([
              const Icon(Icons.flag_outlined, color: green, size: 21),
              Expanded(child: T(milestone['title'] as String, size: 14)),
            ], gap: 12),
          const Align(
            alignment: Alignment.centerRight,
            child: StudyMascot(pose: 'goals_roadmap', size: 96),
          ),
        ];
      case D.go08:
      case D.go09:
      case D.go10:
        if (goal == null) {
          return [
            empty('Chọn mục tiêu để xem chi tiết.'),
            action('Danh sách mục tiêu', () => go(D.go01)),
          ];
        }
        final progress = goalPercent(goal).round();
        if (screen == D.go10) {
          return [
            const Center(
              child: StudyMascot(pose: 'goals_celebrate', size: 150),
            ),
            T(
              progress >= 100 ? 'Chúc mừng bạn!' : 'Nhìn lại hành trình',
              size: 24,
              center: true,
              weight: FontWeight.w700,
              color: dark,
            ),
            T(goal.text('title'), size: 15, center: true),
            plannerStats([
              (Icons.flag_outlined, '${goal.data['baseline']}', 'Mốc ban đầu'),
              (Icons.track_changes, '${goal.data['target']}', 'Mục tiêu'),
              (Icons.check_circle_outline, '$progress%', 'Hoàn thành'),
            ]),
            heading('Cảm nhận của bạn'),
            stars(vm.rating, vm.setRating),
            field(
              'goalReflection_${goal.id}',
              'Ghi chú',
              initial: goal.text('notes'),
              lines: 3,
              max: 2000,
            ),
            action('Hoàn tất', () async {
              if (await data.save('goals', goal.id, {
                    'rating': vm.rating,
                    'notes': value(
                      'goalReflection_${goal.id}',
                      goal.text('notes'),
                    ),
                  }, existing: goal) &&
                  mounted) {
                go(D.go01);
              }
            }),
          ];
        }
        final summary = KCard([
          KRow([
            iconBox(
              Icons.track_changes,
              size: 52,
              radius: 26,
              bg: green,
              color: Colors.white,
            ),
            Expanded(
              child: KColumn([
                bold(goal.text('title'), 17),
                T(
                  'Đến ${dateLabel(goal.date('deadline')!)}',
                  size: 12,
                  color: muted,
                ),
              ]),
            ),
          ], gap: 13),
          gap(18),
          KRow([
            Expanded(
              child: KColumn([
                T(
                  '${goal.data['current']}',
                  center: true,
                  size: 20,
                  weight: FontWeight.w600,
                ),
                const T('Mốc hiện tại', size: 11, color: muted, center: true),
              ]),
            ),
            KRing(progress, size: 90, stroke: 9, labelSize: 20),
            Expanded(
              child: KColumn([
                T(
                  '${goal.data['target']}',
                  center: true,
                  size: 20,
                  weight: FontWeight.w600,
                ),
                const T('Mục tiêu', size: 11, color: muted, center: true),
              ]),
            ),
          ], gap: 8),
          gap(16),
          mascotTip(
            progress >= 100 ? 'Bạn đã đạt mục tiêu!' : 'Tiếp tục từng bước nhé',
            goal.text('unit'),
            pose: 'sprout_watering',
          ),
        ]);
        if (screen == D.go09) {
          return [
            segments(
              ['Hôm nay', 'Tuần', 'Tháng'],
              detailTab,
              (i) => changed(() => detailTab = i),
            ),
            heading('Tiến độ tổng thể'),
            summary,
            heading('Cập nhật mới'),
            row(
              'Cập nhật tiến độ',
              '${goal.data['current']} / ${goal.data['target']} ${goal.text('unit')}',
              Icons.trending_up,
              () => updateGoal(goal),
            ),
            if (goal.text('notes').isNotEmpty)
              KCard([T(goal.text('notes'), size: 13)]),
            if (progress >= 100) action('Đánh giá mục tiêu', () => go(D.go10)),
          ];
        }
        return [
          summary,
          segments(
            ['Cột mốc', 'Thống kê', 'Ghi chú'],
            detailTab,
            (i) => changed(() => detailTab = i),
          ),
          if (detailTab == 0) ...[
            for (final milestone in goal.maps('milestones'))
              KCard([
                KRow([
                  Checkbox(
                    value: milestone['completed'] == true,
                    onChanged: data.busy
                        ? null
                        : (done) {
                            final milestones = goal.maps('milestones');
                            for (final item in milestones) {
                              if (item['id'] == milestone['id']) {
                                item['completed'] = done;
                              }
                            }
                            data.save('goals', goal.id, {
                              'milestones': milestones,
                            }, existing: goal);
                          },
                  ),
                  Expanded(
                    child: KColumn([
                      bold(milestone['title'] as String, 14),
                      T(
                        milestone['notes'] as String? ?? '',
                        size: 12,
                        color: muted,
                      ),
                    ]),
                  ),
                ], gap: 8),
              ], padding: 10),
            if (goal.maps('milestones').isEmpty)
              const T('Chưa có cột mốc.', color: muted),
          ] else if (detailTab == 1)
            KCard([
              T('$progress% mục tiêu đã hoàn thành', weight: FontWeight.w600),
              gap(14),
              LinearProgressIndicator(value: progress / 100, minHeight: 9),
              gap(12),
              T(
                '${goal.maps('milestones').where((m) => m['completed'] == true).length}/${goal.maps('milestones').length} cột mốc đã hoàn thành',
                size: 13,
                color: muted,
              ),
            ])
          else
            KCard([
              T(
                goal.text('notes').isEmpty
                    ? 'Chưa có ghi chú.'
                    : goal.text('notes'),
                size: 14,
              ),
            ]),
          action('Cập nhật tiến độ', () => go(D.go09)),
        ];
      default:
        return [];
    }
  }
}
