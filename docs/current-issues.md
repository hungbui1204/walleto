# Issue hiện tại — Walleto

Review source Flutter + Android + iOS (2026-09-12). File này **tách bug** (hành vi sai / crash / số liệu sai) và **tính năng chưa hoàn thiện** (UI đã hiện nhưng chưa làm, hoặc mới stub).

**Cập nhật 2026-09-12:** bug P0/P1/P2 trong mục 1 đã fix. Một số UI dở được **ẩn hoặc nối** (không implement full feature). Mục còn `[ ]` là việc chủ ý chưa làm (edit category/wallet, social/Terms, push iOS, pagination, flavor ID, …).

Nền tảng Clean Architecture + BLoC nhìn chung ổn. App **chưa sẵn sàng production** vì native store (flavor ID, screen security, iOS push) và vài feature còn stub.

**Cách dùng**

- Tick `[x]` khi đã fix / ship.
- Bug nên sửa trước tính năng mới.
- Không commit / push / PR trừ khi được yêu cầu rõ.

Liên quan: [CODING_RULES.md](../CODING_RULES.md) · [refactor-checklist.md](refactor-checklist.md)

---

## Mục lục

1. [Bug](#1-bug)
2. [Tính năng chưa hoàn thiện](#2-tính-năng-chưa-hoàn-thiện)
3. [Nợ kỹ thuật](#3-nợ-kỹ-thuật) (không phải bug sản phẩm, cũng chưa phải feature)

---

## 1. Bug

Hành vi **sai so với kỳ vọng hiện tại**: crash, số tiền sai, filter sai, data không refresh, cấu hình native tự triệt tiêu.

### 1.1 Crash — P0

#### Không có ví → Create Transaction / tab Transactions crash

User đã login nhưng chưa có ví (ví dụ signup rồi kill app trước khi tạo ví). Cold start vào Main vì `LoadInitialResourceUseCase` chỉ check `isLoggedIn`, không check ví.

- FAB luôn hiện, không guard: `lib/ui/views/main/main_view.dart`
- Create Transaction: `appBloc.state.wallets.first` / `currencies.first` → `StateError: No element`  
  `lib/ui/views/create_transaction/bloc/create_transaction_bloc.dart`
- Tab Transactions cũng `.first` trên list rỗng: `lib/ui/views/transactions/bloc/transactions_bloc.dart`
- Edit Transaction `orElse: () => wallets.first`: `lib/ui/views/edit_transaction/bloc/edit_transaction_bloc.dart`

**Fix gợi ý:** cold start không có ví → Create Wallet; ẩn/disable FAB; không gọi `.first` trên list rỗng.

- [x] Guard empty wallets / currencies trên create + edit + transactions list
- [x] Cold start: logged in + 0 ví → Create Wallet, không vào Main
- [x] Ẩn hoặc disable FAB khi chưa có ví

#### Data-only FCM crash (Android)

`LocalNotificationService.notify` force-unwrap `message.notification!`. Tin nhắn chỉ có `data` sẽ crash.

- `lib/ui/helper/local_notification_service.dart`

- [x] Null-check `notification`; bỏ qua hoặc dùng `data` title/body

### 1.2 Số liệu sai — P0

#### Home “Total balance” cộng nhiều loại tiền, không quy đổi

Hero cộng `wallet.amount` raw, ký hiệu lấy `wallets.first.currencyCode`. Ví VND + USD ra tổng vô nghĩa. Chart tháng thì có base currency; hero không.

- `lib/ui/views/home/home_view.dart`

- [x] Quy đổi về default/base currency trước khi cộng (dùng FX hiện có)

#### Day total trên list giao dịch không quy đổi FX

Cộng `transaction.amount` theo income/expense. Nhiều ví / nhiều currency trong cùng ngày → tổng sai. `currencyCode` lấy từ giao dịch đầu tiên trong ngày.

- `lib/ui/views/transactions/bloc/transactions_bloc.dart` (`_getDayTransFromTrans`)

- [x] Quy đổi về currency của filter / default currency trước khi cộng

#### Đổi currency mặc định không persist

Chỉ `emit` local. Có TODO `update user default currency API`. Mở lại app bị ghi đè từ `get_user_base_currency`. Home stats và hero có thể lệch.

- `lib/ui/app/bloc/app_bloc.dart`

- [x] API + repo + use case cập nhật default currency
- [x] Gọi API trong `UserDefaultCurrencyUpdated`

### 1.3 State không đồng bộ — P0

#### Xóa / duplicate giao dịch không refresh Home và số dư ví

Create/edit fire `StatisticalChartsReloaded` + `DataFetched(walletsFetched: true)`. Delete/duplicate **chỉ** `TransactionsReloaded`. Về Home vẫn chart + số dư cũ.

- `lib/ui/views/transaction_detail/bloc/transaction_detail_bloc.dart`

- [x] Sau delete/duplicate: reload transactions + wallets + charts (giống create/edit)

#### Listener ví trên TransactionsBloc bị kẹt

`appBloc.stream.listen` capture `wallets.first.amount` **một lần** lúc init. Sau lần đổi số dư đầu, mọi emit `AppBloc` sau đó đều retrigger reload vì giá trị captured không cập nhật.

- `lib/ui/views/transactions/bloc/transactions_bloc.dart`

- [x] Cancel/replace subscription; so với `state` hiện tại, không so biến local lúc init

### 1.4 Filter sai — P1

#### Date range nuốt khoảng mới nếu cùng duration

So `dateRangePicked.duration == state.selectedDateRange?.duration`. 1–7 Jan và 1–7 Feb cùng duration → lần chọn sau bị bỏ.

- `lib/ui/views/transactions/bloc/transactions_bloc.dart`

- [x] So `start` / `end`, không so `duration`

### 1.5 Native / config sai (hành vi build không đúng ý định) — P1

#### Android release không minify dù đã bật

`android/app/build.gradle` khai báo `signingConfigs` + `buildTypes` **hai lần**. Block sau thắng: `minifyEnabled false`, `shrinkResources false`. `proguard-rules.pro` không chạy.

- [x] Xóa block trùng; giữ `minifyEnabled true` + ProGuard cho release

#### Android flavor name không hiện

`manifestPlaceholders['applicationName']` = `Walleto-Dev` / `Walleto-Stg` / `Walleto`, nhưng manifest hard-code `android:label="Walleto"`.

- `android/app/src/main/AndroidManifest.xml`

- [x] `android:label="${applicationName}"`

#### Firebase iOS app id lệch

| Nguồn | iOS app id |
|--------|------------|
| `ios/Runner/GoogleService-Info.plist` | `…ios:cbe08f78dab79694c75e00` |
| `lib/firebase_options.dart` | `…ios:0e91dbcfc2b361d8c75e00` |

- [x] Đồng bộ `firebase_options.dart` với `GoogleService-Info.plist` (`…ios:cbe08f78dab79694c75e00`)

#### iOS `Runner.entitlements` không phải plist hợp lệ

Nội dung `dict` bị comment hết → file entitlements rỗng/invalid.

- `ios/Runner/Runner.entitlements`

- [x] Plist hợp lệ; `aps-environment` chỉ khi thật sự bật push

#### Makefile iOS staging sẽ gãy

Xcode chỉ có scheme development / production. Makefile vẫn có `build_staging_ios` / `build_staging_ipa`.

- [x] Target Makefile `build_staging_ios` / `build_staging_ipa` fail rõ, không build scheme không tồn tại

### 1.6 Memory / lifecycle — P2

#### TabController không dispose

- `lib/ui/views/home/home_view.dart`
- `lib/ui/views/categories/categories_view.dart`

- [x] `dispose()` TabController

#### Exception `uncaught` bị nuốt

`ExceptionHandler` với `AppExceptionType.uncaught` return luôn, user không thấy gì.

- `lib/ui/exception_handler/exception_handler.dart`

- [x] Hiện dialog/snackbar (hoặc log + UI tối thiểu)

#### Refresh token lỗi không-401 bị coi như hết session

`InvalidTokenHandleUseCase`: refresh fail mà không phải 401 → return default `emptyToken` → force logout. Lỗi 500 trên refresh trông như “session expired”.

- `lib/domain/usecases/invalid_token_handle_use_case.dart`

- [x] Phân biệt network/5xx vs 401; chỉ logout khi refresh thật sự hết hạn

---

## 2. Tính năng chưa hoàn thiện

UI **đã hiện** hoặc flow **đã có một phần**, nhưng chưa làm xong / tap không có hành vi. Không phải crash; user thấy app “dở”.

### 2.1 Account — gần như stub

Màn đã có profile + logout + link ví/danh mục. Các nút còn lại là TODO.

| Nút | File | Ghi chú |
|-----|------|---------|
| Đổi avatar | `account_view.dart` | `onTap` trống |
| Đổi mật khẩu | `account_view.dart` | Reset password **đã có** trên login stack, chưa nối từ Account |
| Settings | `account_view.dart` | TODO |
| Help | `account_view.dart` | TODO |
| About | `account_view.dart` | TODO |

- [x] Nối Change password vào flow reset/change hiện có
- [x] Implement hoặc **ẩn** avatar / Settings / Help / About cho đến khi có requirement

### 2.2 Categories — tạo được, không sửa/xóa

Tap category / parent = `// TODO: Navigate to category edit page` (4 chỗ).

`Repository` không có `updateCategory` / `deleteCategory`. Không empty state, không skeleton, `ListView` lồng `SingleChildScrollView`.

- `lib/ui/views/categories/categories_view.dart`
- `lib/domain/repositories/repository.dart`

- [ ] API + use case + màn edit/delete
- [x] Hoặc bỏ `onTap` cho đến khi có màn edit
- [x] Empty + loading state

### 2.3 Wallets — edit chỉ số dư, không xóa

- Edit: tên / icon / currency **display-only**, chỉ đổi amount.  
  `lib/ui/views/edit_wallet/`
- Không `deleteWallet` trên Repository.
- `WalletsView` không skeleton — có thể flash empty rồi mới có data.

- [ ] Edit đầy đủ metadata (hoặc ghi rõ “chỉ sửa số dư” trên UI)
- [ ] Delete wallet (kèm rule: ví cuối / còn giao dịch)
- [ ] Skeleton loading

### 2.4 Auth — social + Terms

- Google / Facebook hiện trên login, `onTap` TODO.  
  `lib/ui/views/auth/widgets/login_tab.dart`
- Signup **bắt buộc** tick Terms nhưng không mở được document (login + sign-up).
- iOS không gửi FCM token lúc login (`fcmToken = null`).  
  `lib/ui/views/auth/bloc/login_bloc.dart`

- [x] Implement social hoặc **ẩn** nút
- [ ] Gắn trang Terms thật
- [ ] FCM token iOS khi làm push (xem 2.7)

### 2.5 Reset / đổi mật khẩu — thiếu lối vào khi đã login

Flow email OTP + mật khẩu mới trên stack login **đã chạy**. Account “Change password” không đi tới flow đó. `app_links` có trong pubspec nhưng chưa deep link từ email.

- [x] Entry từ Account
- [ ] Deep link (hoặc bỏ `app_links` nếu không dùng)

### 2.6 Budgets — chưa phải feature

Tab 3 route `budgets`, label **AI Assistant**, initial route = `AiChatView`. `BudgetsView` là placeholder `CommonEmptyPanel`. Không entity / API / bloc handler.

- `lib/ui/views/main/bottom_tab.dart`
- `lib/ui/navigation/routes/app_router.dart`
- `lib/ui/views/budgets/`

- [x] Đổi path/enum cho đúng AI Chat **hoặc** làm budgets khi có requirement
- [ ] Không để user vào `budgets/overview` nhầm là product

### 2.7 Push notification

**Android (dở):** init Firebase + listener. Tap notification không navigate (`handleNavigate` trống). Channel name `"Default"` hard-code.

**iOS (chưa làm):** TODO ở `main.dart`, `app_config.dart`, `walleto_application.dart`, `login_bloc.dart`. `AppDelegate` comment Firebase/local notifications. Không `UIBackgroundModes` remote-notification. Entitlements trống.

- [ ] Navigation khi tap notification
- [ ] Quyết định milestone iOS push; nếu chưa làm thì đừng để config nửa vời
- [x] i18n channel name; không force-unwrap notification

### 2.8 AI Chat — phần chín nhất, còn thiếu UX

Đã có: history, reverse list, load-more, SSE, stop, skeleton, empty prompts. Test dày nhất repo.

Còn thiếu:

- Bubble assistant chỉ `SelectableText` — không markdown (list/code xấu)
- Không pull-to-refresh history
- Không offline
- Tab “budgets” gây confuse (xem 2.6)
- Nội dung chat vẫn log debug

- [x] Markdown/HTML an toàn cho assistant (package `flutter_widget_from_html` đang unused)
- [ ] Pull-to-refresh history
- [x] Đổi tên tab/route cho khớp AI

### 2.9 Home / thống kê — API thừa, UX thiếu

Đã có: hero, wallets strip, month summary, top wallet stats, recent tx, skeleton, refresh sau **một số** mutation.

Còn thiếu:

- Không `RefreshIndicator` (kéo để refresh) — Home / Transactions / Wallets / Categories
- `GetMonthStatUseCase` + `rpc/get_daily_stats` có trong domain/data, UI không dùng
- `GetWalletStatsUseCase` inject vào `HomeBloc` rồi không gọi (cũng làm `make analyze` fail — mục 3.1)

- [x] Pull-to-refresh (Home / Transactions / Wallets; Categories chưa)
- [ ] Dùng daily stats trên UI **hoặc** gỡ API chết

### 2.10 Offline / pagination giao dịch

`ConnectivityInterceptor` reject khi mất mạng — không cache. Transactions load cả tháng/range một shot (không `limit`). Chỉ AI Chat history có pagination. `infinite_scroll_pagination` trong pubspec **không dùng**.

- [ ] Pagination transactions
- [ ] Cache tối thiểu (số dư / list gần nhất) hoặc empty/error rõ khi offline

### 2.11 Native chưa làm (không phải bug logic Dart)

Những mục này là **thiếu cho production / store**, không phải crash flow hiện tại trên Android debug.

| Hạng mục | Chi tiết |
|----------|----------|
| Privacy Manifest | Không có `ios/PrivacyInfo.xcprivacy` — App Store yêu cầu |
| Backup Android | Không `allowBackup="false"` / backup rules — rủi ro token/data finance |
| Flavor ID | Cùng `applicationId` / bundle ID mọi flavor — không cài song song |
| Screenshot | Không `FLAG_SECURE` / blur background — số dư lộ app switcher |
| Deep link | `app_links` chưa gắn intent-filter / URL scheme / associated domains |
| Biometric | `local_auth` trong pubspec, không dùng Dart; MainActivity chưa `FlutterFragmentActivity`; thiếu `NSFaceIDUsageDescription` |
| Export iOS | `ExportOptions.plist` `method = development` — không dùng TestFlight/App Store |
| INTERNET trên app manifest | Chỉ `debug`/`profile`; release dựa plugin merge |
| Display name Android | Xem bug 1.5 (placeholder bị bỏ) |

- [x] Privacy Manifest
- [x] `allowBackup="false"` (hoặc data extraction rules)
- [ ] `applicationIdSuffix` / bundle suffix theo flavor
- [ ] Screen security khi app background
- [ ] Gỡ `local_auth` / `app_links` nếu chưa làm, hoặc wire đúng native

---

## 3. Nợ kỹ thuật

Không phải bug user-facing, cũng chưa phải “feature dở”. Ảnh hưởng CI, bảo mật debug, maintainability.

### 3.1 `make analyze` fail

`HomeBloc` field `_getWalletStatsUseCase` unused (`unused_field`). `make verify` không pass.

- `lib/ui/views/home/bloc/home_bloc.dart`

- [x] Xóa inject chết (Home đã dùng `GetTopWalletStatsUseCase`)

### 3.2 Test lệch coverage

Test hiện có tập trung AI Chat + `HomeBloc` / `CreateWalletBloc` / `TransactionsBloc` (loading) / vài use case + mapper AI.

**Thiếu test cho đúng bug P0:** empty wallets, date range, delete refresh, mixed currency, `LoginBloc`, `ResetPasswordBloc`, `EditWalletBloc`, `TransactionDetailBloc`, mapper wallet/transaction/category, `InvalidTokenHandleUseCase`.

- [x] Test crash empty wallets
- [x] Test date-range equality
- [x] Test delete/duplicate bắn đủ reload events
- [ ] Test auth / reset password

### 3.3 Dependency chết

Có trong `pubspec.yaml`, không (hoặc gần như không) dùng trong `lib/`:

- `permission_handler`
- `app_links`
- `local_auth` / `local_auth_android` / `local_auth_darwin`
- `infinite_scroll_pagination`
- `carousel_slider`
- `flutter_widget_from_html`
- `android_intent_plus`

- [ ] Gỡ hoặc wire thật

### 3.4 Dead code / log nhạy cảm

- `CookieInterceptor` no-op nhưng vẫn gắn mọi API client; `CookieHelper` tạo jar trên disk không dùng
- Event `SignUpButtonPressed` không `on<>` / không dispatch
- OTP `code` chưa redact (`LogRedactor` không coi `code` là sensitive); `LoginState.toString` vẫn có password/otp
- ARB: `"login bellow"` (`intl_en_US.arb`)
- `MainActivity` path `kotlin/com/example/walleto/` vs package `com.hungbui.walleto.app`
- Android Support `multidex` trong project AndroidX
- Create vs edit transaction gần như copy-paste hai bloc — sửa một bên dễ quên bên kia
- Domain vẫn import Flutter cho navigator/popup (đã chấp nhận trong refactor-checklist; không xé trong đợt này)
- Accessibility: gần như không có `Semantics` (trừ `Pressable`)

- [ ] Gỡ interceptor chết (`CookieInterceptor` vẫn gắn mọi API client)
- [x] Gỡ event chết (`SignUpButtonPressed`)
- [x] Redact OTP / password trên event + HTTP `code`
- [x] Sửa typo ARB
- [x] Dọn AndroidX multidex (path MainActivity `com/example/walleto/` chưa đổi)

---

## Thứ tự gợi ý

Làm **bug P0** trước, rồi mới hoàn thiện nút đang hiện trên UI.

1. Empty wallets crash + ẩn FAB + cold start Create Wallet
2. Tổng đa tiền tệ (Home + day total)
3. Persist default currency
4. Delete/duplicate refresh Home + wallets
5. Date range + listener TransactionsBloc
6. `make analyze` (unused `GetWalletStatsUseCase`)
7. Gradle: một `buildTypes`, R8 on, `allowBackup`, label flavor
8. Ẩn hoặc nối Account / Category tap / social / Terms (đừng để nút chết)
9. Privacy Manifest + entitlements iOS hợp lệ
10. Test cho các path vừa sửa
