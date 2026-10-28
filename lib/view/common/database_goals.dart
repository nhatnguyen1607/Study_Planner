part of 'database_frame.dart';

extension _GoalFrames on _DatabaseFrameState {
  Future<void> saveGoal() async {
    final title = value('goalTitle').trim(),
        current = double.tryParse(value('goalCurrent', '0')),
        target = double.tryParse(value('goalTarget', '100'));
    final deadline =
        DateTime.tryParse(value('goalDeadline')) ??
        DateTime.now().add(const Duration(days: 180));
    if (title.isEmpty ||
        current == null ||
        target == null ||
        !current.isFinite ||
        !target.isFinite ||
        target <= current ||
        current < 0 ||
        !deadline.isAfter(DateTime.now())) {
      message(
        'Nhập tên, chỉ tiêu lớn hơn mức hiện tại và thời hạn trong tương lai.',
      );
      return;
    }
    final id = value('goalDraftId', data.repository.newId('goals'));
    draft['goalDraftId'] = id;
    final milestones =
        (draft['milestones'] as List<Map<String, dynamic>>?) ?? [];
    final ok = await data.save('goals', id, {
      'title': title,
      'description': value('goalDescription'),
      'category': value('goalCategory', 'Khác'),
      'unit': value('goalUnit', 'đơn vị'),
      'baseline': current,
      'target': target,
      'current': current,
      'deadline': Timestamp.fromDate(deadline),
      'milestones': milestones,
      'notes': '',
      'rating': 0,
      'archived': false,
    });
    if (ok && mounted) {
      data.selectedGoalId = id;
      draft.remove('goalDraftId');
      go(D.go08);
    }
  }

  double goalPercent(StudyRecord goal) {
    final baseline = (goal.data['baseline'] as num?)?.toDouble() ?? 0,
        target = (goal.data['target'] as num?)?.toDouble() ?? 100,
        current = (goal.data['current'] as num?)?.toDouble() ?? baseline;
    return target <= baseline
        ? 0
        : ((current - baseline) / (target - baseline) * 100).clamp(0, 100);
  }

  Future<void> addMilestone() async {
    await editData(
      context,
      title: 'Thêm cột mốc',
      fields: [
        const DataInput('title', 'Tên cột mốc', required: true, max: 120),
        const DataInput('notes', 'Mô tả', max: 500, lines: 2),
      ],
      save: (values) async {
        final milestones = List<Map<String, dynamic>>.of(
          (draft['milestones'] as List<Map<String, dynamic>>?) ?? [],
        );
        if (milestones.length >= 30) return 'Tối đa 30 cột mốc mỗi mục tiêu.';
        milestones.add({
          'id': data.repository.newId('goals'),
          'title': values['title'],
          'notes': values['notes'],
          'completed': false,
        });
        changed(() => draft['milestones'] = milestones);
        return null;
      },
    );
  }

  Future<void> updateGoal(StudyRecord goal) async {
    await editData(
      context,
      title: 'Cập nhật tiến độ',
      fields: [
        DataInput(
          'current',
          'Mức hiện tại (${goal.text('unit')})',
          value: '${goal.data['current']}',
          numeric: true,
          required: true,
        ),
        DataInput(
          'notes',
          'Ghi chú',
          value: goal.text('notes'),
          lines: 3,
          max: 2000,
        ),
      ],
      save: (values) async {
        final current = double.tryParse(values['current']!),
            baseline = (goal.data['baseline'] as num).toDouble(),
            target = (goal.data['target'] as num).toDouble();
        if (current == null ||
            !current.isFinite ||
            current < baseline ||
            current > target) {
          return 'Giá trị phải nằm trong khoảng $baseline đến $target.';
        }
        return await data.save('goals', goal.id, {
              'current': current,
              'notes': values['notes'],
            }, existing: goal)
            ? null
            : data.error;
      },
    );
  }

