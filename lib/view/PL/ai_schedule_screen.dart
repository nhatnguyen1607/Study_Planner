import 'package:flutter/material.dart';

import '../../model/study_record.dart';
import '../../services/ai_schedule_repository.dart';
import '../../viewmodel/ai_schedule_view_model.dart';
import '../common/study_theme.dart';

class AiScheduleScreen extends StatefulWidget {
  const AiScheduleScreen({
    super.key,
    this.initialSubjects = 'Toán cao cấp, Tiếng Anh, Lập trình Python',
    this.initialHours = '9',
    this.initialObjective = '',
    this.viewModel,
  });
  final String initialSubjects, initialHours, initialObjective;
  final AiScheduleViewModel? viewModel;
  @override
  State<AiScheduleScreen> createState() => _AiScheduleScreenState();
}

class _AiScheduleScreenState extends State<AiScheduleScreen> {
  late final vm =
      widget.viewModel ?? AiScheduleViewModel(FirebaseAiScheduleRepository());
  late final subjects = TextEditingController(text: widget.initialSubjects),
      hours = TextEditingController(text: widget.initialHours),
      objective = TextEditingController(text: widget.initialObjective);
  @override
  void dispose() {
    if (widget.viewModel == null) vm.dispose();
    subjects.dispose();
    hours.dispose();
    objective.dispose();
    super.dispose();
  }

  String time(num n) =>
      '${(n.toInt() ~/ 60).toString().padLeft(2, '0')}:${(n.toInt() % 60).toString().padLeft(2, '0')}';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: vm,
    builder: (context, _) => PopScope(
      canPop: !vm.busy,
      child: Scaffold(
        backgroundColor: StudyColors.surface,
        appBar: AppBar(
          title: const Text('Kế hoạch với Gemini'),
          automaticallyImplyLeading: !vm.busy,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: subjects,
              enabled: !vm.busy,
              onChanged: (_) => vm.invalidate(),
              decoration: const InputDecoration(
                labelText: 'Môn học, ngăn cách bằng dấu phẩy',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hours,
              enabled: !vm.busy,
              onChanged: (_) => vm.invalidate(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quỹ giờ học mỗi tuần',
                prefixIcon: Icon(Icons.schedule),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: objective,
              enabled: !vm.busy,
              onChanged: (_) => vm.invalidate(),
              maxLines: 3,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Mục tiêu, trình độ và yêu cầu học tập',
                alignLabelWithHint: true,
              ),
            ),
            const Text(
              'Gemini đề xuất kế hoạch tuần gồm nội dung từng buổi. Bạn xem trước rồi xác nhận để lưu lịch theo ngày.',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: vm.busy || vm.savedPlanId != null
                  ? null
                  : () async {
                      final now = DateTime.now();
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: vm.start,
                        firstDate: DateTime(now.year, now.month, now.day),
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (selected != null) vm.setStart(selected);
                    },
              icon: const Icon(Icons.calendar_month),
              label: Text('Bắt đầu: ${dateLabel(vm.start)}'),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final count in [1, 2, 4, 8, 12])
                  ChoiceChip(
                    label: Text('$count tuần'),
                    selected: vm.weeks == count,
                    onSelected: vm.busy || vm.savedPlanId != null
                        ? null
                        : (_) => vm.setWeeks(count),
                  ),
              ],
            ),
            if (vm.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  vm.error!,
                  style: const TextStyle(color: StudyColors.danger),
                ),
              ),
            if (vm.busy)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              FilledButton.icon(
                onPressed: () => vm.generate(
                  subjects.text,
                  hours.text,
                  objective: objective.text,
                ),
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  vm.draft == null ? 'Tạo kế hoạch với Gemini' : 'Đề xuất lại',
                ),
              ),
            if (vm.draft != null) ...[
              const SizedBox(height: 20),
              Text(
                vm.draft!['title'] as String? ?? 'Bản xem trước',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(vm.draft!['objective'] as String? ?? ''),
              const SizedBox(height: 12),
              for (final raw in vm.draft!['sessions'] as List)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${raw['subject']} · ${raw['topic'] ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'][raw['day'] as int]} · ${time(raw['startMinute'] as num)} · ${raw['durationMinutes']} phút',
                        ),
                        if (raw['notes'] is String) ...[
                          const SizedBox(height: 8),
                          Text(raw['notes'] as String),
                        ],
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              if (vm.savedPlanId == null)
                FilledButton.icon(
                  onPressed: vm.busy ? null : vm.save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text('Xác nhận lưu lịch ${vm.weeks} tuần'),
                ),
              if (vm.savedPlanId != null)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Đã lưu kế hoạch và các buổi học. Quay lại Lịch để xem.',
                    style: TextStyle(color: StudyColors.green800),
                  ),
                ),
            ],
          ],
        ),
      ),
    ),
  );
}
