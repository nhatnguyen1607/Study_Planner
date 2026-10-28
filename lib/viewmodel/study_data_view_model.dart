import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../model/study_record.dart';
import '../services/study_database.dart';

class StudyDataViewModel extends ChangeNotifier {
  StudyDataViewModel(this.repository) {
    _listen();
  }
  void _listen() {
    _loadTimer?.cancel();
    _loadTimer = Timer(const Duration(seconds: 20), () {
      if (!ready && !_disposed) {
        errors['connection'] =
            'Chưa nhận được dữ liệu từ máy chủ. Kiểm tra kết nối rồi tải lại.';
        _emit();
      }
    });
    for (final kind in StudyDatabase.collections) {
      _subscriptions.add(
        repository
            .watch(kind)
            .listen(
              (items) {
                records[kind] = items;
                if (kind == 'settings' && !_draftLoaded) {
                  final editor = items
                      .where((r) => r.id == 'editor')
                      .firstOrNull;
                  if (editor?.data['values'] is Map) {
                    drafts.addAll(
                      Map<String, dynamic>.from(editor!.data['values'] as Map),
                    );
                    if (drafts['courses'] is List) {
                      drafts['courses'] = (drafts['courses'] as List)
                          .cast<String>();
                    }
                    if (drafts['days'] is List) {
                      drafts['days'] = (drafts['days'] as List).cast<int>();
                    }
                    if (drafts['milestones'] is List) {
                      drafts['milestones'] = (drafts['milestones'] as List)
                          .map((v) => Map<String, dynamic>.from(v as Map))
                          .toList();
                    }
                  }
                  _draftLoaded = true;
                }
                _loaded.add(kind);
                if (ready) {
                  errors.remove('connection');
                  _loadTimer?.cancel();
                }
                errors.remove(kind);
                _emit();
              },
              onError: (Object e) {
                errors[kind] = describe(e, 'read-$kind');
                _emit();
              },
            ),
      );
    }
  }

  final StudyDatabase repository;
  final Map<String, List<StudyRecord>> records = {};
  final Map<String, String> errors = {};
  final Set<String> _loaded = {};
  final List<StreamSubscription<List<StudyRecord>>> _subscriptions = [];
  Completer<void>? _pending;
  Timer? _loadTimer;
  bool _disposed = false, busy = false;
  bool _draftLoaded = false;
  String? error,
      selectedPlanId,
      selectedSessionId,
      selectedGoalId,
      selectedNotificationId;
  String query = '';
  final Map<String, dynamic> drafts = {};
  List<String> recentSearches = [];
  bool get ready => _loaded.length == StudyDatabase.collections.length;
  bool get disposed => _disposed;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> retry() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _loaded.clear();
    errors.clear();
    records.clear();
    if (!_disposed) {
      _listen();
      _emit();
    }
  }

  Future<void> prepareSignOut() async {
    if (_pending != null) await _pending!.future;
    if (error != null) throw DataFailure('unsaved', error!);
  }

  List<StudyRecord> items(String kind) =>
      (records[kind] ?? []).where((r) => !r.archived).toList();
  StudyRecord? find(String kind, String? id) {
    for (final r in items(kind)) {
      if (r.id == id) return r;
    }
    return null;
  }

  StudyRecord? get plan => find('plans', selectedPlanId);
  StudyRecord? get session => find('sessions', selectedSessionId);
  StudyRecord? get goal => find('goals', selectedGoalId);
  List<StudyRecord> get sessions => items('sessions')
    ..sort(
      (a, b) => (a.date('startAt') ?? DateTime(2100)).compareTo(
        b.date('startAt') ?? DateTime(2100),
      ),
    );
  List<StudyRecord> get completedSessions =>
      sessions.where((s) => s.text('status') == 'completed').toList();
  int get totalMinutes => completedSessions.fold(
    0,
    (total, r) => total + r.number('actualMinutes'),
  );
  int get completedTasks =>
      items('tasks').where((t) => t.flag('completed')).length;
  int get progress => sessions.isEmpty
      ? 0
      : (completedSessions.length * 100 / sessions.length).round();
  int get streak {
    final days = completedSessions
        .map((s) => s.date('completedAt'))
        .whereType<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    var day = DateTime.now();
    day = DateTime(day.year, day.month, day.day);
    if (!days.contains(day)) day = day.subtract(const Duration(days: 1));
    var count = 0;
    while (days.contains(day)) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  String describe(Object e, String operation) {
    final code = e is FirebaseException
        ? e.code
        : e is DataFailure
        ? e.code
        : e is TimeoutException
        ? 'timeout'
        : 'unexpected';
    debugPrint('StudyDB operation=$operation code=$code');
    return e is DataFailure
        ? e.toString()
        : 'Không thể đồng bộ ($operation / $code). Kiểm tra mạng và quyền truy cập rồi thử lại.';
  }

  Future<bool> run(String operation, Future<void> Function() action) async {
    if (_disposed || busy) return false;
    busy = true;
    error = null;
    _emit();
    _pending = Completer<void>();
    try {
      await action().timeout(const Duration(seconds: 45));
      return !_disposed;
    } catch (e) {
      error = describe(e, operation);
      return false;
    } finally {
      busy = false;
      _pending?.complete();
      _pending = null;
      _emit();
    }
  }

  Future<bool> save(
    String kind,
    String id,
    Map<String, dynamic> data, {
    StudyRecord? existing,
  }) => run(
    'save-$kind',
    () => repository.save(kind, id, data, expected: existing?.revision),
  );
  Future<bool> saveCalendar({
    StudyRecord? plan,
    required List<StudyRecord> sessions,
    StudyRecord? existingPlan,
  }) => run(
    'save-calendar',
    () => repository.saveCalendar(
      plan: plan,
      sessions: sessions,
      existingPlan: existingPlan,
    ),
  );
  Future<bool> updateSession(Map<String, dynamic> changes) async {
    final current = session;
    if (current == null) return false;
    return saveCalendar(
      sessions: [
        StudyRecord(current.id, {...current.data, ...changes}),
      ],
    );
  }

  void select(String kind, String id) {
    if (kind == 'plans') selectedPlanId = id;
    if (kind == 'sessions') {
      selectedSessionId = id;
      selectedPlanId = find('sessions', id)?.text('planId');
    }
    if (kind == 'goals') selectedGoalId = id;
    if (kind == 'notifications') selectedNotificationId = id;
    _emit();
  }

  Future<bool> setting(String id, Map<String, dynamic> values) =>
      save('settings', id, values, existing: find('settings', id));
  Future<bool> search(String value) async {
    query = value.trim();
    if (query.isEmpty) return false;
    final previous = find('settings', 'search');
    recentSearches = [
      query,
      ...(previous?.strings('recent') ?? []).where((s) => s != query),
    ].take(10).toList();
    return setting('search', {'recent': recentSearches});
  }

  @override
  void dispose() {
    _disposed = true;
    _loadTimer?.cancel();
    for (final sub in _subscriptions) {
      unawaited(sub.cancel());
    }
    records.clear();
    errors.clear();
    recentSearches.clear();
    super.dispose();
  }
}
