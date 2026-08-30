---
name: add-screen
description: Code một màn hình Walleto end-to-end — dựng khung (view + BLoC event/state + route + barrel) → code UI theo design system (app_colors/AppTextStyles/Dimens.responsive(), tái sử dụng lib/ui/widgets) → i18n ARB → codegen → analyze. Tự áp dụng Clean Architecture + coding rules. Dùng khi user muốn "code/thêm màn hình", "tạo screen/page", "làm giao diện + logic màn X", "style/ráp UI màn hình".
---

# Add screen (Walleto) — end-to-end

Skill "ô dù" để code trọn một màn hình: **cấu trúc + UI + i18n**, luôn tuân thủ Clean Architecture (`ui → domain ← data`). Bám `CODING_RULES.md §7` (BLoC/View), §8 (design system), §9 (i18n), §10 (navigation).

> Nếu màn hình cần **API/use case mới** → làm domain+data trước bằng skill `scaffold-feature`, rồi quay lại đây cho phần UI.
> Nếu khung màn đã có, chỉ cần **code/style UI** → nhảy thẳng Bước 3–4.

## 0. Trước khi bắt đầu
- Nhận rõ: tên screen, feature nhóm nó, dữ liệu/use case cần, có protected route (auth) không, design/Figma nếu có.
- Đọc `docs/requirements/<screen>.md` nếu có.
- **Mở màn mẫu để bắt chước pattern:** `lib/ui/views/create_wallet/` (1 màn + bloc inject use case), `lib/ui/views/home/` (nhiều section), `lib/ui/views/auth/` (nhiều bước).

---

## 1. Cấu trúc thư mục

**Feature 1 màn hình** (mặc định) — file nằm THẲNG trong `<feature>/`, **KHÔNG** lồng `<feature>/<feature>/`:
```
lib/ui/views/<feature>/
├── bloc/
│   ├── <feature>_bloc.dart      # extend BaseBloc, @injectable
│   ├── <feature>_event.dart     # part of bloc; sealed extends BaseBlocEvent
│   └── <feature>_state.dart     # part of bloc; @freezed sealed extends BaseBlocState
├── widgets/
│   └── <feature>_<component>_widget.dart
└── <feature>_view.dart          # @RoutePage(), extend BasePageState
```

**Feature nhiều màn / nhiều bước** (vd `auth/`) — nhóm trong `lib/ui/views/<feature>/`.

> `<screen>` dưới đây = tên thư mục lá (với feature 1 màn thì `<screen>` == `<feature>`).

## 2. BLoC + Event/State
- BLoC extend `BaseBloc<<Screen>Event, <Screen>State>`, `@injectable`, inject use case qua constructor (**không** gọi `Repository`/API trực tiếp).
- Handler: `on<<Screen>Event>(_handler, transformer: log())`.
- **Mọi `emit` async bọc `runBlocCatching(action: ...)`**.
- Event: `sealed class <Screen>Event extends BaseBlocEvent`; mỗi event `@freezed sealed class`. Tên theo **ý định** (`<Screen>ViewInitiated`, `<Screen>ConfirmButtonPressed`).
- State: `@freezed sealed class <Screen>State extends BaseBlocState`.

## 3. View + UI (design system)

### 3.1 View
- `@RoutePage()` trên `StatefulWidget`; state extend `BasePageState<<Screen>View, <Screen>Bloc>`.
- `initState` → `bloc.add(const <Screen>ViewInitiated())`.
- Body: `NoirScaffoldBody`. App bar: `CommonAppBar`.

### 3.2 Tái sử dụng widget dùng chung (ưu tiên #1)

**Bắt buộc chạy trước khi tự viết widget mới:**

```bash
ls lib/ui/widgets/ lib/ui/widgets/popup/ lib/ui/widgets/bottom_sheet/
```

Có sẵn CommonButton, CommonAppBar, CommonTextField, NoirScaffoldBody, popup, bottom sheet, shimmer, empty panel… Mở file để xem constructor trước khi dùng.

> Skill này **cố tình không liệt kê danh sách widget**. Luôn `ls` rồi mới kết luận "chưa có".

