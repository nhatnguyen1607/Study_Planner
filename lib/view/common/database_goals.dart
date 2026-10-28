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

  List<Widget> goalsBody() => restoredGoalsBody();
}
