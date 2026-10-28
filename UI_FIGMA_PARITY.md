# Khôi phục giao diện Flutter theo End_term

Giao diện được đối chiếu với Figma End_term, giữ nền lá và các ảnh linh vật mầm cây có sẵn trong `assets/images`. Các màn có dữ liệu Firebase được dựng lại theo từng bố cục riêng; không còn thay toàn bộ màn bằng một danh sách chung.

## Những phần đã chỉnh

- HM: dashboard, lịch học hôm nay, việc cần làm, hoạt động, thông báo và tìm kiếm.
- PL: lịch ngày/tuần/tháng, danh sách kế hoạch, các bước tạo kế hoạch, chi tiết buổi học, nội dung hoàn thành và đánh giá.
- GO: tạo mục tiêu, loại mục tiêu, chỉ tiêu, thời hạn, cột mốc, xem trước và tiến độ.
- AN: tổng quan, thời gian học, nhiệm vụ, môn học, biểu đồ, streak và huy hiệu.
- PR: trang cá nhân, thống kê cá nhân, tùy chọn thông báo và giao diện. Giữ màn sửa hồ sơ và thiết lập tài khoản hiện có.
- Dùng chung font, khoảng cách, thẻ bo góc, nút gradient và thanh điều hướng. Màn dài cuộn được, nút tiếp tục của wizard nằm cố định phía dưới.

## Thêm môn mới

Lịch → Tạo kế hoạch mới → Bắt đầu → Chọn môn học → **Thêm môn học**. Nhập tên và nhóm môn rồi lưu. Môn mới hiện trong danh sách, có thể tìm kiếm, chọn và phân bổ giờ như các môn có sẵn.

Danh mục tự thêm được lưu trong `user/{uid}/settings/editor.values.customSubjects`; mỗi môn có ID riêng. Số giờ nằm trong `values.courseHours`, khóa theo ID môn. Các bước xem trước, tạo lịch và lời nhắc tạo kế hoạch Gemini đều sử dụng danh sách môn đã chọn. Không cần đổi rules hoặc triển khai Cloud Functions.

## Kiểm tra

- Toàn bộ frame có dữ liệu trực tiếp được kiểm tra ở chiều rộng 320 và 390 px, với tài khoản trống và có dữ liệu.
- Kiểm tra thêm môn, tên trùng, tải lại, phân tách UID, phân bổ giờ và tạo lịch cho hai môn tự thêm.
- Ảnh xem trước nằm trong `build/figma_restore/` sau khi chạy `flutter test test/figma_restore_test.dart`.
- Đây là bản khôi phục bố cục và định dạng theo thiết kế; nội dung/số liệu được lấy từ tài khoản thật nên không giống dữ liệu minh họa trong Figma.

Sau khi cập nhật, chạy lại ứng dụng hoặc hot restart (`R`) để tải lại các màn.
