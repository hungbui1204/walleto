# Plan — UI consistency & interaction smoothness

Spec implement. Convention: [CLAUDE.md](../CLAUDE.md), [CODING_RULES.md](../CODING_RULES.md), [AGENTS.md](../AGENTS.md).

**Mục tiêu:** giữ skin **Noir Glass** (OLED + teal + glass panel), nhưng **một contract** cho widget + tap + picker + tab + scroll. App nhìn đẹp đã có; việc này sửa cảm giác “widget không cùng họ / tap không mượt”.

**Hướng đã chốt** (agent **không** mở lại debate trừ khi conflict với code):

1. Mọi bề mặt tap trong app đi qua `Pressable` (không `InkWell` / `GestureDetector` trần / `TextButton` / `ElevatedButton` cho UI Walleto).
2. Mọi hàng list (ví, giao dịch, category, form row) đi qua `CommonListRow`.
3. Picker danh sách → **bottom sheet** + tap-to-select (pop ngay). Dialog chỉ còn confirm / error / complete / warning.
4. Tab 2 lựa chọn → `CommonSegmentedControl`. **Cấm** `TabBarView` nằm trong `SingleChildScrollView`.
5. List dài → sliver / list ảo. Không lồng `ListView(shrinkWrap: true)` trong `SingleChildScrollView` trên Home / Transactions.

**Không:**

- Đổi palette / brand (không restyle màu, không đổi `primaryColor`).
- Rename hàng loạt token (`blackColor` vẫn là chữ sáng — chỉ thêm alias, không search-replace toàn repo).
- Làm feature dở trong [current-issues.md](current-issues.md) (edit category/wallet, budgets, pagination API…).
- Tách hết widget `_private` của màn không đụng (CODING_RULES §7.5).
- Đổi BLoC business logic trừ khi wiring scroll/refresh bắt buộc.
- Gộp nhiều phase vào một PR.
- Commit / push / PR trừ khi user yêu cầu rõ.

**Cách giao việc cho agent**

Mỗi lần chỉ giao **một phase**. Copy prompt ở cuối file, thay `Phase X`.

Một phase xong: `make analyze` + `fvm dart format` file đã đụng. Phase có widget mới / đổi tap contract → thêm hoặc cập nhật test `test/ui/widgets/` (mirror `lib/ui/widgets/`). `make testing` phải pass.

Tick `[x]` khi PR merge.

---

## Mục lục

