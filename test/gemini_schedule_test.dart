import 'dart:async';
import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:study_planner_flutter/model/generated_study_plan.dart';
import 'package:study_planner_flutter/model/study_record.dart';
import 'package:study_planner_flutter/services/gemini_client.dart';
import 'package:study_planner_flutter/services/ai_schedule_repository.dart';
import 'package:study_planner_flutter/services/study_database.dart';
import 'package:study_planner_flutter/viewmodel/ai_schedule_view_model.dart';

Map<String, dynamic> sample() => {
  'title': 'Kế hoạch ôn Toán',
  'objective': 'Nắm vững kiến thức cơ bản.',
  'sessions': [
    {
      'subject': 'Toán',
      'day': 0,
      'startMinute': 420,
      'durationMinutes': 60,
      'topic': 'Ôn lý thuyết',
      'notes': 'Đọc và giải 3 bài.',
    },
  ],
};
http.Response response(Map<String, dynamic> plan, {String finish = 'STOP'}) =>
    http.Response.bytes(
      utf8.encode(
        jsonEncode({
          'candidates': [
            {
              'finishReason': finish,
              'content': {
                'parts': [
                  {'text': jsonEncode(plan)},
                ],
              },
            },
          ],
        }),
      ),
      200,
    );
void main() {
  test('Gemini REST sends structured schema and header; preserves Vietnamese', () async {
    final client = GeminiClient(
      apiKey: 'test-key',
      client: MockClient((request) async {
        expect(request.url.host, 'generativelanguage.googleapis.com');
        expect(request.url.queryParameters, isEmpty);
        expect(request.headers['x-goog-api-key'], 'test-key');
        final body = jsonDecode(request.body) as Map;
        expect(
          body['generationConfig']['responseFormat']['text']['schema']['properties']['sessions']['maxItems'],
          28,
        );
        expect(request.body, contains('Mục tiêu'));
        return response(sample());
      }),
    );
    final plan = await client.generate(['Toán'], 2, objective: 'Mục tiêu');
    expect(plan.title, 'Kế hoạch ôn Toán');
    expect(plan.weeklyMinutes, 60);
    client.close();
  });
  test(
    'Reject overlap, missing subjects, wrong types and excessive budget',
    () {
      final plan = sample(), slot = (plan['sessions'] as List).first as Map;
      expect(
        () => GeneratedStudyPlan.parse(
          {
            ...plan,
            'sessions': [
              slot,
              {...slot, 'startMinute': 430},
            ],
          },
          ['Toán'],
          2,
        ),
        throwsA(isA<GeminiFailure>()),
      );
      expect(
        () => GeneratedStudyPlan.parse(plan, ['Toán', 'Anh'], 2),
        throwsA(isA<GeminiFailure>()),
      );
      expect(
        () => GeneratedStudyPlan.parse(
          {
            ...plan,
            'sessions': [
              {...slot, 'durationMinutes': 90},
            ],
          },
          ['Toán'],
          1,
        ),
        throwsA(isA<GeminiFailure>()),
      );
      expect(
        () => GeneratedStudyPlan.parse(
          {
            ...plan,
            'sessions': [
              {...slot, 'day': 8},
            ],
          },
          ['Toán'],
          2,
        ),
        throwsA(isA<GeminiFailure>()),
      );
    },
  );
  test(
    'Quota, missing key and incomplete JSON do not leak provider payload',
    () async {
      final client = GeminiClient(
        apiKey: 'do-not-log',
        client: MockClient(
          (_) async =>
              http.Response('do-not-log private provider content', 429),
        ),
      );
      await expectLater(
        client.generate(['Toán'], 1),
        throwsA(
          isA<GeminiFailure>()
              .having((e) => e.code, 'code', 'http-429')
              .having(
                (e) => e.message.contains('do-not-log'),
                'no-secret',
                false,
              ),
        ),
      );
      final missing = GeminiClient(
        apiKey: '',
        client: MockClient((_) async => throw StateError('must not call')),
      );
      await expectLater(
        missing.generate(['Toán'], 1),
        throwsA(
          isA<GeminiFailure>().having((e) => e.code, 'code', 'missing-key'),
        ),
      );
      final incomplete = GeminiClient(
        apiKey: 'test',
        client: MockClient(
          (_) async => response(sample(), finish: 'MAX_TOKENS'),
        ),
      );
      await expectLater(
        incomplete.generate(['Toán'], 1),
        throwsA(
          isA<GeminiFailure>().having((e) => e.code, 'code', 'incomplete'),
        ),
      );
    },
  );
  test('Generate alone never writes; confirm atomically saves a UID plan and dated sessions once', () async {
    final store = FakeFirebaseFirestore();
    final database = StudyDatabase('alice', firestore: store);
    final client = GeminiClient(
      apiKey: 'test',
      client: MockClient((_) async => response(sample())),
    );
    final repo = FirebaseAiScheduleRepository(
      database: database,
      client: client,
      currentUid: () => 'alice',
    );
    final draft = await repo.generate(['Toán'], 1);
    expect(await database.watch('plans').first, isEmpty);
    final start = DateTime.now().add(const Duration(days: 7));
    final id = await repo.confirm(draft['draftId'] as String, start);
    await repo.confirm(id, start);
    final plans = await database.watch('plans').first,
        sessions = await database.watch('sessions').first;
    expect(plans.length, 1);
    expect(plans.single.text('source'), 'gemini');
    expect(plans.single.text('objective'), sample()['objective']);
    expect(sessions.length, 4);
    expect(
      sessions.every(
        (s) => s.text('ownerId') == 'alice' && s.text('planId') == id,
      ),
      true,
    );
    expect(sessions.first.text('notes'), 'Đọc và giải 3 bài.');
    expect(
      await StudyDatabase('bob', firestore: store).watch('plans').first,
      isEmpty,
    );
    repo.close();
  });
  test('Existing sessions prevent saving an overlapping Gemini plan', () async {
    final database = StudyDatabase('alice', firestore: FakeFirebaseFirestore());
    final repo = FirebaseAiScheduleRepository(
      database: database,
      client: GeminiClient(
        apiKey: 'test',
        client: MockClient((_) async => response(sample())),
      ),
      currentUid: () => 'alice',
    );
    final start = DateTime.now().add(const Duration(days: 7));
    final first = await repo.generate(['Toán'], 1);
    await repo.confirm(first['draftId'] as String, start);
    final second = await repo.generate(['Toán'], 1);
    await expectLater(
      repo.confirm(second['draftId'] as String, start),
      throwsA(isA<DataFailure>().having((e) => e.code, 'code', 'overlap')),
    );
    expect((await database.watch('plans').first).length, 1);
    repo.close();
  });
  test('Switching UID while Gemini is pending discards response; cannot save another user draft', () async {
    var uid = 'alice';
    final gate = Completer<http.Response>();
    final db = StudyDatabase('alice', firestore: FakeFirebaseFirestore());
    final repo = FirebaseAiScheduleRepository(
      database: db,
      currentUid: () => uid,
      client: GeminiClient(
        apiKey: 'test',
        client: MockClient((_) => gate.future),
      ),
    );
    final pending = repo.generate(['Toán'], 1);
    uid = 'bob';
    gate.complete(response(sample()));
    await expectLater(
      pending,
      throwsA(
        isA<DataFailure>().having((e) => e.code, 'code', 'session-changed'),
      ),
    );
    expect(await db.watch('plans').first, isEmpty);
    repo.close();
  });
  test(
    'Save errors retain draft for retry without another Gemini request',
    () async {
      var calls = 0;
      final date = DateTime.now().add(const Duration(days: 7));
      final database = RejectOnceDatabase();
      final client = GeminiClient(
        apiKey: 'test',
        client: MockClient((_) async {
          calls++;
          return response(sample());
        }),
      );
      final repo = FirebaseAiScheduleRepository(
        database: database,
        client: client,
        currentUid: () => 'alice',
      );
      final state = AiScheduleViewModel(repo)..setStart(date);
      await state.generate('Toán', '1');
      expect(state.draft, isNotNull);
      await state.save();
      expect(state.error, isNotNull);
      expect(state.draft, isNotNull);
      await state.save();
      expect(calls, 1);
      expect(state.savedPlanId, isNotNull);
      state.dispose();
    },
  );
}

class RejectOnceDatabase extends StudyDatabase {
  RejectOnceDatabase() : super('alice', firestore: FakeFirebaseFirestore());
  bool reject = true;
  @override
  Future<void> saveCalendar({
    StudyRecord? plan,
    required List<StudyRecord> sessions,
    StudyRecord? existingPlan,
  }) async {
    if (reject) {
      reject = false;
      throw const DataFailure('test-failure', 'Thử lưu lại');
    }
    await super.saveCalendar(
      plan: plan,
      sessions: sessions,
      existingPlan: existingPlan,
    );
  }
}
