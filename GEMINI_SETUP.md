# Gemini trực tiếp + Firestore (không Cloud Functions)

## Chạy ứng dụng

File `.env` ở gốc project đã có `GEMINI_API_KEY`. App nạp file này qua flutter_dotenv khi khởi động. Không cần Cloud Functions, Secret Manager hoặc nâng cấp Firebase lên Blaze cho luồng này.

```dotenv
GEMINI_API_KEY=your_key_here
# Tùy chọn, mặc định là gemini-3.5-flash-lite
GEMINI_MODEL=gemini-3.5-flash-lite
```

Giữ nguyên key hiện tại trong `.env`; không copy giá trị ví dụ đè lên key. `.env` đã được loại khỏi Git. Key nằm trong ứng dụng khi build vì đây là gọi API trực tiếp từ client; phù hợp bản demo, không bảo vệ được key khi phát hành APK công khai. Không lưu key vào Firestore, log hoặc source Dart.

```powershell
cd D:\ki7\UX-UI\study_planner_flutter
flutter pub get
flutter run -d emulator-5554
```

Sau khi sửa `.env`, dừng app và chạy lại. Không chỉ hot reload. Có thể dùng `--dart-define=GEMINI_MODEL=...` để chọn model, nhưng không nên gõ key vào lịch sử terminal. Gemini quota/model miễn phí phụ thuộc project AI Studio. App không bật billing, không tự gửi lại khi lỗi và không gọi Gemini khi chỉ mở màn hình.

## Flow bấm

Lịch → Tạo kế hoạch mới → Đề xuất lịch với AI. Nhập môn, quỹ giờ mỗi tuần và mục tiêu/trình độ. Chọn ngày bắt đầu và số tuần → Tạo kế hoạch với Gemini → xem tên kế hoạch, mục tiêu, chủ đề và nội dung từng buổi → Xác nhận lưu lịch.

Gemini trả một tuần mẫu bằng JSON có schema. Flutter kiểm tra loại dữ liệu, tất cả môn đã chọn, ngân sách giờ, thời lượng 15–120 phút/buổi, khung 07:00–22:00, không chồng giờ. Khi xác nhận, template chuyển thành từng buổi có ngày giờ cụ thể trong 1–12 tuần. Kế hoạch và buổi học được ghi cùng transaction qua StudyDatabase; vẫn kiểm tra trùng với lịch hiện tại và revision chung.

Key chỉ gửi trong header x-goog-api-key tới generativelanguage.googleapis.com. Prompt gồm tên môn, số giờ và mục tiêu người dùng nhập; không gửi UID, email, mật khẩu hoặc toàn bộ hồ sơ. Output không được quyết định UID, document ID hay câu lệnh ghi Firestore.

## Lưu dữ liệu

- `user/{uid}/plans/{draftId}`: title, objective, source=gemini, subjects, startAt/endAt, weeklyHours, extensions (model, số tuần, phút học tuần).
- `user/{uid}/sessions/{draftId_day_slot}`: planId, title=chủ đề, subject, notes=nội dung học, startAt/endAt và trạng thái.
- ownerId, schemaVersion, revision và timestamps dùng schema chung. UID được khóa theo phiên đăng nhập; đổi tài khoản trong lúc chờ thì kết quả bị loại.
- Bản xem trước giữ trong bộ nhớ của phiên AI. Chưa xác nhận thì không ghi Firestore. Đóng màn hình trước khi lưu sẽ bỏ bản xem trước.
- Lưu lại cùng bản xem trước không tạo kế hoạch trùng. Nếu lưu lỗi, giữ preview và cho thử lưu lại mà không gọi Gemini thêm lần nữa.

Các rules đã triển khai cho phép source=gemini khi ghi cùng calendar lock và đúng UID. Không cần sửa rules hoặc deploy Functions để gọi API trực tiếp. `firebase.json` hiện chỉ cấu hình Firestore. Thư mục functions cũ chỉ còn mã tham khảo/công cụ emulator, không được app gọi hoặc deploy.

Thông báo từ trigger server cũ không chạy trong cấu hình này; chưa có push/nhắc lịch tự động khi app đóng. HM/AN vẫn tự cập nhật kế hoạch và kết quả từ listener Firestore.

## Kiểm tra và debug

```powershell
flutter analyze
flutter test
dart run tool/gemini_smoke_test.dart
```

Smoke test gửi đúng một yêu cầu ví dụ gồm Toán/Tiếng Anh, không ghi Firestore và không in key hoặc raw response. Có thể chọn model thử bằng `--model=...`.

Ngày 28/10/2026 đã thử key trong .env: gemini-flash-latest trả 503, gemini-3.5-flash-lite trả thành công một kế hoạch hợp lệ gồm 2 buổi, tổng 120/120 phút. Vì vậy app mặc định dùng Flash-Lite; không tự gọi nhiều model để tránh tiêu thụ thêm quota.

Mã lỗi:
- missing-key: chưa nạp .env hoặc giá trị rỗng.
- http-400/401/403: kiểm tra key, quyền API và model.
- http-404: model không tồn tại/không còn hỗ trợ; sửa GEMINI_MODEL.
- http-429: hết quota hoặc gửi quá nhanh; chờ, không tự bật billing.
- http-503/timeout: nhà cung cấp tạm bận; thử lại sau.
- invalid-plan/incomplete: output không đạt kiểm tra; chưa ghi database.
- overlap: đổi ngày bắt đầu hoặc tạo lịch khác; chưa lưu kế hoạch bị trùng.
- permission-denied: kiểm tra UID, Project ID và rules Firestore.

Tài liệu chính thức: https://ai.google.dev/gemini-api/docs/generate-content/structured-output và https://ai.google.dev/gemini-api/docs/pricing.
