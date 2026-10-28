class GeminiFailure implements Exception {
  const GeminiFailure(this.code, this.message);
  final String code, message;
  @override
  String toString() => '$message [$code]';
}

/// AI output has no document IDs, UID or write instructions.
class GeneratedStudyPlan {
  const GeneratedStudyPlan({
    required this.title,
    required this.objective,
    required this.sessions,
  });
  final String title, objective;
  final List<GeneratedStudySession> sessions;
  int get weeklyMinutes =>
      sessions.fold(0, (total, s) => total + s.durationMinutes);
  Map<String, dynamic> toJson() => {
    'title': title,
    'objective': objective,
    'sessions': sessions.map((s) => s.toJson()).toList(),
  };
  factory GeneratedStudyPlan.parse(
    Object? json,
    List<String> subjects,
    int hours,
  ) {
    Never invalid() => throw const GeminiFailure(
      'invalid-plan',
      'Gemini trả lịch chưa hợp lệ. Hãy thử đề xuất lại.',
    );
    if (json is! Map) invalid();
    final title = json['title'],
        objective = json['objective'],
        raw = json['sessions'];
    if (title is! String ||
        title.trim().isEmpty ||
        title.length > 120 ||
        objective is! String ||
        objective.length > 1000 ||
        raw is! List ||
        raw.isEmpty ||
        raw.length > 28) {
      invalid();
    }
    final result = <GeneratedStudySession>[];
    for (final entry in raw) {
      if (entry is! Map) invalid();
      final subject = entry['subject'],
          day = entry['day'],
          start = entry['startMinute'],
          duration = entry['durationMinutes'],
          topic = entry['topic'],
          notes = entry['notes'];
      if (subject is! String ||
          !subjects.contains(subject) ||
          day is! int ||
          day < 0 ||
          day > 6 ||
          start is! int ||
          start < 420 ||
          duration is! int ||
          duration < 15 ||
          duration > 120 ||
          start + duration > 1320 ||
          topic is! String ||
          topic.trim().isEmpty ||
          topic.length > 120 ||
          notes is! String ||
          notes.length > 1000) {
        invalid();
      }
      result.add(
        GeneratedStudySession(subject, day, start, duration, topic, notes),
      );
    }
    result.sort(
      (a, b) => a.day == b.day
          ? a.startMinute.compareTo(b.startMinute)
          : a.day.compareTo(b.day),
    );
    for (var i = 1; i < result.length; i++) {
      final previous = result[i - 1], next = result[i];
      if (previous.day == next.day &&
          previous.startMinute + previous.durationMinutes > next.startMinute) {
        invalid();
      }
    }
    final plan = GeneratedStudyPlan(
      title: title.trim(),
      objective: objective.trim(),
      sessions: List.unmodifiable(result),
    );
    if (plan.weeklyMinutes > hours * 60 ||
        subjects.any((s) => !result.any((v) => v.subject == s))) {
      invalid();
    }
    return plan;
  }
}

class GeneratedStudySession {
  const GeneratedStudySession(
    this.subject,
    this.day,
    this.startMinute,
    this.durationMinutes,
    this.topic,
    this.notes,
  );
  final String subject, topic, notes;
  final int day, startMinute, durationMinutes;
  Map<String, dynamic> toJson() => {
    'subject': subject,
    'day': day,
    'startMinute': startMinute,
    'durationMinutes': durationMinutes,
    'topic': topic,
    'notes': notes,
  };
}
