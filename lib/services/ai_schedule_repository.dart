import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/generated_study_plan.dart';
import '../model/study_record.dart';
import 'gemini_client.dart';
import 'study_database.dart';

abstract class AiScheduleRepository {
  Future<Map<String, dynamic>> generate(
    List<String> subjects,
    int hours, {
    String objective = '',
  });
  Future<String> confirm(String draftId, DateTime start, {int weeks = 4});
}

class _Draft {
  _Draft(this.plan, this.subjects, this.hours);
  final GeneratedStudyPlan plan;
  final List<String> subjects;
  final int hours;
}

/// REST Gemini + UID-scoped Firestore. No Cloud Functions or server secret needed.
class FirebaseAiScheduleRepository implements AiScheduleRepository {
  FirebaseAiScheduleRepository({
    StudyDatabase? database,
    GeminiClient? client,
    String? Function()? currentUid,
  }) : _database =
           database ??
           StudyDatabase(FirebaseAuth.instance.currentUser?.uid ?? ''),
       _currentUid =
           currentUid ?? (() => FirebaseAuth.instance.currentUser?.uid),
       _client =
           client ??
           GeminiClient(
             apiKey: _config('GEMINI_API_KEY'),
             model: _config('GEMINI_MODEL', fallback: 'gemini-3.5-flash-lite'),
           );
  final StudyDatabase _database;
  final String? Function() _currentUid;
  final GeminiClient _client;
  final Map<String, _Draft> _drafts = {};
  bool _closed = false;
  static String _config(String name, {String fallback = ''}) {
    final defined = name == 'GEMINI_API_KEY'
        ? const String.fromEnvironment('GEMINI_API_KEY')
        : const String.fromEnvironment('GEMINI_MODEL');
    if (defined.trim().isNotEmpty) return defined.trim();
    return (dotenv.isInitialized ? dotenv.env[name] : null)?.trim() ?? fallback;
  }

  void check() {
    if (_closed || _currentUid() != _database.uid) {
      throw const DataFailure(
        'session-changed',
        'Phiên đăng nhập đã thay đổi. Mở lại màn hình Gemini.',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> generate(
    List<String> subjects,
    int hours, {
    String objective = '',
  }) async {
    check();
    final plan = await _client.generate(subjects, hours, objective: objective);
    check();
    final id = _database.newId('plans');
    _drafts.clear();
    _drafts[id] = _Draft(plan, List.of(subjects), hours);
    return {'draftId': id, ...plan.toJson()};
  }

  @override
  Future<String> confirm(
    String draftId,
    DateTime start, {
    int weeks = 4,
  }) async {
    check();
    final draft = _drafts[draftId];
    if (draft == null) {
      throw const DataFailure(
        'draft-missing',
        'Không còn bản xem trước. Hãy tạo lại kế hoạch.',
      );
    }
    final first = DateTime(start.year, start.month, start.day),
        now = DateTime.now();
    if (weeks < 1 ||
        weeks > 12 ||
        first.isBefore(DateTime(now.year, now.month, now.day)) ||
        first.isAfter(now.add(const Duration(days: 366)))) {
      throw const DataFailure(
        'dates',
        'Chọn ngày bắt đầu từ hôm nay và thời lượng 1–12 tuần.',
      );
    }
    final end = DateTime(
      first.year,
      first.month,
      first.day + weeks * 7,
    ).subtract(const Duration(milliseconds: 1));
    final target = _database.collection('plans').doc(draftId);
    Future<bool> alreadySaved() async {
      final snap = await target
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 20));
      check();
      if (!snap.exists) return false;
      final plan = StudyRecord(snap.id, snap.data()!);
      if (plan.text('ownerId') != _database.uid ||
          plan.text('source') != 'gemini') {
        throw const DataFailure(
          'owner',
          'Bản ghi không thuộc kế hoạch Gemini hiện tại.',
        );
      }
      if (plan.date('startAt') != first || plan.date('endAt') != end) {
        throw const DataFailure(
          'already-saved',
          'Bản xem trước này đã được lưu với ngày/thời lượng khác. Xem trong danh sách kế hoạch.',
        );
      }
      return true;
    }

    if (await alreadySaved()) return draftId;
    final sessions = <StudyRecord>[];
    for (var offset = 0; offset < weeks * 7; offset++) {
      final day = DateTime(first.year, first.month, first.day + offset);
      for (var index = 0; index < draft.plan.sessions.length; index++) {
        final slot = draft.plan.sessions[index];
        if (slot.day != day.weekday - 1) continue;
        final begin = DateTime(
          day.year,
          day.month,
          day.day,
          slot.startMinute ~/ 60,
          slot.startMinute % 60,
        );
        sessions.add(
          StudyRecord('${draftId}_${offset}_$index', {
            'planId': draftId,
            'title': slot.topic,
            'subject': slot.subject,
            'startAt': Timestamp.fromDate(begin),
            'endAt': Timestamp.fromDate(
              begin.add(Duration(minutes: slot.durationMinutes)),
            ),
            'status': 'scheduled',
            'actualMinutes': 0,
            'rating': 0,
            'notes': slot.notes,
            'location': '',
            'materials': '',
            'checklist': <String>[],
            'completedItems': <String>[],
            'archived': false,
          }),
        );
      }
    }
    if (sessions.isEmpty || sessions.length > 350) {
      throw const DataFailure(
        'too-many',
        'Chọn ít tuần hơn để tổng số buổi không vượt 350.',
      );
    }
    final plan = StudyRecord(draftId, {
      'title': draft.plan.title,
      'objective': draft.plan.objective,
      'source': 'gemini',
      'status': 'active',
      'subjects': draft.subjects,
      'startAt': Timestamp.fromDate(first),
      'endAt': Timestamp.fromDate(end),
      'weeklyHours': draft.hours,
      'archived': false,
      'extensions': {
        'geminiModel': _client.model,
        'weeklyMinutes': draft.plan.weeklyMinutes,
        'weeks': weeks,
      },
    });
    check();
    try {
      await _database.saveCalendar(plan: plan, sessions: sessions);
    } on DataFailure {
      if (!await alreadySaved()) rethrow;
    }
    check();
    return draftId;
  }

  void close() {
    _closed = true;
    _drafts.clear();
    _client.close();
  }
}
