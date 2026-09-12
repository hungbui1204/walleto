# Skeleton loading — 4 tab bottom nav

Spec implement. Convention: [CLAUDE.md](../CLAUDE.md), [CODING_RULES.md](../CODING_RULES.md).

**Mục tiêu:** first paint của 4 màn gốc bottom nav dùng **skeleton trong body**, **không** Lottie `AppLoadingWidget`. AppBar + bottom nav giữ nguyên. `AppLoadingWidget` vẫn dùng cho action chặn UI (submit form, create/edit, sign out…).

**Hướng đã chốt:** keep AppBar + **replace body**. Không overlay skeleton lên cả `Scaffold`. Không AppBar giả.

**Không:** commit / push / PR trừ khi user yêu cầu rõ.

---

## Hiện trạng (đừng lặp lại)

| Tab (màn gốc) | File view | First load event | Loading UI hiện tại |
|---|---|---|---|
| Home | `lib/ui/views/home/home_view.dart` | `HomeViewInitialized` | `HomeLoadingShimmer` overlay qua `buildPageLoading()` — **che AppBar** |
| Transactions | `lib/ui/views/transactions/transactions_view.dart` | `TransactionsViewInitialized` | `AppLoadingWidget` (Lottie + overlay `#99000000`) |
| AI Assistant | `lib/ui/views/ai_chat/ai_chat_view.dart` (tab Budgets) | `AiChatViewInitiated` | `AppLoadingWidget` |
| Account | `lib/ui/views/account/account_view.dart` | `AccountViewInitiated` | `AppLoadingWidget` |

Cơ chế chung: `BasePageState` `Stack` + `CommonBloc.isLoading` + `buildPageLoading()` default `AppLoadingWidget`. `runBlocCatching` mặc định `handleLoading: true`.

`HomeLoadingShimmer` nằm trong `lib/ui/widgets/common_shimmer.dart` — layout Home cứng, **không** phải common widget. `CommonShimmerBox` mỗi instance 1 `AnimationController`. `shimmer: 3.0.0` trong `pubspec.yaml` **không dùng** — đừng import; giữ custom token Noir. **Đừng** xóa dependency trừ khi user hỏi.

`HomeViewInitialized` cũng được bắn lại khi `needReloadStatisticalCharts` — nếu giữ `handleLoading: true` thì skeleton sẽ flash sau tạo giao dịch.

---

## Việc cần làm

### Phase 1 — Primitive common

Tách `lib/ui/widgets/common_shimmer.dart` thành primitive **dùng chung**. Xóa `HomeLoadingShimmer` khỏi file này.

| Widget | Vai trò |
|---|---|
| `CommonShimmer` | Ancestor 1 `AnimationController`, share cho con (InheritedWidget / Listenable) |
| `CommonShimmerBox` | Khối bo góc; **không** tự tạo ticker |
| `CommonShimmerCircle` | Avatar / icon ví |
| `CommonShimmerListTile` | Circle + 1–2 dòng + trailing box (row Home/Transactions/Account) |
| `CommonShimmerPanel` | Bọc `AppDecorations.glassPanel()`, optional title bar giả |

Quy tắc:

- Màu: `backgroundShimmer` / `backgroundShimmerHighlight` (đã có trong `app_colors.dart`).
- Spacing / size: `Dimens.dXX.responsive()`.
- Duration shimmer: thêm vào `DurationConstants` (hiện hard-code `1200ms`) — **không** magic number.
- Export public widget mới vào `lib/ui/ui.dart`.
- Mỗi `CommonShimmerBox` dưới 1 `CommonShimmer` phải animate đồng bộ.

**Xong khi:** không còn `HomeLoadingShimmer` trong `common_shimmer.dart`; primitive build được độc lập; `make analyze` pass.

### Phase 2 — Wiring BasePageState (replace body)

Đổi `BasePageState` để màn skeleton **không** vẽ overlay Lottie.

Gợi ý API (được phép chỉnh tên nếu khớp convention hiện có, giữ ý):

```dart
bool get useSkeletonLoading => false;
```

- `useSkeletonLoading == false` (default): giữ Stack + `Visibility` + `buildPageLoading()` → `AppLoadingWidget`. Dùng cho form / mutation.
- `useSkeletonLoading == true`: **không** overlay `AppLoadingWidget`. `buildPage` giữ `Scaffold` + `CommonAppBar`; **body** (trong `NoirScaffoldBody`) hiện skeleton khi đang first-load.

Trong body, ưu tiên đọc `CommonBloc.isLoading` với `BlocBuilder` + `buildWhen` (bắt buộc). Thứ tự:

