# Database của Study Planner

## Phạm vi đã nối

Project Flutter hiện có HM, GO, PL, AN, PR. Không tạo thêm giao diện TS, FC, HT hoặc AI Assistant từ các ảnh thiết kế cũ. Việc cần làm của HM lưu vào tasks; phần tạo lịch/kế hoạch gọi Gemini trực tiếp từ Flutter, sau đó xác nhận lưu Firestore theo UID.

Tất cả dữ liệu được đặt dưới **user/{Firebase Authentication UID}**. UID được lấy một lần khi mở phiên đăng nhập, không nhập từ form. Mỗi phiên có repository, ViewModel, listener và Navigator riêng; khi đổi tài khoản, phiên cũ bị hủy. Không dùng tên người dùng/email làm khóa dữ liệu.

| Đường dẫn | Nội dung |
|---|---|
| user/{uid} | Hồ sơ cá nhân, ngày tạo, email; PR02 cập nhật trường cá nhân |
| plans/{planId} | Tên, mục tiêu, nguồn manual/gemini, môn học, ngày bắt đầu/kết thúc, ngân sách tuần |
| sessions/{sessionId} | planId bắt buộc, môn, tiêu đề, startAt/endAt, địa điểm, tài liệu, ghi chú, trạng thái, actualMinutes, rating, completedAt |
| goals/{goalId} | Chỉ tiêu, baseline/current/target, đơn vị, thời hạn, cột mốc, đánh giá |
| tasks/{taskId} | Việc cần làm, mô tả, trạng thái hoàn thành và lưu trữ |
| settings/preferences | Chế độ giao diện, cỡ chữ |
| settings/notifications | Tùy chọn nhận thông báo |
| settings/editor | Bản nháp của wizard và phân bổ giờ, lưu khi chuyển bước bằng nút trong wizard |
| settings/search | Tối đa 10 tìm kiếm gần đây |
| settings/calendar | Revision chung cho mọi thao tác thay đổi lịch |
| notifications, activities | Bản ghi cũ có thể đọc; không tạo mới bằng trigger trong cấu hình Spark hiện tại |
| aiDrafts, aiUsage | Đường dẫn backend cũ, luồng Gemini trực tiếp hiện không sử dụng |

Các đường dẫn trong bảng, trừ dòng đầu tiên, đều là subcollection của user/{uid}.

## Tính toàn vẹn

- Bản ghi nghiệp vụ có ownerId, schemaVersion, revision, createdAt, updatedAt. Timestamps của metadata do máy chủ cấp. startAt/endAt lưu thời điểm UTC bằng Firestore Timestamp và hiển thị giờ địa phương trên thiết bị.
- Tạo kế hoạch và toàn bộ buổi học trong cùng transaction. Không tạo kế hoạch rỗng nếu kiểm tra lịch thất bại. Tối đa 90 ngày/350 buổi mỗi lần tạo; mỗi buổi tối đa 240 phút.
- Mọi thao tác lịch đọc calendar revision trước truy vấn lịch hiện tại, kiểm tra giao nhau, rồi xác nhận revision trong transaction. Nếu có thiết bị khác sửa lịch, yêu cầu thử lại. Kế hoạch từ Gemini cũng lưu qua cùng repository/khóa. Kiểm tra chồng giờ nằm trong repository/backend; rules không thể so sánh tất cả buổi học của user.
- Cập nhật bản ghi yêu cầu revision hiện tại. Thiết bị cũ không được ghi đè âm thầm. Không dùng tên môn/tên nhiệm vụ làm ID.
- AN và trang chủ tính trực tiếp từ completed sessions và tasks; không lưu các số liệu phần trăm mẫu. Chỉ buổi đã lưu kết quả được tính phút học; xem màn hình không làm tăng số liệu.
- Chờ thao tác đang ghi trước đăng xuất. Khi ghi lỗi, hiển thị mã lỗi và giữ form để thử lại. Chỉ hiển thị dữ liệu snapshot đã được máy chủ xác nhận; nếu mất mạng lúc mở app, hiển thị tải lại thay vì dữ liệu mẫu.
- Các trường bổ sung không ảnh hưởng schema chung có thể đặt trong map extensions ở bản ghi nghiệp vụ. Khi thêm trường nghiệp vụ cấp cao, cập nhật serializer, rules và tests cùng nhau. Không đổi schemaVersion nếu chỉ thêm trường tùy chọn tương thích; version lạ được báo lỗi để tránh ghi sai dữ liệu.

