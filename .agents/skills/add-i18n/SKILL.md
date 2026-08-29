---
name: add-i18n
description: Thêm string localization mới vào STG-VT — thêm key vào cả 3 file ARB (ja_JP, en_US, ko_KR) đúng format rồi make l10n, dùng qua context.s. Dùng khi user muốn "thêm text/string mới", "thêm i18n key", "dịch chuỗi".
---

# Add i18n key (STG-VT)

Thêm chuỗi localization theo `CODING_RULES.md §9`. **Không hard-code string user-facing.**

## 0. Nhận rõ
- Key name (lowerCamelCase, mô tả ý nghĩa: `paywallPurchaseFailed`), và nội dung 3 locale.
- Nếu chỉ có 1 ngôn ngữ → hỏi user bản dịch còn lại, hoặc dùng bản ja_JP làm gốc + đánh dấu cần dịch. **Không bỏ trống locale nào.**

## 1. Thêm key vào cả 3 file ARB
`lib/resources/l10n/intl_ja_JP.arb` · `intl_en_US.arb` · `intl_ko_KR.arb`

Mỗi file thêm **cùng key**, giá trị theo locale. Metadata `@key` (description) đặt ở file gốc `intl_ja_JP.arb`:

```jsonc
// intl_ja_JP.arb  (main locale — kèm metadata)
"retry": "再試行",
"@retry": { "description": "Retry button label" }

// intl_en_US.arb
"retry": "Retry",

// intl_ko_KR.arb
"retry": "다시 시도",
```

- Giữ đúng JSON hợp lệ (dấu phẩy, ngoặc). Key theo thứ tự nhất quán với file.
- Placeholder (nếu có): dùng cú pháp ICU `"{name}"` + khai báo trong `@key.placeholders`.

## 2. Regenerate
```bash
make l10n
```
Sinh code trong `lib/resources/l10n/generated/` — **không sửa tay**.

## 3. Dùng trong UI
```dart
Text(context.s.retry)
```

## 4. Verify
```bash
make analyze
```
Phải pass (thiếu key ở 1 locale sẽ báo lỗi khi build/analyze).

## Ràng buộc
- Đủ 3 locale, không locale nào trống.
- Không sửa file generated. Không commit trừ khi user yêu cầu.
