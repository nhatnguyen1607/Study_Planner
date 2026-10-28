import 'auth_user.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.bio,
    this.studyRole,
    this.school,
    this.major,
    this.academicYear,
    this.photoUrl,
  });
  final String uid, email, displayName;
  final String? bio, studyRole, school, major, academicYear, photoUrl;
  static const notificationDefaults = <String, bool>{
    'enabled': true,
    'studyReminders': true,
    'goalUpdates': true,
    'deadlineReminders': true,
    'aiSuggestions': true,
    'featureUpdates': false,
    'news': false,
  };
  static const preferenceDefaults = <String, String>{
    'themeMode': 'system',
    'accentColor': 'green',
    'fontSize': 'medium',
    'timeFormat': '24h',
    'background': 'botanical',
    'language': 'vi',
  };
  static String? optionalText(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();

  static Map<String, dynamic> initialData(AuthUser user, Object timestamp) => {
    'uid': user.uid,
    'email': user.email ?? '',
    'displayName': user.displayName?.trim() ?? '',
    'photoUrl': null,
    'bio': null,
    'studyRole': null,
    'school': null,
    'major': null,
    'academicYear': null,
    'notifications': Map<String, bool>.from(notificationDefaults),
    'preferences': Map<String, String>.from(preferenceDefaults),
    'createdAt': timestamp,
    'updatedAt': timestamp,
  };
  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) =>
      UserProfile(
        uid: uid,
        email: data['email'] as String? ?? '',
        displayName: data['displayName'] as String? ?? '',
        bio: data['bio'] as String?,
        studyRole: data['studyRole'] as String?,
        school: data['school'] as String?,
        major: data['major'] as String?,
        academicYear: data['academicYear'] as String?,
        photoUrl: data['photoUrl'] as String?,
      );
  Map<String, dynamic> editableData() => {
    'displayName': displayName.trim(),
    'bio': optionalText(bio),
    'studyRole': optionalText(studyRole),
    'school': optionalText(school),
    'major': optionalText(major),
    'academicYear': optionalText(academicYear),
  };
}
