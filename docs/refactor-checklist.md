# Refactor checklist — Walleto

Checklist theo **thứ tự làm**. Mỗi mục = **một PR nhỏ** (cố gắng < ~400 dòng). Không gộp nhiều phase vào một PR.

Nguồn: review coding rules (2026-08-31). Convention: [CODING_RULES.md](../CODING_RULES.md), [CLAUDE.md](../CLAUDE.md).

**Cách dùng**

- Tick `[x]` khi PR merge.
- Một mục xong: `make analyze` (+ `make testing` nếu có test) phải pass.
- Không commit / push / PR trừ khi được yêu cầu rõ.

**Không làm hàng loạt** (CODING_RULES §7.5): tách widget `_private` trong `home_view.dart` và các màn cũ trừ khi đang đụng đúng feature đó. `AppNavigator` / `AppPopupInfo` giữ Flutter types trong `domain/navigation/` — không xé kiến trúc navigator trong checklist này.

---

## Phase 1 — Rule cứng BLoC (sửa nhanh)

### 1.1 Thêm `transformer: log()` cho mọi handler còn thiếu

- [x] `lib/ui/views/home/bloc/home_bloc.dart` (3 handler)
- [x] `lib/ui/views/transactions/bloc/transactions_bloc.dart` (7 handler)
- [x] `lib/ui/views/create_category/bloc/create_category_bloc.dart` (7 handler)
- [x] `lib/ui/views/edit_wallet/bloc/edit_wallet_bloc.dart` (3 handler)
- [x] `lib/ui/views/categories/bloc/categories_bloc.dart`
- [x] `lib/ui/views/account/bloc/account_bloc.dart`
- [x] `lib/ui/views/select_category/bloc/select_category_bloc.dart`
- [x] `lib/ui/views/select_icon/bloc/select_icon_bloc.dart`
- [x] `lib/ui/views/wallets/bloc/wallets_bloc.dart` — chỉ sửa nếu bloc còn sống; nếu xóa ở 3.1 thì bỏ mục này

**Xong khi:** mọi `on<Event>(...)` trong `lib/ui/**/bloc/` đều có `transformer: log()` (trừ `MainBloc` không có handler).

Tham chiếu đúng: `lib/ui/views/create_wallet/bloc/create_wallet_bloc.dart`.

---

## Phase 2 — Bug hành vi + i18n

### 2.1 Sửa `ErrorWithRetry` không hiện nút Retry

Hiện `ExceptionHandler` gọi `AppPopupInfo.errorWithRetry` (timeout / mất mạng) nhưng mapper map sang `ErrorPopup` (action rỗng). `ErrorWithRetryPopup` gần như toàn comment.

- [x] `lib/ui/navigation/mapper/app_popup_info_mapper.dart` — map `ErrorWithRetry` → `ErrorWithRetryPopup`, truyền `onRetryPressed`
- [x] `lib/ui/widgets/popup/error_with_retry_popup.dart` — implement nút Retry / Cancel bằng `CommonButton` (không để comment `ButtonWidget` cũ)
- [x] Xóa comment chết tương tự trên `error_popup.dart` / `complete_popup.dart` / `warning_popup.dart` nếu đụng cùng PR (hoặc tách PR 2.1b)

**Xong khi:** timeout / no-internet hiện popup có Retry; Retry gọi `doOnRetry`.

### 2.2 i18n sheet chọn currency

- [x] Thêm key `chooseCurrency` vào `lib/resources/l10n/intl_en_US.arb` → `make l10n`
- [x] `lib/ui/widgets/bottom_sheet/choose_currency_bottom_sheet.dart` — đổi `S.current.chooseWallet` → `S.current.chooseCurrency`

---

## Phase 3 — Page / BLoC chết / điều hướng chuẩn

### 3.1 `WalletsView` về `BasePageState`

- [x] `lib/ui/views/wallets/wallets_view.dart` — `_WalletsViewState extends BasePageState<WalletsView, …>`
- [x] Quyết định: **xóa** `WalletsBloc` (view đang đọc `AppBloc`) **hoặc** wire bloc thật (`@injectable`, handler, `transformer: log()`)
- [x] Đã wire `WalletsBloc` (không xóa)
- [x] Đổi `getIt.get<AppNavigator>()` → `navigator` của page

