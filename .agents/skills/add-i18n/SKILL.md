---
name: add-i18n
description: Thêm hoặc sửa chuỗi hiển thị và nhãn accessibility của Walleto trong ARB hiện có, sinh lại intl_utils và cập nhật chỗ dùng S.current. Dùng khi một UI flow cần copy, placeholder hoặc bản dịch mới.
---

# Add i18n — Walleto

Đọc `CLAUDE.md` và `CODING_RULES.md §9` trước khi sửa. Repo dùng `intl_utils` (`make l10n`) và `S.current`, không dùng hướng dẫn `flutter gen-l10n`/`context.l10n` từ project khác.

1. Tra `lib/resources/l10n/intl_*.arb` và `S.current` để tìm key cùng ý nghĩa trước khi tạo key mới. Chọn key lowerCamelCase theo vai trò của text, tránh key theo vị trí hoặc bản dịch hiện tại.
2. Thêm/sửa key trong **mọi ARB hiện có**. Tại `intl_en_US.arb` đặt `@key.description` mô tả ngữ cảnh cho copy mới. Với chuỗi có tham số, xem cú pháp placeholder và metadata của các key đang dùng rồi xác nhận API được sinh ra sau `make l10n`. Giữ cấu trúc JSON và cách nhóm key của file. Với locale khác, cung cấp bản dịch có nghĩa; hỏi user chỉ khi thuật ngữ sản phẩm hoặc bản dịch bắt buộc chưa được xác định.
3. Dùng `S.current.<key>` ở View/widget hoặc nơi phù hợp; truyền chuỗi đã localize vào widget chung khi widget không nên phụ thuộc trực tiếp vào l10n. Nhãn screen reader và thông báo lỗi user-facing cũng cần key.
4. Chạy `make l10n`, không sửa `lib/resources/l10n/generated/` bằng tay. Nếu có Dart thay đổi, format đúng file vừa sửa; chạy `make analyze` và test liên quan đến copy/placeholder nếu behavior phụ thuộc vào chúng.

Hiện repo có `intl_en_US.arb`; luôn khám phá lại trước mỗi task thay vì giả định chỉ có một locale. Không tự commit/push/PR.