1. [Hiện trạng — đừng lặp lại](#1-hiện-trạng--đừng-lặp-lại)
2. [Contract đã chốt](#2-contract-đã-chốt)
3. [Phase 0 — Primitive: Pressable + token](#phase-0--primitive-pressable--token)
4. [Phase 1 — CommonListRow](#phase-1--commonlistrow)
5. [Phase 2 — Chrome: nút, empty, keyboard, bottom nav, FAB](#phase-2--chrome-nút-empty-keyboard-bottom-nav-fab)
6. [Phase 3 — Picker sheet thống nhất](#phase-3--picker-sheet-thống-nhất)
7. [Phase 4 — Segmented control + bỏ TabBarView trong scroll](#phase-4--segmented-control--bỏ-tabbarview-trong-scroll)
8. [Phase 5 — Scroll architecture](#phase-5--scroll-architecture)
9. [Phase 6 — Polish còn lệch](#phase-6--polish-còn-lệch)
10. [Verify & Definition of Done](#10-verify--definition-of-done)
11. [Prompt giao agent](#11-prompt-giao-agent)

---

## 1. Hiện trạng — đừng lặp lại

Skin đã có: `AppDecorations.glassPanel()`, `NoirScaffoldBody`, `CommonButton`/`Pressable`, `AppTextStyles`, `AppThemes.amount`/`display`.

Lỗ hổng là **không có luật dùng**:

| Vấn đề | Bằng chứng |
|---|---|
| Cùng hàng list, 4 cách ráp | Home ví = `Pressable` + chevron; Home tx = `GestureDetector`; Transactions tx = `GestureDetector`; Wallets = `CommonRow` **không** `CommonAmountWithSymbol` |
| 5 ngôn ngữ tap | `Pressable` (scale) / `InkWell` (ripple) / `GestureDetector` (im lặng) / `ElevatedButton` (keyboard) / `FloatingActionButton` |
| `Pressable.borderRadius` dead | Field nhận vào, **không clip / không dùng** |
| Picker ví nhân đôi | `AppPopupInfo.selectWallet` = dialog; `chooseWallet` = sheet + Save/Cancel |
| Tab hai họ | Home `_ChartTab` chip vs Categories Material `TabBar`; Home còn `SegmentedButton` |
| Gesture conflict | `TabBarView` (vuốt ngang) **trong** `SingleChildScrollView` (vuốt dọc) — `statistic_widget.dart` |
| List không ảo | Home + Transactions: `SingleChildScrollView` → `ListView.separated(shrinkWrap: true)` lồng nhau |
| Typography dual-track | `CommonAppBar` override DM Sans `s20wBoldBlack`; `AppBarTheme` khai Space Grotesk 22 |
| Radius / duration rải | Panel `d16`, chip `d12`, form icon `d8`; motion 180 / 200 / 300 hard-code / 400 / 500 |
| Icon tab lệch | Home/Tx/Account = SVG; AI = `Icons.auto_awesome_rounded`; size `d30` vs `d28` |
| Không haptic | `HapticFeedback` = 0 match trong `lib/` |

Chi tiết điều tra (2026-09-12): không cần đọc lại toàn repo nếu bám contract dưới.

---

## 2. Contract đã chốt

### 2.1 Tap — `Pressable` là luật

Mọi `onTap` của UI Walleto (list row, button, chip, tab item, icon action, keyboard key, bottom nav, “See all”) **phải** bọc `Pressable`.

**Ngoại lệ được phép `GestureDetector`:** chỉ để dismiss keyboard (`onTap` blank + `HitTestBehavior.opaque` trên overlay), không phải control.

**Cấm** `InkWell` / `TextButton` / `ElevatedButton` / `IconButton` cho control sản phẩm (empty CTA, wallets `+`, category row, auth back vẫn chuyển sang `Pressable`). `IconButton` trong `CommonTextField` suffix (show password) được giữ vì là control của `InputDecoration` — bọc không vừa; được phép.

Feedback:

| `PressableFeedback` | Dùng cho |
|---|---|
| `scale` (default) | Button, chip, list row, card, keyboard key, FAB |
| `opacity` | Bottom nav item (scale làm tab bar “nhún” — cảm giác rẻ) |
| `none` | Disabled (`onTap == null`) |

Scale: `0.97`. Duration: `DurationConstants.microInteraction` (180ms). `MediaQuery.disableAnimationsOf` → `Duration.zero`. Clip theo `borderRadius` (`ClipRRect`). Haptic: `HapticFeedback.selectionClick()` khi tap **enabled** (một lần lúc `onTap`), không haptic khi disabled.

`borderRadius` **bắt buộc dùng** (clip + Semantics). Default: `AppDecorations.panelRadius()`.

### 2.2 Hàng list — `CommonListRow`

File mới: `lib/ui/widgets/common_list_row.dart`.

`CommonRow` **không xóa ngay**: biến thành wrapper mỏng gọi `CommonListRow` (Phase 1), trailing phải là `CommonAmountWithSymbol` khi nội dung là tiền.

API chốt (được phép thêm param optional, **không** bớt):

```dart
class CommonListRow extends StatelessWidget {
  const CommonListRow({
    super.key,
    this.leading,
    required this.title, // Widget
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.backgroundColor,
    this.semanticLabel,
    this.minHeight, // default Dimens.d44.responsive()
  });
}
```

Quy tắc:

- Bọc `Pressable` bên trong (feedback `scale`).
- Chevron: `Icons.arrow_forward_ios_rounded`, size `Dimens.d14`, color `darkGreyColor` — **một** icon, không lẫn `chevron_right` / `arrow_forward_ios`.
- Title mặc định style `AppTextStyles.s16wNormalBlack()` nếu `title` là `Text` không style — caller được truyền `Text(..., style:)` riêng.
- Tiền trailing: **luôn** `CommonAmountWithSymbol` (không `toStringWithFormat` trần).
- `showChevron: true` khi hàng **đi tiếp** (edit ví, chi tiết giao dịch, form field). `false` khi hàng chỉ hiển thị / select trong sheet (sheet dùng check icon trailing khi selected).

### 2.3 Picker — sheet; Alert — dialog

| Loại | Pattern |
|---|---|
| Chọn 1 item từ list (ví, currency, tháng, icon nếu list) | Bottom sheet + `CommonPickerSheet` + tap row → callback + `pop` |
| Nhập text (note) | Sheet + Save/Cancel (form) |
| Confirm / error / complete / warning | `AlertDialog` qua `PopUpWidget` (giữ) |
| Cây category + tạo mới | **Giữ dialog** Phase 3 (cây + `createCategory` phức tạp). Ghi nợ Phase 6 nếu còn lệch |

Gộp ví: **xóa** `AppPopupInfo.selectWallet` + `select_wallet_popup.dart`. Mọi chỗ dùng `chooseWallet`.

`chooseWallet` sau gộp:

```dart
const factory AppPopupInfo.chooseWallet({
  required void Function(Wallet) onWalletSelected,
  Wallet? currentWallet,
  List<Wallet>? wallets, // null → AppBloc.wallets (không có Total)
  @Default(false) bool includeTotalWallet, // Transactions filter
}) = ChooseWallet;
```

Tap row = select + pop. **Bỏ** Save/Cancel trên sheet ví / currency. Note sheet giữ Save/Cancel.

`showModalBottomSheet`: `isScrollControlled: true` khi list có thể dài.

### 2.4 Tab / segmented

Widget mới: `lib/ui/widgets/common_segmented_control.dart`.

Lấy visual từ Home `_ChartTab` (chip fill `primaryShadeColor` + border `primaryColor` khi selected; `fieldFillColor` + `glassHairlineColor` khi không). Radius: `AppDecorations.chipRadius()` (`d12`).

```dart
class CommonSegmentedControl<T> extends StatelessWidget {
  const CommonSegmentedControl({
    super.key,
    required this.segments, // List<({T value, String label})> hoặc class nhỏ
    required this.selected,
    required this.onSelected,
  });
}
```

Dùng cho:

- Home chart: Month summary / Spent stats
- Home spent: Expense / Income (**thay** `SegmentedButton`)
- Categories: Expense / Income (**thay** `TabBar`)

Home chart **không** `TabBarView` vuốt. Dùng `IndexedStack` (tap chip đổi index). Giữ bounded height như hiện tại.

Categories: `TabBarView` **được giữ** vì là body `Expanded` (không nằm trong vertical scroll). Chỉ thay chrome `TabBar` → `CommonSegmentedControl` sync `TabController` / index.

### 2.5 Radius & motion

Thêm helper, **không** hard-code rải:

| Token | Giá trị | Dùng |
|---|---|---|
| `AppDecorations.panelRadius()` | `d16` | panel, button, field, sheet top, dialog |
| `AppDecorations.chipRadius()` | `d12` | segmented, keyboard key, small chip |
| Tiny | `d8` | icon well trong form / tooltip — chỉ khi thật sự nhỏ |

Theme `bottomSheetTheme` / `dialogTheme` đang `Radius.circular(16)` const — đổi sang cùng `d16` (theme có thể không `const` nếu cần `.responsive()`). Viền sheet/dialog: `glassHairlineColor` (không `frameColor`).

Duration: **cấm** `Duration(milliseconds: 300)` trần. `AnimatedSize` filter ngày Transactions → `DurationConstants.defaultAnimationDuration`.

| Token | ms | Dùng |
|---|---|---|
| `microInteraction` | 180 | press, chip selected |
| `defaultGeneralDialogTransitionDuration` | 200 | dialog |
| `defaultAnimationDuration` | 300 | expand/collapse, sheet content |
| `defaultAnimationScrollDuration` | 400 | scroll-to |
| `defaultChartAnimationDuration` | 500 | fl_chart only |

### 2.6 Typography

- AppBar title: `AppThemes.display(fontSize: Dimens.d22.responsive())` — **bỏ** override `s20wBoldBlack()` trên `CommonAppBar`.
- Số tiền: `AppThemes.amount` qua `CommonAmountWithSymbol`.
- Body / label / button label: `AppTextStyles` như hiện tại.
- Không invent `TextStyle(...)` mới trừ `AppThemes.display`/`amount`.

Không rename `blackColor`. Optional Phase 0: alias comment-only hoặc `const onSurfaceForeground = blackColor` **nếu không phình diff**. Ưu tiên không đụng token name.

### 2.7 Scroll

- **Transactions:** `CustomScrollView` + sliver header (wallet chip + date filter) + sliver list ngày. Mỗi ngày là panel; **bên trong** ngày nếu ít item thì `Column` (không `ListView` lồng). Ngày nhiều item: `SliverMainAxisGroup` hoặc flatten `(dateHeader + rows)` thành một sliver list — agent chọn cách **không** `shrinkWrap` lồng nhau.
- **Home:** `CustomScrollView` / `CustomScrollView` + slivers cho hero, chips, wallets, charts, recent. Chart block = sliver với height cố định + `IndexedStack`. Recent tx: sliver list, không `ListView.shrinkWrap`.
- **Wallets / Account:** list ngắn, được phép `Column` trong `SingleChildScrollView` + `RefreshIndicator`. Không bắt buộc sliver.
- Pull-to-refresh giữ `RefreshIndicator` bọc scrollable **primary** (AlwaysScrollable).

---

## Phase 0 — Primitive: Pressable + token

**PR nhỏ. Không migrate màn.**

### Việc

- [ ] `lib/ui/widgets/pressable.dart`
  - Dùng `borderRadius` (default `AppDecorations.panelRadius()`).
  - `ClipRRect` + `AnimatedScale`.
  - `PressableFeedback { scale, opacity, none }`.
  - `HapticFeedback.selectionClick()` khi `onTap` fire.
  - Reduce motion → duration 0.
- [ ] `lib/resources/styles/app_decorations.dart` — thêm `chipRadius()`; document `panelRadius` vs `chipRadius` bằng comment ngắn.
- [ ] `lib/ui/widgets/common_app_bar.dart` — title `AppThemes.display(fontSize: Dimens.d22.responsive())`.
- [ ] `lib/resources/styles/app_themes.dart` — dialog/sheet radius + border `glassHairlineColor` khớp decoration.
- [ ] `.cursor/rules/design-system.mdc` + [CODING_RULES.md](../CODING_RULES.md) §8 — thêm 4 dòng luật: `Pressable` bắt buộc; `CommonListRow` cho hàng; picker = sheet; cấm `TabBarView` trong vertical scroll.
- [ ] Test: `test/ui/widgets/pressable_test.dart` — tap gọi callback; `onTap == null` không scale / không gọi haptic (mock haptic nếu cần, hoặc test `onTap` only).

### Không làm Phase 0

Migrate `InkWell`/`GestureDetector` trên view (Phase 1–2). Đổi `AppPopupInfo`. Đổi Home/Transactions scroll.

**Xong khi:** `Pressable` clip + haptic + feedback enum; AppBar dùng display font; rule file đã ghi luật; `make analyze` pass; test Pressable pass.

---

## Phase 1 — CommonListRow

### Việc

- [ ] Tạo `lib/ui/widgets/common_list_row.dart` đúng API §2.2. Export `lib/ui/ui.dart`.
- [ ] `common_row.dart` → wrapper: `CommonAmountWithSymbol` cho tiền (Wallets đang mất symbol).
- [ ] Migrate hàng:

| File | Hàng | `showChevron` | Trailing |
|---|---|---|---|
| `home_view.dart` `_WalletInfoWidget` | ví | true | `CommonAmountWithSymbol` |
| `home_view.dart` `_RecentTransactionWidget` | tx | true | amount màu income/expense |
| `transactions_view.dart` `_TransactionInfoWidget` | tx | true | amount màu |
| `wallets_view.dart` | ví | true | `CommonAmountWithSymbol` |
| `transaction_form_panel.dart` `_TransactionFormRow` | form | true | (chevron only) |
| `choose_wallet_bottom_sheet.dart` `_WalletWidget` | select | false | check khi selected |
| `choose_currency_bottom_sheet.dart` (row tương đương) | select | false | check khi selected |
| `select_category/widgets/category_widget.dart` + `parent_category_widget.dart` | `InkWell` → `CommonListRow` | false nếu pop select | — |

- [ ] Home “See all”: `Pressable` + text (đừng để `GestureDetector`).
- [ ] Test: `test/ui/widgets/common_list_row_test.dart` — render title; `onTap`; chevron có/không.

### Không làm Phase 1

Đổi sheet API / xóa `SelectWallet`. Đổi TabBar. CustomScrollView.

**Xong khi:** không còn hàng ví/tx/form tự `GestureDetector`/`InkWell` ở các file bảng trên; Wallets hiện symbol tiền; `CommonRow` không còn logic layout riêng.

---

## Phase 2 — Chrome: nút, empty, keyboard, bottom nav, FAB

### Việc

- [ ] `common_empty_panel.dart` — CTA: `CommonButton(compact: true)` (hoặc `CommonChipButton` nếu chỉ text link). **Cấm** `TextButton`.
- [ ] `common_forward_button.dart` — `AppDecorations.secondaryCta` khi `showBorder`, không `BoxDecoration` tay. Chevron `arrow_forward_ios_rounded` `d14`.
- [ ] `numeric_keyboard.dart` — mỗi key `Pressable` + `DecoratedBox` (`chipRadius`). Bỏ `ElevatedButton`.
- [ ] `bottom_bar_icon_button.dart` — `Pressable(feedback: opacity)`. Bỏ `InkWell`.
- [ ] `bottom_tab.dart` — icon size **một** `Dimens.d24.responsive()` (hoặc `d28` — chọn 1, áp mọi tab). Tab AI: SVG nếu đã có asset gần nghĩa; nếu không, `Icon` cùng size + `ColorFilter` selected như tab khác (selected = `primaryColor`, unselected = `darkGreyColor`). Sửa bug hiện tại: icon AI hard-code `blackColor` rồi bị `ColorFiltered` ở parent — thống nhất một đường màu.
- [ ] `main_view.dart` FAB — thay `FloatingActionButton` bằng vòng tròn `Pressable` + `AppDecorations.primaryCta`, size `Dimens.d56`, `semanticLabel: S.current.addTransaction`. Giữ `floatingActionButtonLocation: centerDocked` + gap `d56` trên bar.
- [ ] Auth / reset: `InkWell` back / complete → `Pressable` (file: `sign_up_tab.dart`, `sign_up_complete_step_widget.dart`, `reset_password_view.dart`, `reset_password_complete_step_widget.dart`).
- [ ] `create_category_popup.dart` / `select_icon_popup.dart` — tap control → `Pressable` hoặc `CommonListRow`.
- [ ] `wallets_view.dart` nút `+` — `Pressable` (hoặc `CommonChipButton` icon), bỏ `IconButton`.

### Không làm Phase 2

Gộp popup ví. Sliver list.

**Xong khi:** `rg "InkWell\\(" lib/ui` = 0 (trừ comment). `rg "ElevatedButton\\(" lib/ui` = 0. `rg "TextButton\\(" lib/ui` = 0. Bottom nav không ripple Material. FAB cùng ngôn ngữ CTA.

---

## Phase 3 — Picker sheet thống nhất

Cần codegen: `AppPopupInfo` freezed → `make force_build`.

### Việc

- [ ] Widget `lib/ui/widgets/bottom_sheet/common_picker_sheet.dart`
  - Drag handle (width `d36`, height `d4`, `glassHairlineColor`, radius `d2`).
  - Title `AppTextStyles.s18wBoldBlack()`.
  - `child` + `SafeArea(top: false)`.
  - Optional `actions` (chỉ note sheet).
- [ ] Gộp ví:
  - Mở rộng `AppPopupInfo.chooseWallet` theo §2.3.
  - Transactions filter: `chooseWallet(wallets: state.wallets, includeTotalWallet: …)` — list hiện tại **đã** có Total; truyền list caller.
  - Form: `chooseWallet` như cũ (AppBloc, không Total).
  - Xóa `AppPopupInfo.selectWallet`, `select_wallet_popup.dart`, export barrel.
  - Mapper + tests nếu có reference.
- [ ] Currency sheet: tap-to-select + pop; bọc `CommonPickerSheet`; bỏ Save/Cancel.
- [ ] `select_month_popup.dart` → sheet (file mới `select_month_bottom_sheet.dart` hoặc đổi widget, mapper `showModalBottomSheet`). UI tháng/năm giữ; chrome = `CommonPickerSheet`. Transactions `showDialog(selectMonth)` → `showModalBottomSheet`.
- [ ] Note sheet: bọc `CommonPickerSheet` + actions Save/Cancel (`CommonButton`).
- [ ] `app_navigator_impl.dart` — sheet list: `isScrollControlled: true` (ít nhất choose wallet / currency / month).
- [ ] Cập nhật test mapper / popup nếu gãy vì xóa `SelectWallet`.

### Không làm Phase 3

Đổi `selectCategory` sang sheet (nợ Phase 6). Đổi Material `showDatePicker` (date range / form date) — **giữ hệ thống** ở phase này (look native được chấp nhận cho calendar). Ghi nợ: theme date picker Noir nếu còn lệch sau Phase 5.

**Xong khi:** `rg "selectWallet" lib/` = 0; chọn ví Transactions và form cùng sheet; currency/month không còn `AlertDialog` giữa màn; tap row pop ngay (trừ note).

---

## Phase 4 — Segmented control + bỏ TabBarView trong scroll

### Việc

- [ ] `lib/ui/widgets/common_segmented_control.dart` — visual copy `_ChartTab`. `Pressable` + `AnimatedContainer` `microInteraction`. Export barrel.
- [ ] `statistic_widget.dart`
  - Xóa `_ChartTab`.
  - `TabBarView` → `IndexedStack` (hoặc `if (index==0)`). **Không** physics vuốt ngang.
  - Expense/Income: thay `SegmentedButton` bằng `CommonSegmentedControl<CategoryType>`.
- [ ] `categories_view.dart` — `TabBar` → `CommonSegmentedControl`; `TabBarView` giữ trong `Expanded`.
- [ ] Date chip Home spent (`Container` calendar) → `Pressable` + `chipRadius` (đừng để hộp chết).

**Xong khi:** Home không còn `TabBarView`; vuốt chart không kéo ngang-cắn-dọc; Categories không Material underline tab; một widget segmented dùng 3 chỗ.

---

## Phase 5 — Scroll architecture

**Dễ phình diff — chỉ Home + Transactions.**

### Việc

- [ ] `transactions_view.dart`
  - `RefreshIndicator` + `CustomScrollView(physics: AlwaysScrollableScrollPhysics)`.
  - Header (wallet chip, date filter) = sliver.
  - Danh sách ngày/giao dịch = sliver list **không** `shrinkWrap` lồng `ListView`.
  - Empty: sliver fill / sliver to box `CommonEmptyPanel` (không empty trong `ListView.shrinkWrap`).
- [ ] `home_view.dart`
  - Cùng pattern sliver: hero, flow chips, wallets (max 3 → `SliverList` hoặc `SliverToBoxAdapter`+`Column` vì ngắn), statistic (bounded), recent tx sliver.
  - Bỏ `ListView.separated(shrinkWrap: true)` wallets/recent.
- [ ] `AnimatedSize` date filter: `DurationConstants.defaultAnimationDuration`.
- [ ] Skeleton Home/Transactions: chỉ sửa nếu layout sliver làm skeleton lệch rõ (giữ token shimmer). Không redesign skeleton.

### Không làm Phase 5

Virtualize AI chat (đã reverse list riêng). Pagination API giao dịch ([current-issues](current-issues.md) 2.10) — khác task.

**Xong khi:** `rg "shrinkWrap: true" lib/ui/views/home lib/ui/views/transactions` = 0 (trừ skeleton nếu bắt buộc). Scroll một trục; `make analyze` pass. Hành vi filter / navigate / refresh **không đổi**.

---

## Phase 6 — Polish còn lệch

Làm sau khi 0–5 ổn. Từng mục có thể PR riêng.

- [ ] `selectCategory` → sheet `isScrollControlled` nếu vẫn lệch dialog vs sheet (không bắt buộc nếu tree + create dialog ổn).
- [ ] Theme `showDatePicker` / date range cho khớp Noir (optional).
- [ ] `CommonLine` vs `AccentRule`: giữ cả hai (Accent = hero; Line = divider). Không gộp.
- [ ] Magic number Home overlay ví `right: -6` → `Dimens` (vd `d6`).
- [ ] `common_currency_container.dart` radius `d12` → `chipRadius()`.
- [ ] Tooltip convert amount (`transaction_form_panel`) radius `d8` + border `glassHairlineColor`.
- [ ] Audit cuối: `rg "GestureDetector\\(" lib/ui` — mỗi match phải là dismiss keyboard hoặc comment giải thích ngoại lệ.
- [ ] Alias token `onSurfaceForeground` **chỉ nếu** diff nhỏ; không rename `blackColor`.

**Xong khi:** grep audit sạch; không còn picker dialog trừ alert + (optional) category tree.

---

## 10. Verify & Definition of Done

Toàn bộ epic (sau Phase 5, Phase 6 optional):

- [ ] `make analyze` pass.
- [ ] `make testing` pass.
- [ ] Tap list/button/chip/nav/keyboard: **một họ** feedback (`Pressable`).
- [ ] Hàng ví/tx cùng layout (`CommonListRow` + amount widget).
- [ ] Chọn ví chỉ còn 1 UI (sheet).
- [ ] Home: tap segmented, **không** vuốt chart cắn scroll trang.
- [ ] Transactions: scroll mượt list dài (không layout hết `shrinkWrap` lồng).
- [ ] Không hard-code color / `TextStyle` / string / duration / radius ngoài token.
- [ ] Barrel export widget public mới.
- [ ] Không đụng `ios/`, `android/`, `env/`, generated files.

Manual (giao QA / user):

1. Home: tap ví, tap tx, tap See all, đổi 2 tab chart, đổi Income/Expense — scale/opacity nhất quán, không giật gesture.
2. Transactions: đổi ví (sheet), filter tháng (sheet), mở tx — list dài scroll không khựng.
3. Tạo giao dịch: chọn ví/currency (sheet tap-to-select), category (dialog tạm), note (sheet Save), keyboard keys scale.
4. Bottom nav + FAB: không ripple Material lệch; FAB không che label tab.
5. Account / Wallets / Categories: hàng và empty CTA cùng họ nút.

---

## 11. Prompt giao agent

Copy nguyên khối, thay phase:

```
Bạn là Code Agent (Flutter) trên repo Walleto. Đọc CLAUDE.md, CODING_RULES.md, rồi docs/ui-consistency-plan.md.

Làm ĐÚNG một phase: Phase <N> — <tên phase>.
Không gộp phase khác. Không restyle màu/brand. Không commit/push/PR trừ khi tui yêu cầu.

Bám "Hướng đã chốt" và API widget trong file plan. Nếu code hiện tại conflict với plan, hỏi tui — đừng tự đổi contract.

Xong phase: tick tiêu chí "Xong khi", chạy make analyze, format đúng file đã đụng, thêm/cập nhật test nếu phase yêu cầu, make testing pass.
```

Gợi ý thứ tự giao: **0 → 1 → 2 → 4 → 3 → 5 → 6**.

- 0+1+2 = cảm giác tap khớp (user thấy ngay).
- 4 = hết cấn tay trên Home.
- 3 = hết dialog/sheet lai tạp.
- 5 = list dài mượt (diff lớn, để sau khi primitive ổn).
- 6 = còn sót.

Role: Phase 0–5 chủ yếu **Refactor Agent** (không đổi behavior tiền/filter) + **Code Agent** khi thêm widget. Docs rule (`.cursor/rules/design-system.mdc`, `CODING_RULES.md` §8) làm trong Phase 0. Không cần Platform/CI.

Liên quan: [current-issues.md](current-issues.md) (bug/feature dở — **không** trộn vào epic này), [skeleton-loading.md](skeleton-loading.md) (giữ skeleton; Phase 5 chỉ chỉnh nếu sliver làm lệch layout).