**Xong khi:** `WalletsView` là `BasePageState`; không còn BLoC stub / dead export.

### 3.2 `BudgetsView` (placeholder)

- [ ] `lib/ui/views/budgets/budgets_view.dart` — `BasePageState` + `BudgetsBloc` stub `@injectable` **hoặc** giữ placeholder nhưng ghi chú “làm khi code feature budgets”

Làm sau 3.1; có thể gộp nếu diff vẫn nhỏ.

### 3.3 Bỏ `getIt.get<AppNavigator>()` trên page đã có `BasePageState`

Ưu tiên page/widget đang sống (không comment):

- [x] `lib/ui/views/home/home_view.dart`
- [x] `lib/ui/views/account/account_view.dart`
- [x] `lib/ui/views/transactions/transactions_view.dart`
- [x] `lib/ui/views/create_transaction/create_transaction_view.dart`
- [x] `lib/ui/views/edit_transaction/edit_transaction_view.dart`
- [x] `lib/ui/views/transaction_detail/transaction_detail_view.dart`
- [x] `lib/ui/views/auth/widgets/login_tab.dart`
- [x] `lib/ui/views/reset_password/widgets/reset_password_complete_step_widget.dart`
- [x] `lib/ui/views/select_category/widgets/category_widget.dart`
- [x] `lib/ui/views/select_category/widgets/parent_category_widget.dart`
- [x] Popup / bottom sheet: `choose_currency`, `choose_wallet`, `note_input`, `select_month`, `select_wallet`, `confirm`, `duplicate_transaction`, `error_with_retry`

**Cách:** trong `State` của page dùng `navigator`; widget con dùng `context.read<AppNavigator>()` (`RepositoryProvider` từ `BasePageState`). Popup/sheet được wrap `RepositoryProvider.value` trong `AppPopupInfoMapper`.

### 3.4 `MainView` không cast `AppNavigatorImpl`

- [ ] `lib/ui/views/main/main_view.dart` — bỏ `(navigator as AppNavigatorImpl).tabRoutes` / `tabsRouter =`
- [ ] Đưa `tabRoutes` / set `tabsRouter` vào `AppNavigator` port (hoặc helper UI), không leak impl vào view
- [ ] (Tuỳ chọn cùng PR) chuyển đăng ký FCM từ `initState` sang `MainBloc` / service — **không** copy-paste thêm TODO iOS

---

## Phase 4 — Domain thuần (tách UI khỏi enum)

### 4.1 Tách presentation khỏi `lib/domain/entities/enum/enum.dart`

Domain **không** import `flutter/`, `flutter_svg`, `resources`, không trả `Widget`, không gọi `S.current`.

- [x] `BottomTab.icon()` / `title` → extension UI (`lib/ui/` hoặc `lib/shared/extensions/`)
- [x] `TargetMonth.displayName` → UI / shared
- [x] `SignUpStep` / `ResetPasswordStep` / `BottomTab` → chuyển sang UI (enum màn hình, không phải entity)
- [x] `OperationType.symbol` / `fromString` **không** so với `S.current` — dùng hằng `+` `-` `×` `÷` ở UI (`numeric_keyboard.dart` + create/edit transaction bloc)
- [x] `CategoryType.name` / `TargetMonth.name` (string API `expense` / `this_month`) giữ ở mapper data, không gắn i18n

**Xong khi:** `lib/domain/entities/enum/enum.dart` (hoặc file enum domain mới) không import Flutter/resources.

### 4.2 `SignOutUseCase` không navigate

- [x] `lib/domain/usecases/sign_out_use_case.dart` — chỉ `repository.signOut()`, bỏ inject `AppNavigator`
- [x] `lib/ui/app/bloc/app_bloc.dart` — `replace(AppRouteInfo.login())` sau khi use case thành công

---

## Phase 5 — Design system + copy chết

### 5.1 Hard-code style / màu barrier

