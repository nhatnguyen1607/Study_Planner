import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_flutter/services/ai_schedule_repository.dart';
import 'package:study_planner_flutter/viewmodel/ai_schedule_view_model.dart';

class FakeAi implements AiScheduleRepository {
  int confirmed = 0;
  @override
  Future<Map<String, dynamic>> generate(
    List<String> subjects,
    int hours, {
    String objective = "",
  }) async => {'draftId': 'draft', 'sessions': []};
  @override
  Future<String> confirm(String id, DateTime start, {int weeks = 4}) async {
    confirmed++;
    return id;
  }
}

void main() {
  test('Validate input and confirm the same AI draft once', () async {
    final repo = FakeAi(), vm = AiScheduleViewModel(FakeAi());
    vm.dispose();
    final data = AiScheduleViewModel(repo);
    await data.generate('', '99');
    expect(data.error, isNotNull);
    expect(data.draft, isNull);
    await data.generate('Toán, Python', '9');
    expect(data.error, isNull);
    expect(data.draft?['draftId'], 'draft');
    await data.save();
    await data.save();
    expect(repo.confirmed, 1);
    expect(data.savedPlanId, 'draft');
    data.dispose();
  });
}
