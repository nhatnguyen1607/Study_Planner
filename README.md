# Study_Planner

Ứng dụng Flutter quản lý kế hoạch và lịch học, tổ chức theo MVVM. Các flow hiện có: Home (HM), Study Goals (GO), Study Planner (PL), Analytics (AN), Profile (PR).

## Chức năng

- Đăng nhập/đăng ký email và mật khẩu bằng Firebase Authentication.
- Hồ sơ, kế hoạch, buổi học, mục tiêu và việc cần làm lưu trong Firestore dưới user/{uid}.
- Kiểm tra trùng giờ, revision khi cập nhật và tách dữ liệu giữa các tài khoản.
- Gemini tạo kế hoạch và nội dung từng buổi; xem trước rồi xác nhận lưu lịch.
- Thống kê từ dữ liệu học tập đã lưu. Giữ cấu trúc mỗi frame một file trong lib/view.

## Cài đặt và chạy Android

Cần Flutter SDK phù hợp với pubspec.yaml, Android SDK và emulator hoặc điện thoại Android. Firebase hiện đã cấu hình cho Android; các nền tảng khác chưa cấu hình Firebase.

```powershell
flutter pub get
Copy-Item .env.example .env
```

Nhập key AI Studio của bạn vào GEMINI_API_KEY trong .env. Không commit .env. Model mặc định là gemini-3.5-flash-lite, có thể đổi GEMINI_MODEL.

```powershell
flutter devices
flutter run -d emulator-5554
```

Vào Lịch → Tạo kế hoạch mới → Đề xuất lịch với AI. Dừng và chạy lại app sau khi sửa .env.

## Tổ chức mã

- lib/model: dữ liệu và kiểm tra output Gemini.
- lib/services: Firebase repositories và Gemini HTTP client.
- lib/viewmodel: trạng thái, thao tác và vòng đời phiên đăng nhập.
- lib/view/HM, GO, PL, AN, PR: các frame; lib/view/common: component dùng chung.
- test: kiểm thử UI, dữ liệu, UID isolation và Gemini với HTTP giả lập.

Gemini gọi trực tiếp từ Flutter, không Cloud Functions. .env không nằm trong Git nhưng được đóng gói khi build app; key phía client có thể bị trích xuất, vì vậy không phát hành key dùng chung trong APK công khai. API có hạn mức riêng của project AI Studio.

## Tài liệu và kiểm tra

- [Gemini và cách tạo kế hoạch](GEMINI_SETUP.md)
- [Schema Firestore, UID và debug](DATABASE_GUIDE.md)
- firestore.rules: phân quyền và kiểm tra dữ liệu theo UID.
- functions: mã backend cũ và công cụ kiểm thử emulator; không được app gọi hoặc deploy trong cấu hình hiện tại.

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Không commit build, node_modules, .env, service-account key hoặc Android signing key.
