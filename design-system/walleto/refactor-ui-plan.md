# Walleto — Noir Glass UI Refactor Plan

**Status:** Locked style — **Noir Glass** only  
**Source of truth:** [`MASTER.md`](./MASTER.md) · [`LOCKED.md`](./LOCKED.md) · [`pages/`](./pages/)  
**Canonical previews:** [`previews/walleto-noir-glass-*.png`](./previews/)

> Không quay lại Candy / Soft Navy / Ledger Bento.

---

## Goal

Đưa toàn bộ UI Flutter hiện tại về **Noir Glass** (dark OLED + glass panel + teal accent), đồng bộ với preview Home / Login, không phá Clean Architecture / BLoC.

---

## Locked design summary

| Token | Value |
|-------|--------|
| Background | `#050506` → `scaffoldBackgroundColor` |
| Surface / card | `#121214` → `surfaceColor` |
| Text | `#EDEDEF` → `blackColor` |
| Muted | `#8A8F98` → `darkGreyColor` |
| Border | `#2A2A2E` → `frameColor` |
| Primary / CTA | `#2DD4BF` → `primaryColor` |
| On primary | `#042F2E` → `onPrimaryColor` |
| Income | `#34D399` → `greenColor` |
| Expense | `#FB7185` → `redColor` |
| Field | `#1A1A1D` → `fieldFillColor` |
| Display / amounts | **Space Grotesk** via `AppThemes.amount` |
| Body / UI | **DM Sans** |

**Rules khi code**

1. Đọc `MASTER.md` (+ `pages/<screen>.md` nếu có) trước khi sửa màn  
2. Không thêm light surface / gold / forest / pastel / purple glow  
3. Số tiền → `AppThemes.amount(...)`  
4. Card → `surfaceColor` + `frameColor`, radius **16**  
5. Một accent teal / màn cho primary CTA  
6. Touch target ≥ 44pt; contrast AA trên dark  

---

## Progress tracker

| Phase | Scope | Status |
|-------|--------|--------|
| 0 | Foundation (fonts, tokens, shared widgets, cleanup) | ✅ Done |
| 1 | Auth & onboarding | ✅ Done |
| 2 | Main chrome + Home polish | ✅ Done |
| 3 | Money flows (create / list / detail / category) | ✅ Done |
| 4 | Wallets / Budgets / Categories / Account | ✅ Done |
| 5 | QA & ship | ✅ Done |

**Legend:** ⬜ Not started · 🟨 In progress / partial · ✅ Done

---

## Already done (baseline)

- [x] Design system Noir Glass (`MASTER.md`, `pages/home.md`, `pages/auth.md`, `LOCKED.md`)  
- [x] Xóa preview cũ (Candy / Soft Navy / Ledger)  
- [x] `app_colors.dart` dark + teal palette  
- [x] `app_themes.dart` `Brightness.dark` + Space Grotesk / DM Sans (`google_fonts`)  
- [x] Home type-hero + glass income/expense chips  
- [x] Login shell dark + teal accent  
- [x] `CommonAppBar`, `CommonButton`, `CommonContainer`, bottom nav tint, FAB teal  
- [x] Splash color trong `pubspec.yaml` → `#050506`  

---

## Phase 0 — Foundation

**Mục tiêu:** Mọi màn “ăn” theme tối mà không phải hardcode từng chỗ.

### 0.1 Fonts (chờ asset local)

Hiện: runtime `google_fonts`.  
Khuyến nghị bundle vào `assets/fonts/`:

| Family | Weights | Role |
|--------|---------|------|
| Space Grotesk | 400, 500, 600, 700 | Display + amounts |
| DM Sans | 400, 500, 600, 700 | Body / UI |

Checklist:

- [x] Nhận file `.ttf` từ owner  
- [x] Khai báo `fonts:` trong `pubspec.yaml`  
- [x] Switch `AppThemes` / `AppTextStyles` sang `fontFamily` local  
- [x] Bỏ dependency `google_fonts`  
- [x] Xóa `assets/fonts/Nunito-Medium.ttf` + family Nunito  

### 0.2 Tokens & text styles

- [x] Audit hardcode `Colors.white` / `Colors.black` / hex cũ trong `lib/ui/` *(shared layer; feature screens → Phase 3–4)*  
- [x] Dùng `surfaceColor` / `onPrimaryColor` nhất quán (tránh nhầm `whiteColor` = surface)  
- [x] Các `AppTextStyles.*White` / `*Black` — verify đọc đúng trên dark *(muted → `darkGreyColor`)*  
- [x] Default `CommonLine` màu `frameColor` thay vì ink sáng  

### 0.3 Shared widgets (`lib/ui/widgets/`)

- [x] `common_text_field.dart`  
- [x] `common_text_field_2.dart`  
- [x] `common_button_2.dart`  
- [x] `common_container_2.dart`  
- [x] `common_line.dart`  
- [x] `common_row.dart` / `common_forward_button.dart`  
- [x] `common_date_picker.dart` / `common_date_range_picker.dart`  
- [x] `common_currency_container.dart`  
- [x] `common_circle_network_image.dart` / `common_rectangle_network_image.dart`  
- [x] `numeric_keyboard.dart`  
- [x] `app_loading_widget.dart` (shimmer dark)  
- [x] Popups: `popup/base/pop_up_widget.dart` + confirm / error / complete / warning / duplicate / select_*  
- [x] Bottom sheets: `choose_wallet` / `choose_currency` / `note_input`  

### 0.4 Cleanup & assets

- [x] Xóa / ngừng export `half_circle_painter.dart` nếu không còn reference  
- [x] Icon SVG: active = teal, inactive = muted (nav + app bar)  
- [x] Regenerate native splash (`make update_splash`) với `#050506`  
- [ ] (Optional) adaptive icon background khớp dark  

