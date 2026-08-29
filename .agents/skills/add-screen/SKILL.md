---
name: add-screen
description: Code một màn hình STG-VT end-to-end — dựng khung (view + BLoC event/state + route + barrel) → code UI theo design system (app_colors/AppTextStyles/Dimens.responsive(), tái sử dụng component design_system) → i18n 3 locale → codegen → analyze. Tự áp dụng Clean Architecture + coding rules. Dùng khi user muốn "code/thêm màn hình", "tạo screen/page", "làm giao diện + logic màn X", "style/ráp UI màn hình".
---

# Add screen (STG-VT) — end-to-end

Skill "ô dù" để code trọn một màn hình: **cấu trúc + UI + i18n**, luôn tuân thủ Clean Architecture (`ui → domain ← data`) và custom lint. Bám `CODING_RULES.md §7` (BLoC/View), §8 (design system), §9 (i18n), §10 (navigation).

> Nếu màn hình cần **API/use case mới** (backend) → làm domain+data trước bằng skill `scaffold-feature`, rồi quay lại đây cho phần UI.
> Nếu khung màn đã có, chỉ cần **code/style UI** → nhảy thẳng Bước 3–4.

## 0. Trước khi bắt đầu
- Nhận rõ: tên screen, feature nhóm nó, dữ liệu/use case cần, có protected route (auth) không, design/Figma nếu có.
- Đọc `docs/requirements/<screen>.md` nếu có; xem `docs/designs/DESIGN.md` nếu style theo design.
- **Mở màn mẫu để bắt chước pattern:** `lib/ui/views/change_password/` (1 màn, view mỏng + widget con + bloc inject use case), `lib/ui/views/home/` (nhiều widget con), `lib/ui/views/auth/login/` (feature nhiều màn).

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

**Feature nhiều màn hình** (vd `auth/`) — mỗi màn 1 thư mục con `<feature>/<screen>/`:
```
lib/ui/views/auth/login/     lib/ui/views/auth/register/   …   (mỗi thư mục có bloc/ · widgets/ · <screen>_view.dart)
```
> `<screen>` dưới đây = tên thư mục lá (với feature 1 màn thì `<screen>` == `<feature>`).

## 2. BLoC + Event/State
- BLoC extend `BaseBloc<<Screen>Event, <Screen>State>`, `@injectable`, inject use case qua constructor (**không** gọi repository/API trực tiếp).
- Handler: `on<<Screen>Event>(_handler, transformer: log())`.
- **Mọi `emit` async bọc `runBlocCatching(action: ...)`** (lint bắt buộc).
- Event: `sealed class <Screen>Event extends BaseBlocEvent`; mỗi event `@freezed sealed class`. Tên theo **ý định** (`<Screen>PageInitiated`, `<Screen>SubmitPressed`), không theo implementation.
- State: `@freezed sealed class <Screen>State extends BaseBlocState`.

## 3. View + UI (design system)

### 3.1 View
- `@RoutePage()` trên `StatefulWidget`; state extend `BasePageState<<Screen>View, <Screen>Bloc>`.
- `initState` → `bloc.add(const <Screen>PageInitiated())`.

### 3.2 Tái sử dụng component design_system (ưu tiên #1 — đừng dựng lại)

**Bắt buộc chạy trước khi tự viết widget mới:**

```bash
ls lib/ui/widgets/design_system/ lib/ui/widgets/
```

Repo có sẵn hơn 20 component (button, glass card, text field, password field, app bar, shimmer/skeleton, refresh indicator, ambient background, network image, popup…). Tên file `app_<tên>_widget.dart` → class `App<Tên>Widget`; mở file để xem constructor param trước khi dùng.

> Skill này **cố tình không liệt kê danh sách widget** — danh sách đổi mỗi sprint và bản chép tay sẽ stale (đã từng lệch 11/21). Luôn `ls` rồi mới kết luận "chưa có".

### 3.3 Styling — KHÔNG hard-code (lint bắt buộc)
| Thành phần | Dùng | Cấm | Tra danh sách |
|------------|------|-----|---------------|
| Màu | constant từ `app_colors.dart` | `Color(0xFF…)` | `grep '^const' lib/resources/styles/app_colors.dart` |
| Text | method `AppTextStyles` — semantic (`bodyMd()`) hoặc legacy (`s14w700ActionOrange()`) | `TextStyle(...)` | `grep 'static TextStyle' lib/resources/styles/app_text_styles.dart` |
| Spacing/size/radius | `Dimens.dXX.responsive()` (tuỳ chọn `tablet:`, `ultraTablet:`) | `16`, `EdgeInsets.all(16)` |
| Assets | `Assets.images.xxx` (flutter_gen) | path string |
| String | `context.s.<key>` (xem Bước 5) | text trần |

```dart
Container(
  padding: EdgeInsets.all(Dimens.d16.responsive()),
  decoration: BoxDecoration(
    color: pitchBlack,
    borderRadius: BorderRadius.circular(Dimens.d12.responsive()),
  ),
  child: Text(context.s.changePasswordTitle, style: AppTextStyles.headlineMd()),
)
```