  List<Widget> goalsBody() {
    final goal = data.goal;
    switch (screen) {
      case D.go01:
        return [
          action('Tạo mục tiêu mới', () {
            for (final k
                in draft.keys.where((k) => k.startsWith('goal')).toList()) {
              draft.remove(k);
            }
            draft.remove('milestones');
            go(D.go02);
          }, icon: Icons.add),
          if (data.items('goals').isEmpty) empty('Chưa có mục tiêu học tập.'),
          for (final g in data.items('goals'))
            row(
              g.text('title'),
              '${g.text('category')} · ${g.date('deadline') == null ? '' : dateLabel(g.date('deadline')!)}',
              Icons.track_changes,
              () {
                data.select('goals', g.id);
                go(D.go08);
              },
              trailing: KRing(
                goalPercent(g).round(),
                size: 52,
                stroke: 6,
                labelSize: 12,
              ),
            ),
        ];
      case D.go02:
        return [
          Center(child: picture('sprout_books', height: 140, width: 140)),
          field('goalTitle', 'Tên mục tiêu', max: 120),
          field('goalDescription', 'Mô tả (tùy chọn)', lines: 3, max: 1000),
          action('Chọn loại mục tiêu', () {
            if (value('goalTitle').trim().isEmpty) {
              message('Nhập tên mục tiêu.');
              return;
            }
            go(D.go03);
          }),
        ];
      case D.go03:
        return [
          for (final category in [
            'Tiếng Anh',
            'Toán học',
            'Lập trình',
            'Kiến thức chuyên ngành',
            'Kỹ năng',
            'Chứng chỉ',
            'Khác',
          ])
            row(
              category,
              value('goalCategory', 'Khác') == category ? 'Đã chọn' : '',
              Icons.auto_stories,
              () => changed(() => draft['goalCategory'] = category),
            ),
          action('Đặt chỉ tiêu', () => go(D.go04)),
        ];
      case D.go04:
        return [
          field('goalCurrent', 'Mốc hiện tại', initial: '0', numeric: true),
          field(
            'goalTarget',
            'Chỉ tiêu đạt được',
            initial: '100',
            numeric: true,
          ),
          field('goalUnit', 'Đơn vị', initial: 'đơn vị', max: 80),
          action('Chọn thời hạn', () => go(D.go05)),
        ];
      case D.go05:
        final end =
            DateTime.tryParse(value('goalDeadline')) ??
            DateTime.now().add(const Duration(days: 180));
        return [
          row(
            'Ngày hoàn thành',
            dateLabel(end),
            Icons.calendar_month,
            () => chooseDate('goalDeadline', current: end),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final days in [30, 90, 180, 365])
                ActionChip(
                  label: Text('$days ngày'),
                  onPressed: () => changed(
                    () => draft['goalDeadline'] = DateTime.now()
                        .add(Duration(days: days))
                        .toIso8601String(),
                  ),
                ),
            ],
          ),
          action('Thiết lập cột mốc', () => go(D.go06)),
        ];
      case D.go06:
        return [
          for (final m
              in (draft['milestones'] as List<Map<String, dynamic>>?) ?? [])
            row(
              m['title'] as String,
              m['notes'] as String,
              Icons.flag_outlined,
              () => changed(() => (draft['milestones'] as List).remove(m)),
              trailing: const Icon(Icons.delete_outline, color: muted),
            ),
          action('Thêm cột mốc', addMilestone, icon: Icons.add),
          const T(
            'Cột mốc là tùy chọn. Chạm biểu tượng xóa để bỏ một cột mốc.',
            color: muted,
          ),
          action('Xem trước mục tiêu', () => go(D.go07)),
        ];
      case D.go07:
        return [
          hero(
            Icons.track_changes,
            value('goalTitle'),
            value('goalCategory', 'Khác'),
          ),
          KCard([
            T(value('goalDescription')),
            gap(12),
            T(
              '${value('goalCurrent', '0')} → ${value('goalTarget', '100')} ${value('goalUnit', 'đơn vị')}',
            ),
            gap(8),
            T(
              'Thời hạn: ${dateLabel(DateTime.tryParse(value('goalDeadline')) ?? DateTime.now().add(const Duration(days: 180)))}',
            ),
            gap(8),
            T('${((draft['milestones'] as List?) ?? []).length} cột mốc'),
          ]),
          action('Tạo mục tiêu', saveGoal),
        ];
      case D.go08:
      case D.go09:
      case D.go10:
        if (goal == null) {
          return [
            empty('Chọn mục tiêu để xem và cập nhật.'),
            action('Danh sách mục tiêu', () => go(D.go01)),
          ];
        }
        final percentage = goalPercent(goal).round();
        return [
          hero(
            Icons.track_changes,
            goal.text('title'),
            goal.text('category'),
            trailing: KRing(percentage, size: 68, stroke: 7, labelSize: 16),
          ),
          KCard([
            T(goal.text('description')),
            gap(8),
            bold(
              '${goal.data['current']} / ${goal.data['target']} ${goal.text('unit')}',
            ),
            gap(8),
            T('Thời hạn: ${dateLabel(goal.date('deadline')!)}'),
            if (goal.text('notes').isNotEmpty) ...[
              gap(12),
              T(goal.text('notes')),
            ],
          ]),
          if (screen == D.go08) ...[
            heading('Cột mốc'),
            if (goal.maps('milestones').isEmpty)
              const T('Chưa đặt cột mốc.', color: muted),
            for (final m in goal.maps('milestones'))
              CheckboxListTile(
                title: Text(m['title'] as String),
                subtitle: Text(m['notes'] as String? ?? ''),
                value: m['completed'] == true,
                onChanged: data.busy
                    ? null
                    : (v) {
                        final milestones = goal.maps('milestones');
                        for (final n in milestones) {
                          if (n['id'] == m['id']) n['completed'] = v;
                        }
                        data.save('goals', goal.id, {
                          'milestones': milestones,
                        }, existing: goal);
                      },
              ),
            action('Cập nhật tiến độ', () => go(D.go09)),
          ] else if (screen == D.go09) ...[
            action(
              'Nhập tiến độ mới',
              () => updateGoal(goal),
              icon: Icons.edit_outlined,
            ),
            if (percentage >= 100)
              action('Đánh giá mục tiêu', () => go(D.go10)),
          ] else ...[
            if (percentage < 100)
              const T('Mục tiêu chưa hoàn thành. Bạn vẫn có thể lưu cảm nhận.'),
            action('Lưu đánh giá', () async {
              await editData(
                context,
                title: 'Đánh giá mục tiêu',
                fields: [
                  DataInput(
                    'rating',
                    'Số sao (1–5)',
                    value:
                        '${goal.number('rating') == 0 ? 5 : goal.number('rating')}',
                    numeric: true,
                    required: true,
                  ),
                  DataInput(
                    'notes',
                    'Cảm nhận',
                    value: goal.text('notes'),
                    lines: 3,
                    max: 2000,
                  ),
                ],
                save: (v) async {
                  final stars = int.tryParse(v['rating']!);
                  if (stars == null || stars < 1 || stars > 5) {
                    return 'Chọn từ 1 đến 5 sao.';
                  }
                  return await data.save('goals', goal.id, {
                        'rating': stars,
                        'notes': v['notes'],
                      }, existing: goal)
                      ? null
                      : data.error;
                },
              );
            }),
          ],
          OutlinedButton(
            onPressed: () => go(D.go01),
            child: const Text('Danh sách mục tiêu'),
          ),
        ];
      default:
        return [];
    }
  }
}