### 3.3 Styling — KHÔNG hard-code
| Thành phần | Dùng | Cấm | Tra danh sách |
|------------|------|-----|---------------|
| Màu | constant từ `app_colors.dart` | `Color(0xFF…)` | `grep '^const' lib/resources/styles/app_colors.dart` |
| Text | `AppTextStyles.s18wBoldBlack()` | `TextStyle(...)` | `grep 'static TextStyle' lib/resources/styles/app_text_styles.dart` |
| Panel kính | `AppDecorations.glassPanel()` | `BoxDecoration` glass tự bịa | `app_decorations.dart` |
| Spacing/size | `Dimens.dXX.responsive()` | `16`, `EdgeInsets.all(16)` |
| Assets | `Assets.images.xxx` | path string |
| String | `S.current.<key>` | text trần |

```dart
Container(
  padding: EdgeInsets.all(Dimens.d16.responsive()),
  decoration: AppDecorations.glassPanel(),
  child: Text(S.current.createWallet, style: AppTextStyles.s18wBoldBlack()),
)
```

### 3.4 Kết nối state — bắt buộc buildWhen/listenWhen
- `BlocBuilder` → `buildWhen`; `BlocListener` → `listenWhen`; `BlocConsumer` → cả hai.

### 3.5 Tách widget (code mới)
- `*_view.dart` chỉ giữ View + State + `buildPage`. Khối UI con → `widgets/<screen>_<component>_widget.dart`, class **public**.
- Export vào `lib/ui/ui.dart`. Widget con **stateless** khi có thể; không load data / gọi use case.
- Màn cũ có thể còn widget `_private` cùng file — đừng refactor hàng loạt trừ khi task yêu cầu.

### 3.6 Responsive
- Mọi `Dimens` gọi `.responsive()`. Ưu tiên `Expanded`/`Flexible`/`Wrap`.

## 4. Route
- Thêm `AutoRoute(page: <Screen>Route.page)` vào `lib/ui/navigation/routes/app_router.dart`.
- Nested tab cần ẩn bottom nav → `meta: const {'hideBottomNav': true}`.
- Protected → `AuthRouteGuard`. Navigate qua `AppNavigator`/`AppRouteInfo`.

## 5. i18n
Thêm key vào **mọi** ARB hiện có (`lib/resources/l10n/intl_en_US.arb`), rồi `make l10n`. Dùng `S.current.<key>`. (Chi tiết: skill `add-i18n`.)

## 6. Codegen + verify + barrel
```bash
make force_build       # freezed + injectable + *.gr.dart
make verify            # analyze + format_check + testing
```
Export view/widget public vào `lib/ui/ui.dart`.

## 7. Test (bắt buộc — `CLAUDE.md §0 mục 10`)
- BLoC: `test/ui/views/<feature>/bloc/<feature>_bloc_test.dart` — constructor thật + mock use case, cascade-assign `BaseBlocDelegate` (`navigator`/`disposeBag`/`appBloc`/`commonBloc`/`exceptionHandler`/`exceptionMessageMapper`), `blocTest()` happy path + lỗi.
- View: chỉ bắt buộc nếu view có logic đáng kể. Page `BasePageState` → register mock vào `getIt`.
- Mock: `class _MockX extends Mock implements X {}` local trong file test.
- Nếu chưa có `bloc_test`/`mocktail` → thêm `dev_dependencies` khi viết test đầu tiên.
- `make testing` phải pass. Chi tiết: `CODING_RULES.md §15`.

---

## Checklist trước khi báo xong
- [ ] Đã `ls lib/ui/widgets/` trước khi viết widget mới
- [ ] Layer đúng: UI không import `data/`, chỉ gọi use case qua BLoC
- [ ] `runBlocCatching` · `transformer: log()` · `buildWhen`/`listenWhen`
- [ ] 0 hard-code color/text style/magic number/string · `.responsive()` trên mọi Dimens
- [ ] Widget con không tự load data
- [ ] i18n ARB + `make l10n`
- [ ] Route đăng ký · export barrel · `make force_build` · `make analyze` pass
- [ ] Unit test bloc (+ view nếu cần) — `make testing` pass
- [ ] Không commit trừ khi user yêu cầu
