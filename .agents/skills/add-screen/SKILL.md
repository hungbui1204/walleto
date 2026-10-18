---
name: add-screen
description: Thêm hoặc hoàn thiện màn hình, tab, popup hay bottom sheet trong Walleto khi data/use case đã có. Dùng cho UI và BLoC của một flow; nếu cần API/use case mới, dùng scaffold-feature cho toàn bộ lát cắt.
---

# Add screen — Walleto

Đọc `CLAUDE.md`, `AGENTS.md` và phần liên quan trong `CODING_RULES.md` trước khi sửa. Các file đó quyết định kiến trúc và quyền ghi; ví dụ của skill chỉ là điểm khởi đầu. Làm xong một flow hoạt động được, không để widget, route hoặc BLoC mới thành dead code.

## Khảo sát flow hiện có

- Đọc yêu cầu trong `docs/requirements/` nếu có; xác định đây là màn được route, tab con, popup/bottom sheet, hay chỉnh một màn đã tồn tại. Tra `lib/ui/views/`, màn lân cận, `lib/ui/widgets/`, styles trong `lib/resources/`, ARB và test tương ứng trước khi tạo file.
- Kiểm tra dữ liệu và use case đã tồn tại trong `lib/domain/`. Nếu behavior cần API, model, mapper hoặc use case mới, xử lý lát cắt đó bằng `scaffold-feature`; không cho View/BLoC gọi `Repository` hay `AppApiServices` trực tiếp.
- Dùng `rg --files` và `rg` để tra nguồn thật. `create_wallet/` minh họa page + BLoC; `ai_chat/` minh họa stream, widget tách file và trạng thái phức tạp. Không chép các widget inline cũ làm mẫu cho code mới.

## Dựng đúng loại UI

- **Page có route:** đặt View trong `lib/ui/views/<feature>/`, BLoC và các `part` event/state trong `bloc/` khi có state/logic. `@RoutePage()` và `BasePageState<View, Bloc>` theo page lân cận. Đăng ký `AppRouter`; nếu flow điều hướng bằng `AppNavigator`, cập nhật cả `AppRouteInfo` và `AppRouteInfoMapper`. Chọn nhánh tab, guard, path và `hideBottomNav` theo hành vi thực tế; một View có thể xuất hiện dưới nhiều tab.
- **Popup/bottom sheet:** theo `AppPopupInfo` và `AppPopupInfoMapper`, xem `select_category/` hoặc `create_category/`. Không thêm `AutoRoute` cho overlay. Chỉ thêm BLoC khi flow cần quản lý state/async.
- **Màn đã có:** sửa đúng widget, BLoC và route chịu tác động; không scaffold lại toàn màn hay refactor phần không liên quan.
- Code UI mới: View giữ lifecycle và lắp ráp bố cục; khối UI con có ý nghĩa đặt trong `widgets/<screen>_<component>_widget.dart` với class public theo `CODING_RULES.md §7.5`. Export public file mới qua `lib/ui/ui.dart` và bảo đảm nó được dùng thật.

## State, UI và tương tác

- BLoC `@injectable` dùng use case qua constructor, `BaseBloc`, event/state `freezed` theo màn lân cận. Event mang ý định người dùng. Với async handler, đặt `emit` trong `runBlocCatching` và kiểm tra loading, error, retry, huỷ/lifecycle. Đăng ký event với `transformer: log()` theo mặc định của repo; nếu cần chặn request trùng như `AiChatBloc` dùng `exhaustMap()`, chứng minh ngữ nghĩa concurrency bằng test.
- `BlocBuilder`, `BlocListener`, `BlocConsumer` có `buildWhen`/`listenWhen` tương ứng. Navigation và side effect không đặt trong `builder` có thể chạy lại.
- Tái dùng `Pressable`, `CommonListRow`, form control, panel, shimmer, popup và bottom sheet sẵn có sau khi xem constructor. Dùng `app_colors.dart`, `AppTextStyles`, `AppDecorations` và `Dimens.dXX.responsive()` thay vì màu, style, string hoặc kích thước tự đặt. `app_colors.dart` hiện có palette **light và dark**; kiểm tra cả hai theme, không giả định mọi bề mặt luôn nền tối. `NoirScaffoldBody` là component hiện có, dùng khi phù hợp với màn lân cận.
- Khi UI thay đổi, kiểm tra trạng thái loading/empty/error, màn nhỏ, bàn phím, text scale, semantic label và vùng chạm của control quan trọng. Có thể tham khảo hướng dẫn widget test của Flutter ở cuối file, nhưng giữ harness của Walleto.
- String hiển thị và nhãn accessibility dùng `S.current`; áp dụng `add-i18n` khi có key mới.

## Kiểm chứng và bàn giao

1. Thêm/cập nhật test trong `test/` mirror `lib/`: BLoC và logic mới phải có test hành vi; widget test khi tương tác, layout hoặc nhánh state là phần cần bảo vệ. Dùng `bloc_test`, `mocktail`, `flutter_test` đã có. Với BLoC, tham khảo `test/ui/views/create_wallet/bloc/create_wallet_bloc_test.dart` để gắn các delegate (`navigator`, `disposeBag`, `appBloc`, `commonBloc`, exception handler); với `BasePageState` widget test, đăng ký mock vào `getIt` và dọn trong `tearDown`. Xem thêm `CODING_RULES.md §15`.
2. Chạy `make force_build` khi thay đổi `freezed`, DI hoặc `auto_route`; chạy `make l10n` nếu đổi ARB. Không sửa file generated bằng tay.
3. Format đúng file Dart đã sửa bằng `fvm dart format <file...>`, rồi `make verify`. Nếu verify bị chặn bởi thay đổi khác trong working tree, báo rõ lệnh và lỗi thay vì sửa ngoài scope.
4. Tự review diff bằng `walleto-code-review`; thêm `walleto-bloc-check` khi đổi BLoC/layer, và `walleto-security-review` khi flow chạm auth, tiền, storage hoặc network nhạy cảm. Không tự commit/push/PR.

## Nguồn tham khảo bổ trợ

- [Flutter widget testing](https://github.com/flutter/agent-plugins/blob/main/skills/flutter-add-widget-test/SKILL.md)
- [Flutter layout troubleshooting](https://github.com/flutter/agent-plugins/blob/main/skills/flutter-fix-layout-issues/SKILL.md)
- [VGV testing](https://github.com/VeryGoodOpenSource/vgv-ai-flutter-plugin/blob/main/skills/testing/SKILL.md)
