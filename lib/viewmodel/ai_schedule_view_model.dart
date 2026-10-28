import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

import '../services/ai_schedule_repository.dart';
import '../services/gemini_client.dart';
import '../model/generated_study_plan.dart';
import '../model/study_record.dart';

class AiScheduleViewModel extends ChangeNotifier {
  AiScheduleViewModel(this.repository);
  final AiScheduleRepository repository;
  Map<String, dynamic>? draft;
  DateTime start = DateTime.now().add(const Duration(days: 1));
  int weeks = 4;
  String? error, savedPlanId;
  bool busy = false, _disposed = false;
  void emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> run(Future<void> Function() action) async {
    if (busy || _disposed) return;
    busy = true;
    error = null;
    emit();
    try {
      await action();
    } on GeminiFailure catch (e) {
      error = e.toString();
    } on DataFailure catch (e) {
      error = e.toString();
    } on FirebaseException catch (e) {
      error =
          'Không lưu được vào Firestore [${e.code}]. Có thể thử lưu lại mà không gọi Gemini lại.';
    } catch (_) {
      error = 'Không thể xử lý kế hoạch. Kiểm tra kết nối rồi thử lại.';
    } finally {
      busy = false;
      emit();
    }
  }

  Future<void> generate(
    String names,
    String amount, {
    String objective = '',
  }) async {
    if (busy || _disposed) return;
    final subjects = names
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    final hours = int.tryParse(amount);
    try {
      GeminiClient.validateInput(subjects, hours ?? 0, objective.trim());
    } on GeminiFailure catch (e) {
      error = e.toString();
      emit();
      return;
    }
    await run(() async {
      draft = null;
      savedPlanId = null;
      final result = await repository.generate(
        subjects,
        hours!,
        objective: objective.trim(),
      );
      if (!_disposed) draft = result;
    });
  }

  Future<void> save() async {
    if (busy || draft == null || savedPlanId != null) return;
    await run(() async {
      final id = await repository.confirm(
        draft!['draftId'] as String,
        start,
        weeks: weeks,
      );
      if (!_disposed) savedPlanId = id;
    });
  }

  void invalidate() {
    if (busy) return;
    draft = null;
    savedPlanId = null;
    error = null;
    emit();
  }

  void setStart(DateTime date) {
    if (busy || savedPlanId != null) return;
    start = date;
    emit();
  }

  void setWeeks(int value) {
    if (busy || savedPlanId != null || value < 1 || value > 12) return;
    weeks = value;
    emit();
  }

  @override
  void dispose() {
    _disposed = true;
    draft = null;
    if (repository is FirebaseAiScheduleRepository) {
      (repository as FirebaseAiScheduleRepository).close();
    }
    super.dispose();
  }
}
