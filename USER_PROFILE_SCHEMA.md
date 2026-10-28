# Hồ sơ người dùng — collection user

> Xem [DATABASE_GUIDE.md](DATABASE_GUIDE.md) cho schema nghiệp vụ và cách triển khai mới nhất. Tùy chọn giao diện/thông báo đang dùng settings/preferences và settings/notifications dưới user/{uid}; các giá trị trong hồ sơ gốc được giữ để tương thích.

Document ID chính là Firebase Authentication UID: user/{uid}.
Không dùng add() hoặc email làm ID. Không lưu mật khẩu, access token hoặc quyền admin.

| Trường | Khi tạo mới | Chỉnh sửa ở đâu |
| --- | --- | --- |
| uid | UID từ Auth | Không cho đổi |
| email | Email từ Auth | Chỉ đọc; đổi email cần luồng Auth riêng |
| displayName | Họ tên đăng ký | Chỉnh sửa hồ sơ |
| bio | null | Chỉnh sửa hồ sơ, tối đa 120 ký tự |
| studyRole | null | Vai trò học tập, không phải quyền truy cập |
| school / major / academicYear | null | Chỉnh sửa hồ sơ |
| photoUrl | null | Dự phòng chức năng upload avatar |
| notifications | 7 giá trị mặc định theo PR04 | Đã tạo schema; PR04 chưa nối lưu cloud |
| preferences | Ngôn ngữ vi, giao diện system, màu green, font medium, giờ 24h, nền botanical | Đã tạo schema; PR05 chưa nối lưu cloud |
| createdAt / updatedAt | Server timestamp | Hệ thống |

## Luồng
1. Auth tạo tài khoản và trả UID.
2. Lưu displayName trong Auth, rồi tạo user/{uid} bằng Firestore transaction.
3. Transaction chỉ tạo khi document chưa có; không reset thông tin đã sửa.
4. Khi mở phiên đã đăng nhập, kiểm tra/bổ sung hồ sơ thiếu (bao gồm tài khoản cũ).
5. Chỉ vào trang chủ khi đọc được hồ sơ; lỗi thì có Thử lại / Đăng xuất.
6. PR02 đọc từ stream Firestore và chỉ update các trường được chỉnh sửa.
7. Auth và Firestore không có transaction chung. Nếu tạo tài khoản xong nhưng ghi hồ sơ lỗi, giữ tài khoản và thử lại bước hồ sơ, không xóa tài khoản.

## Cấu hình cần làm trong Firebase Console
- Build → Firestore Database → Create database → chọn chế độ Production.
- Chọn vị trí database phù hợp (đây là lựa chọn cần người quản lý project quyết định).
- Nếu database đã có, không tạo lại.
- Rules: xem firestore.rules và ghép rule /user/{uid} vào rules hiện có.
  Không dùng allow read, write: if true.
- Code/rules được chuẩn bị ở máy, CHƯA deploy lên project Firebase.
- Nếu đã dùng Firebase CLI, xem xét rules hiện tại trước khi:
  firebase deploy --only firestore:rules --project studyplanner-76524
  Lệnh deploy thay rules đang có bằng file local; không chạy nếu chưa hợp nhất rules của collection khác.

## Kiểm tra
Các test Dart dùng fake_cloud_firestore để kiểm tra dữ liệu và UI, không thay thế kiểm thử Security Rules trên Firebase Emulator. Thư viện fake không hỗ trợ đầy đủ functions/timestamps/request.resource trong rules này; cần kiểm tra rules trên Emulator/Console trước khi publish.
Đăng ký một tài khoản test → Authentication/Users lấy UID → Firestore/user/{uid}.
Chỉnh sửa hồ sơ → Lưu → đăng xuất/đăng nhập lại để kiểm tra dữ liệu vẫn còn.
Các kế hoạch, mục tiêu và thống kê vẫn là dữ liệu mẫu, chưa nối Firestore.