- [x] `lib/ui/views/select_category/select_category_popup.dart` — `TextStyle(fontWeight: FontWeight.bold)` → `AppTextStyles`
- [x] `lib/ui/widgets/common_app_bar.dart` — `AppThemes.display(...)` → `AppTextStyles` phù hợp
- [x] `lib/ui/views/auth/login_view.dart` — `AppThemes.display` → `AppTextStyles`
- [x] `lib/domain/navigation/app_navigator.dart` + `lib/ui/navigation/app_navigator_impl.dart` — barrier `Color(0x…)` / `Colors.black54` → `backgroundOverlayColor` (hoặc token hiện có)

Không bắt buộc đổi mọi `Colors.transparent`.

### 5.2 Panel kính thống nhất

- [x] `lib/ui/views/create_category/create_category_popup.dart` — `AppDecorations.glassPanel()` thay `BoxDecoration` phẳng
- [x] `lib/ui/widgets/popup/select_wallet_popup.dart`
- [x] `lib/ui/widgets/popup/duplicate_transaction_popup.dart`

Bottom nav blur (`custom_bottom_navigation_bar.dart`) để riêng — chrome đặc thù, không bắt `glassPanel()`.

**Xong khi:** 3 popup trên dùng `AppDecorations.glassPanel()`; không còn `BoxDecoration` phẳng thay panel kính. Inner fill (`fieldFillColor`) và circle border không đổi.

### 5.3 Magic number / duration (chỉ khi đụng file)

- [x] `lib/ui/views/main/main_view.dart` — `elevation: 4` → `Dimens`
- [x] `lib/ui/views/main/widgets/custom_bottom_navigation_bar.dart` — `sigmaX/Y: 20` → `Dimens` (đã đổi folder `widget/` → `widgets/`)
- [x] Duration `milliseconds: 300/500` — dùng `DurationConstants` nếu đã có hằng tương đương

---

## Phase 6 — Gom duplicate UI (diff lớn — tách PR)

Làm **sau** Phase 3–4 để tránh conflict với extract navigator / enum.

### 6.1 Create / edit transaction dùng widget + helper chung

Không gộp thành một màn. Tách phần trùng:

- [x] Widget chung: amount input, row ví / category / date / note / currency (file `widgets/` public, export `ui.dart`) *(6.1b)* — `TransactionFormPanel` + `TransactionAmountInput` + `TransactionNumericKeyboardSheet` (`lib/ui/widgets/`)
- [x] Helper calculator (split operator, max length, format) — `lib/ui/utils/transaction_amount_calculator.dart` — **một** chỗ, create + edit bloc gọi lại *(6.1a)*
- [x] `create_transaction_view.dart` / `edit_transaction_view.dart` chỉ còn layout + `BasePageState` *(6.1b)*

**Xong khi:** sửa calculator một lần áp dụng cả create và edit *(6.1a)*. Sửa row/amount/keyboard widget một lần áp dụng cả create và edit *(6.1b)*.

### 6.2 Đặt tên lại `Common*2` theo vai trò

Không xóa hành vi; merge API nếu thực sự trùng.

- [x] `CommonButton2` → `CommonChipButton` (`common_chip_button.dart`) — compact secondary chip (`surfaceColor`, nhỏ hơn `CommonButton`)
- [x] `CommonContainer` → `CommonTitledPanel`; `CommonContainer2` → `CommonGlassPanel` — titled panel vs child-only glass panel
- [x] `CommonTextField` giữ (outlined + password/prefix); `CommonTextField2` → `CommonInlineTextField` — collapsed, không border

Cập nhật mọi call site + barrel. Không gộp API vì visual/constructor khác nhau.

### 6.3 Một flow chọn ví

- [ ] So `ChooseWallet` (bottom sheet, ví từ `AppBloc`) vs `SelectWallet` (popup, list truyền vào)
- [ ] Gom UX nếu product cho phép; nếu giữ hai chỗ thì document khác biệt trong comment ngắn trên `AppPopupInfo`

---

## Phase 7 — Dead code / naming / gitignore