## Triển khai lên Firebase thật

Ngày 28/10/2026: Firestore Rules đã triển khai thành công lên studyplanner-76524. Project giữ gói Spark. AI hiện gọi Gemini Developer API trực tiếp từ Flutter, key nạp từ .env; không dùng Cloud Functions, Secret Manager hoặc nâng cấp Blaze.

Xem [GEMINI_SETUP.md](GEMINI_SETUP.md) cho cách chạy, model đã thử thành công và flow tạo kế hoạch. Bản xem trước ở bộ nhớ; xác nhận mới lưu kế hoạch và từng buổi theo UID. Model mặc định gemini-3.5-flash-lite; có thể đổi GEMINI_MODEL. Hạn mức theo AI Studio, không còn quota 5 lượt/ngày của backend cũ.

firebase.json chỉ cấu hình Firestore. Nếu cần triển khai lại rules:

```powershell
.\functions\node_modules\.bin\firebase.cmd deploy --only firestore:rules --project studyplanner-76524
```

Thư mục functions cũ không được app gọi hoặc deploy. Thông báo tạo bởi trigger cũ chưa chạy; chưa có push/nhắc lịch nền khi app đóng. Dữ liệu kế hoạch, phiên học và thống kê vẫn cập nhật qua listener Firestore.

## Kiểm thử

```powershell
flutter analyze
flutter test
$env:JAVA_HOME='C:\Program Files\Android\Android Studio\jbr'
$env:PATH=$env:JAVA_HOME+'\bin;'+$env:PATH
.\functions\node_modules\.bin\firebase.cmd emulators:exec --only firestore --project demo-study-planner --config firebase.emulator.json "node --test functions/security.test.js"
```

Emulator dùng project demo, không ghi Firebase thật. Tests bao gồm UID A/B, khách chưa đăng nhập, sửa ownerId, revision cũ, parent plan, calendar lock, chỉ tiêu sai và các layout có/không có dữ liệu.

## Debug và dữ liệu cũ

Console log có dạng `StudyDB operation=save-calendar code=overlap`; không ghi mật khẩu, key, email hoặc nội dung học tập. UI cũng hiện mã `permission-denied`, `calendar-conflict`, `conflict`, `timeout` để phân biệt lỗi.

Một số trường hợp:
- permission-denied: đối chiếu UID hiện tại với đường dẫn, Project ID và rules đã Publish.
- overlap: đổi giờ; không tắt kiểm tra trùng lịch.
- conflict/calendar-conflict: chờ listener nhận bản mới rồi thử lưu lại.
- schema-owner: có bản ghi thủ công/legacy không đúng schema hoặc ownerId; cần kiểm tra bản ghi đó trước khi migrate, không xóa hoặc gán lại UID tự động.
- Không thấy collection: Firestore chỉ hiển thị collection sau lần ghi document đầu tiên. Account mới không có kế hoạch/buổi học/mục tiêu mẫu.

appState/current cũ chỉ chứa trạng thái demo, không phải lịch học có ngày/ID. Không tự chuyển các con số và tên nhiệm vụ demo thành dữ liệu thật. Các file prototype cũ vẫn được dùng cho kiểm thử giao diện không đăng nhập; khi có phiên thật, live data renderer dùng đúng các frame/file và bộ component hiện có.

Theo dõi toàn bộ collection hiện phù hợp quy mô bài tập cá nhân. Trước khi mở rộng nhiều năm dữ liệu/nhiều nghìn buổi mỗi user, thêm phân trang, truy vấn khoảng ngày và chuyển kiểm tra xung đột hoàn toàn lên backend; không cắt danh sách hiện tại mà vẫn dùng nó để kiểm tra chồng lịch.