1. `isLoading` → skeleton widget của màn
2. (AI Chat) `state.isEmpty` → empty state — **không** hiện empty trong lúc load history
3. content thật

`buildPage` vẫn luôn mount `Scaffold` + AppBar — skeleton **không** thay cả page, chỉ body.

**Xong khi:** Home/Transactions/AiChat/Account set `useSkeletonLoading => true`; màn khác không đổi hành vi Lottie overlay.

### Phase 3 — `handleLoading` chỉ first load

Skeleton body gắn `CommonBloc.isLoading` → **cấm** `handleLoading: true` trên filter / refresh / mutation nhẹ. Nếu không, cả trang thành skeleton khi đổi tháng / Income-Expense.

| Bloc | Event | `handleLoading` |
|---|---|---|
| `HomeBloc` | `HomeViewInitialized` lần đầu | `true` |
| `HomeBloc` | reload charts (`HomeViewInitialized` từ `needReloadStatisticalCharts`, hoặc event refresh mới) | `false` |
| `HomeBloc` | `HomeCategoryTypeSelected` | `false` |
| `HomeBloc` | `HomeCurrencySelected` (khi đã có currency) | `false` |
| `TransactionsBloc` | `TransactionsViewInitialized` | `true` |
| `TransactionsBloc` | `TransactionsRefreshed` / `TransactionsMonthSelected` / `TransactionsDateRangePicked` / `TransactionsWalletSelected` | `false` |
| `AccountBloc` | `AccountViewInitiated` | `true` |
| `AiChatBloc` | `AiChatViewInitiated` | `true` (giữ) |
| `AiChatBloc` | load-more / send | `false` (đã đúng — đừng phá) |

Home reload: **đừng** tái sử dụng init với loading. Tách event refresh (`HomeDataRefreshed` hoặc flag trên event) **hoặc** `handleLoading: !state.hasInitialized` rồi set `hasInitialized: true` sau load đầu. Cập nhật `home_view.dart` listener `needReloadStatisticalCharts` cho khớp.

**Xong khi:** đổi chip Home / filter Transactions / reload sau tạo GD **không** hiện skeleton full body; chỉ first visit (hoặc tab lazy lần đầu) mới hiện.

### Phase 4 — Skeleton 4 màn (compose primitive)

File theo CODING_RULES §7.5: `lib/ui/views/<feature>/widgets/<screen>_loading_skeleton_widget.dart`, class public, export `lib/ui/ui.dart`.

Bọc cây skeleton bằng `CommonShimmer` (1 ticker / màn). Padding khớp `buildPage` (`Dimens.d16.responsive()` horizontal, v.v.). `physics: NeverScrollableScrollPhysics()` nếu scroll.

#### Home — `HomeLoadingSkeletonWidget`

Bám layout `home_view.dart` (không cần pixel-perfect chart):

- Label nhỏ + amount lớn (`d40`)
- 2 chip ngang (`d72`, gap `d12`)
- `CommonShimmerPanel`: title + 3 `CommonShimmerListTile` (all wallets)
- `CommonShimmerPanel`: title + 2 tab giả + khối chart ~ `Dimens.d330.responsive()` (không dùng `d280` như shimmer cũ)
- `CommonShimmerPanel`: title + 3 `CommonShimmerListTile` (recent)

Không `SafeArea` trùng AppBar. Không `ColoredBox` full-screen đè chrome.

#### Transactions — `TransactionsLoadingSkeletonWidget`

Bám `transactions_view.dart`:

- Chip ví giữa (`CommonChipButton`-shaped box)
- Date picker bar (glass)
- 2 panel: title ngày (số lớn + 2 dòng) + 3–4 `CommonShimmerListTile`

#### AI Chat — `AiChatLoadingSkeletonWidget`

- Cột bubble xen kẽ trái/phải (4–5 cái), không full-width
- **Không** thay composer — `AiChatComposerWidget` vẫn dưới, có thể `enabled: false` lúc load history
- Không hiện `AiChatEmptyStateWidget` khi `CommonBloc.isLoading`

#### Account — `AccountLoadingSkeletonWidget`

- `CommonShimmerCircle` ~ `d80` (avatar overlap như layout thật)
- 2 dòng tên / email trong panel
- 2 panel menu: vài `CommonShimmerListTile` (utilities + supportive)
- Sign-out button: box giả **hoặc** hiện `CommonButton` disabled — chọn 1, nhất quán

**Xong khi:** 4 tab first load thấy skeleton trong body, AppBar title đúng màn, bottom nav không bị overlay Lottie.

### Phase 5 — Test + verify

Cập nhật test bloc hiện có nếu đổi `handleLoading` / event reload (chúng mock `LoadingVisibilityEmitted`):

