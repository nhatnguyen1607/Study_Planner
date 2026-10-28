# Firebase Authentication — Android

> Cấu hình AI hiện tại dùng Gemini trực tiếp + Firestore Spark, không Cloud Functions/Secret Manager. Xem [GEMINI_SETUP.md](GEMINI_SETUP.md); các ghi chú backend phía dưới là lịch sử.


> Xem [DATABASE_GUIDE.md](DATABASE_GUIDE.md) cho schema nghiệp vụ và cách triển khai mới nhất. Tùy chọn giao diện/thông báo đang dùng settings/preferences và settings/notifications dưới user/{uid}; các giá trị trong hồ sơ gốc được giữ để tương thích.

Project: studyplanner-76524
Android package: com.example.study_planner_flutter

## Before running
1. Firebase Console → Authentication → Sign-in method → enable Email/Password.
2. Keep android/app/google-services.json downloaded for the matching Android app.
3. On Windows, enable Developer Mode in Settings so Flutter can create plugin symlinks.
4. In this project, run:
   flutter pub get
   flutter run -d emulator-5554

Stop the existing flutter run session and rebuild. Hot reload alone cannot add native Firebase plugins.

## Implemented
- Email/password registration and sign-in through Firebase Auth.
- Display name stored on the Firebase Auth user (not Firestore).
- Session restored using userChanges().
- Sign out: Cá nhân → Cài đặt ứng dụng → Đăng xuất.
- New in-memory planner state for each authenticated session.
- Loading, validation, and Vietnamese authentication error messages.
- Passwords never written to app files or logs.

Only Android is configured. Web/iOS require their own Firebase app configuration.
User profiles now use Firestore user/{uid}. See USER_PROFILE_SCHEMA.md for schema and required Rules setup.
Planner, goals and analytics remain mock data. No Firestore database or rules were deployed automatically.

## Verification
Tests inject FakeAuthRepository; they do not create real Firebase accounts.
A live end-to-end test still requires an Android device/emulator, internet, and Email/Password enabled.
Use your own test email when checking registration, then verify it in Firebase Console → Authentication → Users.