### 7.1 Xóa hoặc wire dead export

- [ ] `lib/ui/views/home/widgets/daily_stats_chart.dart` — xóa **hoặc** gắn vào `StatisticWidget` nếu còn nhu cầu
- [ ] Gỡ export `lib/ui/ui.dart` nếu xóa
- [ ] `MainBloc` rỗng: giữ nếu `BasePageState` bắt buộc bloc; nếu 3.4 đã chuyển logic vào đây thì không còn “rỗng”

### 7.2 Typo / folder / gitignore

- [ ] `lib/domain/usecases/duplicate_transaction_use_case.dart` — `respone` → `response`
- [x] `lib/ui/views/main/widget/` → `widgets/` (đổi mọi import)
- [ ] `.gitignore`: `**/resource/gen` → khớp `lib/resources/gen/` (đừng ignore nhầm path)

### 7.3 Barrel import (nice-to-have, PR riêng nếu đụng file)

- [ ] Deep import → barrel: `numeric_keyboard.dart`, `main_view.dart` (`app_route_info`), `select_icon_bloc`, `common_button*.dart` → `pressable`, v.v.

---

## Phase 8 — Bảo mật log (debug)

Không tắt hết log; **redact** field nhạy cảm.

- [ ] `lib/shared/constants/env_constants.dart` — không `Log.d(appApiKey)`
- [ ] `lib/data/api/middleware/custom_log_interceptor.dart` — redact `Authorization`, password, refresh_token, body auth
- [ ] `LoginByPasswordInput` (và event password) — `toString` / log không in password (`@JsonKey` / override `toString` / tắt `enableLogUseCaseInput` cho auth)
- [ ] `lib/ui/base/bloc/app_bloc_observer.dart` — không log nguyên event chứa password

---

## Phase 9 — Test convention (seed, không cover cả app)

CODING_RULES §15: repo chưa có `test/`. Feature **mới** sau này phải có test; seed trước để có mẫu.

- [ ] Thêm `bloc_test` + `mocktail` vào `dev_dependencies` nếu chưa có
- [ ] `test/domain/usecases/get_wallets_use_case_test.dart` (hoặc `create_wallet`) — mock `Repository` local trong file, không `test/helpers/mocks.dart`
- [ ] `test/ui/views/create_wallet/bloc/create_wallet_bloc_test.dart` — harness `BaseBlocDelegate` như §15
- [ ] `make testing` pass

Không viết test giả (assert luôn true). Không cover 32 use case trong một PR.

---

## Phase 10 — TODO product (không phải coding-rule thuần)

Làm khi có requirement, không nhét vào PR refactor.

- [ ] `home_bloc.dart` — đổi currency phải reload month summary (TODO hiện bỏ qua)
- [ ] `app_bloc.dart` — update user default currency API
- [ ] `categories_view.dart` — navigate edit category
- [ ] Push notification iOS — **một** chỗ (không 5 file TODO giống nhau): `main.dart`, `app_config`, `main_view`, `login_bloc`, `walleto_application`

---

## Thứ tự PR đề xuất (copy nhanh)

| # | Mục | Phase |
|---|-----|--------|
| 1 | `transformer: log()` | 1.1 |
| 2 | `ErrorWithRetry` + popup | 2.1 |
| 3 | `chooseCurrency` i18n | 2.2 |
| 4 | `WalletsView` + xóa/wire `WalletsBloc` | 3.1 |
| 5 | `navigator` thay `getIt` (từng cụm file) | 3.3 |
| 6 | Tách UI khỏi `enum.dart` | 4.1 |
| 7 | Sign-out navigate ở BLoC | 4.2 |
| 8 | `AppTextStyles` / barrier / `glassPanel` | 5.x |
| 9 | Shared create/edit transaction widgets | 6.1 |
| 10 | Rename `Common*2` | 6.2 |
| 11 | Dead chart / typo / gitignore | 7.x |
| 12 | Redact logs | 8 |
| 13 | Seed unit test | 9 |

`MainView` / `BudgetsView` / FCM / TODO product: xen sau mục 4–5 khi đụng đúng file.
