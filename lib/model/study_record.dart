import 'package:cloud_firestore/cloud_firestore.dart';

/// An envelope is stable across schema additions; optional fields live in data.
class StudyRecord {
  const StudyRecord(this.id, this.data);
  final String id;
  final Map<String, dynamic> data;
  String text(String key, [String fallback = '']) =>
      data[key] is String ? data[key] as String : fallback;
  int number(String key, [int fallback = 0]) =>
      data[key] is num ? (data[key] as num).toInt() : fallback;
  bool flag(String key) => data[key] == true;
  DateTime? date(String key) =>
      data[key] is Timestamp ? (data[key] as Timestamp).toDate() : null;
  List<String> strings(String key) =>
      (data[key] is List ? data[key] as List : const [])
          .whereType<String>()
          .toList();
  List<Map<String, dynamic>> maps(String key) =>
      (data[key] is List ? data[key] as List : const [])
          .whereType<Map>()
          .map((v) => Map<String, dynamic>.from(v))
          .toList();
  int get revision => number('revision');
  bool get archived => flag('archived');
}

class DataFailure implements Exception {
  const DataFailure(this.code, this.message);
  final String code, message;
  @override
  String toString() => '$message [$code]';
}

String dateLabel(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
String clockLabel(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
