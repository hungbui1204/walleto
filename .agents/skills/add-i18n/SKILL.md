---
name: add-i18n
description: Thêm string localization mới vào Walleto — thêm key vào mọi file ARB hiện có (hiện intl_en_US.arb) đúng format rồi make l10n, dùng qua S.current. Dùng khi user muốn "thêm text/string mới", "thêm i18n key", "dịch chuỗi".
---

# Add i18n key (Walleto)

Thêm chuỗi localization theo `CODING_RULES.md §9`. **Không hard-code string user-facing.**

## 0. Nhận rõ
- Key name (lowerCamelCase, mô tả ý nghĩa: `createWallet`), và nội dung từng locale.
- Hiện **chỉ có `en_US`**. Nếu sau này có thêm locale → thêm cùng key vào **mọi** ARB, không locale nào trống.
- Nếu user chỉ đưa 1 ngôn ngữ trong khi đã có nhiều ARB → hỏi bản dịch còn lại. **Không bỏ trống locale nào.**

## 1. Thêm key vào mọi file ARB
Hiện tại: `lib/resources/l10n/intl_en_US.arb` (main locale — kèm metadata `@key`).

```jsonc
"createWallet": "Create wallet",
"@createWallet": { "description": "Create wallet screen title" }
```

- Giữ JSON hợp lệ (dấu phẩy, ngoặc). Key theo thứ tự nhất quán với file.
- Placeholder: ICU `"{name}"` + khai báo trong `@key.placeholders`.

## 2. Regenerate
```bash
make l10n
```
Sinh code trong `lib/resources/l10n/generated/` — **không sửa tay**.

## 3. Dùng trong UI
```dart
Text(S.current.createWallet)
```

## 4. Verify
```bash
make analyze
```
Phải pass (thiếu key ở 1 locale sẽ báo lỗi khi build/analyze).

## Ràng buộc
- Đủ mọi locale hiện có, không locale nào trống.
- Không sửa file generated. Không commit trừ khi user yêu cầu.
