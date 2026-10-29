import '../model/study_subject.dart';

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
                    // Transaction IDs are kept only in memory for retries.
                    drafts.remove('planDraftId');
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
                // Keep the catalog live without overwriting unsaved wizard fields.
                if (kind == 'settings' && _draftLoaded) {
                  final editor = items
                      .where((r) => r.id == 'editor')
                      .firstOrNull;
                  final values = editor?.data['values'];
                  if (values is Map && values['customSubjects'] is List) {
                    drafts['customSubjects'] = List<dynamic>.of(
                      values['customSubjects'] as List,
                    );
                  }
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
  final Set<Completer<void>> _editorWaiters = {};
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

  List<StudySubject> get subjects {
    final custom = (drafts['customSubjects'] as List? ?? [])
        .whereType<Map>()
        .map((v) => StudySubject.fromJson(Map<String, dynamic>.from(v)));
    return [...StudySubject.presets, ...custom];
  }

  List<StudySubject> get selectedSubjects {
    final names =
        (drafts['courses'] as List?)?.whereType<String>().toSet() ??
        StudySubject.presets.take(3).map((s) => s.name).toSet();
    return subjects.where((s) => names.contains(s.name)).toList();
  }

  int subjectHoursFor(
    StudySubject subject, {
    List<int> legacy = const [3, 2, 4],
  }) {
    final saved = (drafts['courseHours'] as Map?)?[subject.id];
    if (saved is int && saved >= 1 && saved <= 168) return saved;
    final index = StudySubject.presets.indexWhere((s) => s.id == subject.id);
    return index >= 0 && index < legacy.length ? legacy[index] : 1;
  }

  bool toggleSubject(StudySubject subject) {
    final names = selectedSubjects.map((s) => s.name).toList();
    if (names.contains(subject.name)) {
      names.remove(subject.name);
    } else {
      if (names.length >= 6) {
        error = 'Chọn tối đa 6 môn cho mỗi kế hoạch.';
        _emit();
        return false;
      }
      names.add(subject.name);
    }
    drafts['courses'] = names;
    error = null;
    _emit();
    return true;
  }

  bool changeSubjectHours(StudySubject subject, int hours) {
    if (hours < 1 || hours > 168) return false;
    drafts['courseHours'] = {
      ...?(drafts['courseHours'] as Map?),
      subject.id: hours,
    };
    _emit();
    return true;
  }

  Future<bool> addSubject(
    String rawName, {
    String category = 'Tự chọn',
    Map<String, dynamic>? allocation,
  }) async {
    final name = rawName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty || name.length > 80) {
      error = 'Tên môn cần từ 1 đến 80 ký tự.';
      _emit();
      return false;
    }
    if (subjects.any((s) => s.name.toLowerCase() == name.toLowerCase())) {
      error = 'Môn học này đã có trong danh sách.';
      _emit();
      return false;
    }
    if (subjects.length >= 50) {
      error = 'Danh sách tối đa 50 môn học.';
      _emit();
      return false;
    }
    final subject = StudySubject(
      id: repository.newId('settings'),
      name: name,
      category: category,
      icon: 'book',
      color: subjects.length % 7,
    );
    final selected = selectedSubjects.map((s) => s.name).toList();
    if (selected.length < 6) selected.add(name);
    final next = {
      ...drafts,
      'customSubjects': [
        ...(drafts['customSubjects'] as List? ?? []),
        subject.toJson(),
      ],
      'courses': selected,
    };
    final previous = find('settings', 'editor');
    final ok = await setting('editor', {
      'values': next,
      'allocation':
          allocation ?? previous?.data['allocation'] ?? <String, dynamic>{},
    });
    if (ok) {
      drafts
        ..clear()
        ..addAll(next);
      _emit();
    }
    return ok;
  }

  // Keep the save busy until the committed snapshot reaches this view model.
  // The next wizard step must use the revision we just wrote.
  Future<void> _awaitEditorRevision(int revision) async {
    if (_disposed || (find('settings', 'editor')?.revision ?? 0) >= revision) {
      return;
    }
    final observed = Completer<void>();
    void check() {
      if (!observed.isCompleted &&
          (find('settings', 'editor')?.revision ?? 0) >= revision) {
        observed.complete();
      }
    }

    _editorWaiters.add(observed);
    addListener(check);
    try {
      check();
      await observed.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw const DataFailure(
          'sync-pending',
          'Bản nháp đã lưu nhưng chưa đồng bộ xong. Chờ kết nối rồi thử lại.',
        ),
      );
    } finally {
      _editorWaiters.remove(observed);
      if (!_disposed) removeListener(check);
    }
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
      run('save-settings', () async {
        final previous = find('settings', id);
        await repository.save(
          'settings',
          id,
          values,
          expected: previous?.revision,
        );
        if (id == 'editor') {
          await _awaitEditorRevision((previous?.revision ?? 0) + 1);
        }
      });
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
    for (final waiter in _editorWaiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
    _editorWaiters.clear();
    _loadTimer?.cancel();
    for (final sub in _subscriptions) {
      unawaited(sub.cancel());
    }
    records.clear();
    errors.clear();
    recentSearches.clear();
    drafts.clear();
    super.dispose();
  }
}
