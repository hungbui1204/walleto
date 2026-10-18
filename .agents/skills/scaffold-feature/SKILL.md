---
name: scaffold-feature
description: Triển khai một feature Walleto cần phối hợp domain, data và có thể cả UI, từ contract/API đến test. Dùng khi thêm hành vi hoặc endpoint mới xuyên nhiều layer; với UI chỉ dùng add-screen.
---

# Scaffold feature — Walleto

Đọc `CLAUDE.md`, `AGENTS.md`, `CODING_RULES.md` và requirement liên quan nếu có. Hoàn thiện một flow dùng được; "scaffold" không có nghĩa là để placeholder. Giữ `ui → domain ← data`, một `Repository` interface, `get_it` + `injectable`, `dio`/Supabase qua `AppApiServices`, `freezed` và barrel hiện có. Không áp cấu trúc package-per-feature, MVVM, GoRouter hay HTTP client khác từ skill bên ngoài.

## Xác định lát cắt

- Truy vết flow gần nhất từ View/BLoC qua use case, `Repository`, `RepositoryImpl`, API/service và mapper. Dùng `rg --files` trong `lib/domain/`, `lib/data/`, `lib/ui/views/`, `test/` để tìm code tái dùng; đọc contract API thật trước khi quyết định model/endpoint.
- Xác định đây là Future, Stream, local preference/service hay phối hợp nhiều nguồn. Xác định input, output, lỗi, cancellation/retry, route/overlay và dữ liệu nào là số tiền hoặc auth. Hỏi khi contract hoặc product behavior chưa thể suy ra; tiếp tục phần độc lập trước.
- Tham khảo `get_wallets_use_case.dart` + `wallet_data_mapper.dart` cho request thường; `send_ai_chat_message_use_case.dart` + `ai_chat/` cho stream. Chọn mẫu theo behavior, không tạo entity/model/mapper chỉ vì checklist.

## Domain → data → UI khi cần

1. **Domain:** dùng entity hiện có hoặc thêm entity thuần Dart khi contract cần. Thêm method vào `lib/domain/repositories/repository.dart`; không tạo repo mới nếu user không yêu cầu thay kiến trúc. Use case `@injectable` ở `lib/domain/usecases/` dùng `BaseFutureUseCase` hoặc `BaseStreamUseCase` đúng kết quả; I/O theo pattern `BaseInput`/`BaseOutput` của repo. Đặt business rule tại domain, không trong widget hoặc `*Data` model. Export public file trong `lib/domain/domain.dart`.
2. **Data:** cập nhật `AppApiServices`/service thích hợp, `RepositoryImpl` (`@LazySingleton(as: Repository)`) và mapper/model cần thiết. Model `*Data` chỉ ở data layer; dùng `freezed`/JSON generation khi contract cần. Mapper `@injectable` theo `BaseDataMapper`, thêm `DataMapperMixin` khi cần map hai chiều. JSON/field nullable theo response thật; dùng default null-safe hợp lý, không che thiếu field bắt buộc hoặc leak `*Data` ra domain. Tìm đúng client Auth/Rest/Functions/Storage, giữ xử lý token/error/logging sẵn có. Export public file trong `lib/data/data.dart`.
3. **UI nếu feature có màn:** áp dụng `add-screen` cho View/BLoC, widget, route hoặc overlay, i18n và test. Nếu feature chỉ là data/domain, không dựng màn giả hoặc route không dùng.

## Test và verify

- Thêm/cập nhật test mirror `lib/` cho behavior mới hoặc bug fix: use case (kết quả, lỗi), mapper/parser khi có biến đổi, BLoC (state, side effect, retry/concurrency) và widget khi tương tác UI cần kiểm chứng. Với stream, kiểm tra thứ tự event, cancellation và lỗi phù hợp. Kiểm tra contract `BaseFutureUseCase.execute`: `AppException` giữ nguyên, lỗi khác được wrap theo base class. Dùng `mocktail`, `bloc_test`, `flutter_test` hiện có; tham khảo test cùng layer thay vì tạo helper/mock package chung mới.
- Chạy `make force_build` khi đổi `freezed`, JSON generation, injectable hoặc route. Chạy `make l10n` khi đổi ARB. Không sửa generated file bằng tay; format đúng file Dart đã chạm bằng `fvm dart format <file...>`.
- Chạy `make verify` (`analyze`, `format_check`, `testing`), rồi tự review bằng `walleto-code-review` và `walleto-bloc-check`; thêm `walleto-security-review` khi thay đổi auth, giao dịch, dữ liệu tài chính, storage hoặc network nhạy cảm. Nêu rõ kiểm tra chưa chạy được. Không tự commit/push/PR hay thêm dependency lớn ngoài yêu cầu.

## Nguồn tham khảo bổ trợ

- [Flutter Agent Plugins](https://github.com/flutter/agent-plugins)
- [Dart unit test workflow](https://github.com/dart-lang/skills/blob/main/skills/dart-add-unit-test/SKILL.md)
- [VGV BLoC testing](https://github.com/VeryGoodOpenSource/vgv-ai-flutter-plugin/blob/main/skills/bloc/SKILL.md)
- [Flutter app workflow (discovery-first)](https://github.com/thienqo/flutter-skills/blob/main/skills/flutter-app-workflow/SKILL.md)
