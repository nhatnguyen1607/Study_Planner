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

  List<Widget> homeBody() => restoredHomeBody();
}