### 3.4 Kết nối state — bắt buộc buildWhen/listenWhen
- `BlocBuilder` → `buildWhen` (chỉ rebuild khi field liên quan đổi); tách builder nhỏ theo từng phần UI.
- `BlocListener` → `listenWhen` (snackbar, navigate, popup).
- `BlocConsumer` → cả hai.

```dart
BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
  buildWhen: (p, c) => p.isSubmitEnabled != c.isSubmitEnabled,
  builder: (context, state) => /* ... */,
)
```

### 3.5 Tách widget — **bắt buộc** (mỗi widget con 1 file trong `widgets/`)
- `*_view.dart` **chỉ giữ** `<Screen>View` + `_<Screen>ViewState` + `buildPage` (lắp ráp layout tổng). **Mọi khối UI con** (header, card, section, row, panel, field, banner, empty/loading/error state, painter…) **tách ra file riêng** — đừng để widget con inline trong view.
- 1 widget = 1 file `widgets/<screen>_<component>_widget.dart`; class **public** `<Screen><Component>Widget` (file riêng phải public để import qua barrel). `State` con giữ `_private` cùng file.
- Export file mới vào `lib/ui/ui.dart` (đúng thứ tự alphabet block view đó); widget/view tham chiếu nhau qua barrel.
- Widget con **stateless** khi có thể, nhận data qua constructor; **không** load data / gọi use case trong widget con — chỉ hiển thị + bắn event qua callback. `BlocBuilder`/`Listener` trong widget con vẫn cần `buildWhen`/`listenWhen`.
- Màn mẫu: `lib/ui/views/home/`, `lib/ui/views/train/` (view mỏng, mọi phần trong `widgets/<screen>_*_widget.dart`). Không để lại widget dead-code trong `widgets/`.

### 3.6 Responsive
- Mọi `Dimens` gọi `.responsive()`. Layout co giãn ưu tiên `Expanded`/`Flexible`/`Wrap`, tránh kích thước cứng.

## 4. Route
- Thêm `AutoRoute(page: <Screen>Route.page)` vào `lib/ui/navigation/routes/app_router.dart`.
- Protected → `AuthRouteGuard`. Navigate qua `AppNavigator`/`AppRouteInfo`, không `Navigator.push` thô.

## 5. i18n (mọi string user-facing)
Thêm key vào **cả 3 file ARB** `lib/resources/l10n/intl_{ja_JP,en_US,ko_KR}.arb` (metadata `@key` đặt ở `intl_ja_JP.arb`), rồi:
```bash
make l10n
```
Dùng `context.s.<key>`. Không locale nào được trống. (Chi tiết: skill `add-i18n`.)

## 6. Codegen + verify + barrel
```bash
make force_build_all   # freezed + injectable + *.gr.dart
make verify            # analyze + lint + format_check + testing — đều phải pass
```
> ⚠️ `make analyze` một mình **KHÔNG** bắt custom lint (hard-code color/style, thiếu `buildWhen`, thiếu `runBlocCatching`…) — plugin chỉ chạy khi `dart analyze` nhận path file cụ thể. Đang dev thì kiểm nhanh bằng `fvm dart analyze <file vừa sửa>`.

Export view/widget public vào `lib/ui/ui.dart`.

## 7. Test (bắt buộc — `AGENTS.md §0 mục 10`)
- BLoC: `test/ui/views/<feature>/bloc/<feature>_bloc_test.dart` — dựng bloc qua constructor thật (mock use case), cascade-assign field `BaseBlocDelegate` (`navigator`/`disposeBag`/`appBloc`/`commonBloc`/`exceptionHandler`/`exceptionMessageMapper`), `blocTest()` cho happy path + case lỗi. Bám file mẫu `test/ui/views/home/bloc/home_bloc_test.dart`.
- View: chỉ bắt buộc nếu view có logic đáng kể (conditional render theo state, gesture...) — page `BasePageState` thì register mock vào `getIt` (xem `test/ui/views/home/home_view_test.dart`).
- Mock: `class _MockX extends Mock implements X {}` khai báo local trong file test — không dùng helper mock dùng chung.
- Chạy `make testing`, phải pass. Chi tiết convention + gotcha: `CODING_RULES.md §15`.

---

## Checklist trước khi báo xong
- [ ] Đã `ls lib/ui/widgets/design_system/` trước khi viết widget mới — không dựng lại cái đã có
- [ ] Layer đúng: UI không import `data/`, chỉ gọi use case qua BLoC
- [ ] `runBlocCatching` cho mọi emit async · `buildWhen`/`listenWhen` đầy đủ
- [ ] Dùng lại component `design_system` khi có
- [ ] 0 hard-code color/text style/magic number/string · `.responsive()` trên mọi Dimens
- [ ] Widget con stateless, không tự load data
- [ ] i18n đủ 3 locale + `make l10n`
- [ ] Route đăng ký · export barrel · `make force_build_all` · `make analyze` pass
- [ ] Unit test cho bloc (+ view nếu có logic đáng kể) đã tạo/cập nhật — `make testing` pass
- [ ] Không commit trừ khi user yêu cầu