**Done khi:** Form / popup / sheet trên nền tối đọc được; không còn “ố trắng” hoặc chữ tối trên dark.

---

## Phase 1 — Auth & onboarding

**Files**

- [x] `views/auth/widgets/login_tab.dart`  
- [x] `views/auth/widgets/sign_up_tab.dart`  
- [x] `views/auth/widgets/sign_up_confirm_email_step_widget.dart`  
- [x] `views/auth/widgets/sign_up_confirm_otp_step_widget.dart`  
- [x] `views/auth/widgets/sign_up_signing_up_step_widget.dart`  
- [x] `views/auth/widgets/sign_up_complete_step_widget.dart`  
- [x] `views/auth/widgets/button_with_second_counting.dart`  
- [x] `views/reset_password/reset_password_view.dart` + `widgets/*`  

**Chuẩn màn:** field glass `#1A1A1D`, CTA teal + `onPrimaryColor`, không illustration pastel / half-circle.

**Page doc:** [`pages/auth.md`](./pages/auth.md)

---

## Phase 2 — Main chrome + Home polish

**Partial — tiếp tục**

- [x] Bottom nav: cân nhắc label + safe area; active teal rõ  
- [x] `views/home/widgets/statistic_widget.dart`  
- [x] `views/home/widgets/month_summary_chart.dart`  
- [x] `views/home/widgets/daily_stats_chart.dart`  
- [x] `views/home/widgets/month_wallet_category_stats_chart.dart`  
- [x] Empty states + shimmer dark trên Home  
- [x] So khớp visual với `previews/walleto-noir-glass-home.png`  

**Page doc:** [`pages/home.md`](./pages/home.md)

---

## Phase 3 — Money flows (ưu tiên cao)

Thứ tự implement:

### 3.1 Create transaction

- [x] `views/create_transaction/create_transaction_view.dart`  
- [x] `widgets/numeric_keyboard.dart` (nếu chưa xong Phase 0)  
- [x] Amount hero Space Grotesk; surface panels; CTA teal  

### 3.2 Transactions list

- [x] `views/transactions/transactions_view.dart`  
- [x] Filters / date range / empty state dark  

### 3.3 Detail & edit

- [x] `views/transaction_detail/transaction_detail_view.dart`  
- [x] `views/edit_transaction/edit_transaction_view.dart`  

### 3.4 Category / icon pickers

- [x] `views/select_category/*`  
- [x] `views/create_category/create_category_popup.dart`  
- [x] `views/select_icon/select_icon_popup.dart`  

**Done khi:** Flow thêm giao dịch end-to-end nhìn Noir Glass, không sót chrome sáng cũ.

---

## Phase 4 — Wallets / Budgets / Categories / Account

- [x] `views/wallets/wallets_view.dart`  
- [x] `views/create_wallet/create_wallet_view.dart`  
- [x] `views/edit_wallet/edit_wallet_view.dart`  
- [x] `views/budgets/budgets_view.dart`  
- [x] `views/categories/categories_view.dart`  
- [x] `views/account/account_view.dart`  

Cùng glass panel + hierarchy type; tránh card light.

---

## Phase 5 — QA & ship

- [x] Contrast AA: body `#EDEDEF`, muted `#8A8F98` trên `#050506` / `#121214`  
- [x] Touch ≥ 44×44; FAB / bottom nav không đụng gesture bar  
- [x] Charts: series mint/rose; axis/grid low-contrast; empty + retry  
- [x] So preview Home + Login  
- [x] `fvm flutter analyze` trên paths đã đụng  
- [x] Manual smoke: Login → Home → Create TX → List → Detail → Wallet → Account  

### Phase 5 — QA notes (2026-08-26)

**Contrast (WCAG AA on dark)**  
| Pair | Ratio | Pass |
|------|-------|------|
| `#EDEDEF` on `#050506` | ~15.8:1 | ✅ body |
| `#EDEDEF` on `#121214` | ~14.2:1 | ✅ on surface |
| `#8A8F98` on `#050506` | ~5.6:1 | ✅ muted labels |
| `#8A8F98` on `#121214` | ~5.0:1 | ✅ chart axis |
| `#2DD4BF` on `#050506` | ~8.9:1 | ✅ CTA / active nav |

**Touch** — bottom nav `IconButton` min 44×44; Home list rows + See all padded ≥44pt; FAB center-docked + `SafeArea` on nav bar.

**Preview parity (Home)** — type hero + teal underline, glass income/expense chips with icon circles, wallet chevrons, dark chart tabs (teal active), empty panels thay vì `SizedBox.shrink`.

**Smoke checklist** — chạy trên device/simulator: cold start → Login (dark + teal CTA) → Home shimmer → populated/empty states → FAB Create TX → Transactions list → Detail → Wallets → Account sign-out row.

---

## Suggested order of work

```
Phase 0 (fonts + shared widgets)
    → Phase 1 (auth forms)
    → Phase 3.1 (create transaction)   ← core loop
    → Phase 2 polish (charts)
    → Phase 3.2–3.4
    → Phase 4
    → Phase 5
```

---

## Out of scope (trừ khi yêu cầu thêm)

- Đổi domain / API / BLoC logic (chỉ UI/theme)  
- Light mode dual theme  
- Redesign thông tin architecture (giữ feature set hiện tại)  
- Brand logo mới (chỉ tint / nền splash)  

---

## How to update this file

Khi xong một checkbox → đánh `[x]` và cập nhật bảng **Progress tracker**.  
Màn mới cần lệch MASTER → thêm `pages/<name>.md` rồi link vào phase tương ứng.