- `test/ui/views/home/bloc/home_bloc_test.dart`
- `test/ui/views/transactions/bloc/transactions_bloc_test.dart`
- `test/ui/views/ai_chat/bloc/ai_chat_bloc_test.dart` (chỉ nếu đụng)
- Account bloc test nếu có

Không bắt buộc widget test primitive trừ khi thêm logic nhánh (null / missing ancestor). Nếu `CommonShimmerBox` **require** ancestor: document + fallback an toàn hoặc `assert` rõ.

Verify:

```bash
fvm dart format <các file đã đụng>
make analyze
make testing
```

---

## Ngoài scope

- Tách `_private` widget trong `home_view.dart` / `transactions_view.dart` / `account_view.dart` (CODING_RULES §7.5 — đừng refactor hàng loạt).
- Skeleton màn khác (wallets, categories, create/edit, budgets overview).
- Đổi `AppLoadingWidget` / Lottie.
- Xóa `shimmer` khỏi `pubspec.yaml`.
- iOS / Android / CI / `env/`.
- Commit / push / PR.

---

## Checklist trước khi báo xong

- [ ] Primitive common, 1 ticker shared
- [ ] `HomeLoadingShimmer` xóa; 4 skeleton màn ở `views/<feature>/widgets/`
- [ ] `useSkeletonLoading` trên 4 tab; overlay Lottie tắt đúng những màn đó
- [ ] AppBar + bottom nav visible lúc skeleton
- [ ] Filter / refresh / category / currency **không** flash skeleton full body
- [ ] AI Chat: loading ≠ empty state
- [ ] Barrel `lib/ui/ui.dart`
- [ ] Test bloc cập nhật; `make analyze` + `make testing` pass
- [ ] Không hard-code color / duration / magic number

---

## Prompt cho coding agent

Copy nguyên khối dưới:

```
Đọc CLAUDE.md, CODING_RULES.md, AGENTS.md trước. Làm đúng spec docs/skeleton-loading.md. Không commit / push / PR.

Task: skeleton loading thay AppLoadingWidget (Lottie overlay) trên first paint của 4 màn gốc bottom nav: Home, Transactions, AiChatView (tab Budgets), Account.

Hướng bắt buộc: giữ CommonAppBar + bottom nav; skeleton CHỈ replace body trong NoirScaffoldBody. Không overlay skeleton lên cả Scaffold. Không AppBar giả.

Làm theo phase trong spec:

1. Primitive common trong lib/ui/widgets/ (tách/refactor common_shimmer.dart):
   CommonShimmer (1 AnimationController share), CommonShimmerBox (không tự ticker), CommonShimmerCircle, CommonShimmerListTile, CommonShimmerPanel (AppDecorations.glassPanel()).
   Xóa HomeLoadingShimmer khỏi common_shimmer.dart.
   Duration shimmer → DurationConstants. Token màu backgroundShimmer / backgroundShimmerHighlight. Dimens.dXX.responsive().
   Không import package shimmer. Không xóa shimmer khỏi pubspec.

2. BasePageState: thêm useSkeletonLoading (default false). false = giữ Stack + AppLoadingWidget. true = không overlay Lottie; body đọc CommonBloc.isLoading (BlocBuilder + buildWhen) → skeleton | content.
   4 tab set useSkeletonLoading => true.

3. handleLoading chỉ first load. Filter/refresh/category/currency = handleLoading: false.
   Home reload charts (listener needReloadStatisticalCharts đang add HomeViewInitialized) phải không hiện skeleton — tách event refresh hoặc flag hasInitialized. AiChat load-more/send đã handleLoading: false thì giữ nguyên.
   AI Chat: đừng hiện AiChatEmptyStateWidget khi đang load history.

4. Skeleton màn (CODING_RULES §7.5):
   lib/ui/views/home/widgets/home_loading_skeleton_widget.dart
   lib/ui/views/transactions/widgets/transactions_loading_skeleton_widget.dart
   lib/ui/views/ai_chat/widgets/ai_chat_loading_skeleton_widget.dart
   lib/ui/views/account/widgets/account_loading_skeleton_widget.dart
   Class public, export lib/ui/ui.dart, compose primitive, bọc CommonShimmer.
   Layout bám view thật (Home chart height d330 không d280; AI Chat giữ composer).

5. Cập nhật test bloc liên quan LoadingVisibilityEmitted. Format file đã đụng. make analyze + make testing phải pass.

Ngoài scope: refactor _private widgets hàng loạt, skeleton màn khác, đổi Lottie, native/CI, i18n trừ khi thật sự cần string mới.

Minimize scope. Tra widget/color/dimens hiện có trước khi dựng mới.
```
