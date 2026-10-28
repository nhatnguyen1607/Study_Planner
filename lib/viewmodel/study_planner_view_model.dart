import 'study_data_view_model.dart';

import 'package:flutter/foundation.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/model/study_time_slot.dart';

class StudyPlannerViewModel extends ChangeNotifier {
  StudyDataViewModel? database;
  StudyDestination _destination = StudyDestination.hm01;
  final List<StudyDestination> _history = <StudyDestination>[];
  final Set<String> completedTasks = <String>{
    'Đọc tài liệu Python',
    'Xem video bài giảng',
  };
  String selectedDuration = '6 tháng';
  int goalProgress = 60;
  int rating = 5;

  final Set<StudyTimeSlot> _idealTimeSlots = {StudyTimeSlot.evening};
  Set<StudyTimeSlot> get idealTimeSlots => Set.unmodifiable(_idealTimeSlots);
  String get idealTimeLabel => _idealTimeSlots.length == 1
      ? _idealTimeSlots.single.range
      : StudyTimeSlot.values
            .where(_idealTimeSlots.contains)
            .map((slot) => slot.label)
            .join(' · ');

  bool setIdealTimeSlots(Set<StudyTimeSlot> slots) {
    if (slots.isEmpty) return false;
    if (!setEquals(_idealTimeSlots, slots)) {
      _idealTimeSlots
        ..clear()
        ..addAll(slots);
      notifyListeners();
    }
    return true;
  }

  static const maxWeeklyHours = 168;
  final List<int> _subjectHours = [3, 2, 4];
  int _weeklyHours = 18;

  List<int> get subjectHours => List.unmodifiable(_subjectHours);
  int get weeklyHours => _weeklyHours;
  int get allocatedHours => database == null
      ? _subjectHours.fold(0, (sum, hours) => sum + hours)
      : database!.selectedSubjects.fold(
          0,
          (sum, s) => sum + database!.subjectHoursFor(s, legacy: _subjectHours),
        );
  int get remainingHours => weeklyHours - allocatedHours;

  int maxHoursForSubject(int index) => remainingHours + _subjectHours[index];

  bool setSubjectHours(int index, int hours) {
    if (index < 0 || index >= _subjectHours.length) return false;
    if (hours < 1 || hours > maxHoursForSubject(index)) return false;
    if (_subjectHours[index] != hours) {
      _subjectHours[index] = hours;
      notifyListeners();
    }
    return true;
  }

  bool setWeeklyHours(int hours) {
    if (hours < allocatedHours || hours > maxWeeklyHours) return false;
    if (_weeklyHours != hours) {
      _weeklyHours = hours;
      notifyListeners();
    }
    return true;
  }

  Map<String, dynamic> get cloudState => {
    'completedTasks': completedTasks.toList()..sort(),
    'selectedDuration': selectedDuration,
    'goalProgress': goalProgress,
    'rating': rating,
    'weeklyHours': weeklyHours,
    'subjectHours': subjectHours,
    'idealTimeSlots': idealTimeSlots.map((v) => v.name).toList()..sort(),
  };
  void restoreCloudState(Map<String, dynamic> data) {
    if ((data['schemaVersion'] ?? 1) != 1) {
      throw const FormatException('Unsupported state version');
    }
    if (data['completedTasks'] is List) {
      completedTasks
        ..clear()
        ..addAll((data['completedTasks'] as List).whereType<String>());
    }
    if (data['selectedDuration'] is String) {
      selectedDuration = data['selectedDuration'];
    }
    if (data['goalProgress'] is num) {
      goalProgress = (data['goalProgress'] as num).toInt().clamp(0, 100);
    }
    if (data['rating'] is num) {
      rating = (data['rating'] as num).toInt().clamp(1, 5);
    }
    final hours = data['subjectHours'];
    final weekly = data['weeklyHours'];
    if (hours is List &&
        hours.length == 3 &&
        hours.every((v) => v is int && v >= 1 && v <= 168) &&
        weekly is int &&
        weekly <= 168 &&
        weekly >= hours.fold<int>(0, (sum, v) => sum + (v as int))) {
      _subjectHours.setAll(0, hours.cast<int>());
      _weeklyHours = weekly;
    }
    final slots = data['idealTimeSlots'];
    if (slots is List) {
      final selected = StudyTimeSlot.values
          .where((v) => slots.contains(v.name))
          .toSet();
      if (selected.isNotEmpty) {
        _idealTimeSlots
          ..clear()
          ..addAll(selected);
      }
    }
    notifyListeners();
  }

  StudyDestination get destination => _destination;

  void navigate(StudyDestination next, {bool replace = false}) {
    if (next == _destination) return;
    if (!replace) _history.add(_destination);
    _destination = next;
    notifyListeners();
  }

  void goBack() {
    if (_history.isEmpty) {
      navigate(StudyDestination.hm01, replace: true);
      return;
    }
    _destination = _history.removeLast();
    notifyListeners();
  }

  void toggleTask(String task) {
    completedTasks.contains(task)
        ? completedTasks.remove(task)
        : completedTasks.add(task);
    notifyListeners();
  }

  void setDuration(String value) {
    selectedDuration = value;
    notifyListeners();
  }

  void updateGoalProgress(int delta) {
    goalProgress = (goalProgress + delta).clamp(0, 100);
    notifyListeners();
  }

  void setRating(int value) {
    rating = value.clamp(1, 5);
    notifyListeners();
  }
}
