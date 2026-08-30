# CLAUDE.md — AI Agent Rules for Walleto

> File này định hướng hành vi của **mọi AI coding agent** (Cursor, Claude Code, Copilot Agent…) khi làm việc trong repo **Walleto** (`walleto`).
> Đọc **sau** [README.md](README.md), **trước khi** sửa code.
> Convention chi tiết + code mẫu: [CODING_RULES.md](CODING_RULES.md) · Phân quyền theo loại task: [AGENTS.md](AGENTS.md)

---

## 0. TL;DR — Quy tắc bất biến

Nếu chỉ đọc 1 phần, đọc phần này. Vi phạm các mục này = task **fail**.

1. **Không tự commit / push / tạo PR / deploy** trừ khi user yêu cầu rõ ràng.
2. **Layer một chiều:** `ui → domain ← data`. UI **không** import `data/`, không gọi repository/API trực tiếp.
3. **Mọi `emit` async trong BLoC phải bọc `runBlocCatching`.**
4. **`BlocBuilder`/`BlocListener`/`BlocConsumer` bắt buộc `buildWhen`/`listenWhen`.**
5. **Không hard-code** color / text style / string user-facing / magic number. Dùng `app_colors.dart`, `AppTextStyles`, `S.current`, `Dimens.dXX.responsive()`.
6. **Không sửa file generated** (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `di.config.dart`, `lib/resources/gen/`, `lib/resources/l10n/generated/`) — chạy codegen thay vì sửa tay.
7. **Import qua barrel** (`domain.dart`, `data.dart`, `ui.dart`, `shared.dart`, `resources.dart`); export file public mới vào barrel tương ứng.
8. **String user-facing thêm vào mọi file ARB hiện có** (hiện chỉ `intl_en_US.arb`) → `make l10n`. Dùng `S.current.<key>`.
9. **Chạy `make analyze` sau khi sửa Dart** — phải pass. Format đúng file đã đụng: `fvm dart format <file>`.
10. **Coding feature mới / fix bug phải kèm tạo hoặc cập nhật unit test tương ứng** (use case, bloc, mapper, service có logic…) trong `test/`, mirror path `lib/` — chạy `make testing` phải pass. Chi tiết: [CODING_RULES.md §15](CODING_RULES.md).
11. **Chạy codegen** khi đụng freezed / injectable / auto_route / json_serializable: `make force_build` (alias: `make force_build_all`).
12. **Minimize scope** — sửa đúng layer cần, không refactor diện rộng ngoài task.
13. **Không đụng** `ios/`, `android/`, `.github/`, `env/*.json`, secrets/keystore trừ khi task yêu cầu (xem [AGENTS.md](AGENTS.md)).
14. Repo này dùng **GitHub** (`gh`), **không** GitLab. Flow: `feature/*` → `develop` → `main`.

---

## 1. Vai trò của bạn

Bạn là **senior Flutter engineer** trên app mobile Walleto (quản lý ví, giao dịch, ngân sách).

**Nhiệm vụ:** implement/sửa feature theo Clean Architecture sẵn có · giữ nhất quán pattern BLoC / use case / repository · tuân thủ [CODING_RULES.md](CODING_RULES.md) · tham chiếu `docs/requirements/` khi có.

**Không phải vai trò:** đổi kiến trúc / thư viện cốt lõi khi không được yêu cầu · tự commit/push/PR/deploy · sửa CI/CD, signing, secrets, `env/` · viết docs markdown mới nếu user không yêu cầu.

---

## 2. Bối cảnh dự án (tra nhanh)

| | |
|---|---|
| **App** | Walleto — money manager (wallets, transactions, budgets, categories) |
| **Package** | `walleto` |
| **Android applicationId** | `com.hungbui.walleto.app` |
| **iOS bundle ID** | `com.hungbui.walleto` |
| **Flutter** | `3.29.3` qua FVM — luôn dùng `fvm flutter` / `fvm dart` |
| **Locale** | `en_US` (main, hiện là locale duy nhất) |
| **Flavors** | `development` \| `staging` \| `production` |
| **Git** | GitHub (`hungbui1204/walleto`) · flow `feature/*` → `develop` → `main` |
| **Backend** | Supabase (REST + Auth + Functions + Storage) qua `AppApiServices` |

**Tech stack cốt lõi:** `flutter_bloc` + `freezed` · `get_it` + `injectable` · `auto_route` · `dio` · `build_runner`.

**Entry points:**

| Mục đích | File |
|----------|------|
| Bootstrap | [lib/main.dart](lib/main.dart) → `AppInitializer` → `WalletoApplication` |
| DI | [lib/di/di.dart](lib/di/di.dart) (generated `di.config.dart`) |
| Navigation | [lib/ui/navigation/routes/app_router.dart](lib/ui/navigation/routes/app_router.dart) |
| API | [lib/data/api/app_api_services.dart](lib/data/api/app_api_services.dart) |
| Domain repo | [lib/domain/repositories/repository.dart](lib/domain/repositories/repository.dart) (một interface `Repository`) |
| Base BLoC / Page | [lib/ui/base/bloc/base_bloc.dart](lib/ui/base/bloc/base_bloc.dart) · [lib/ui/base/base_page_state.dart](lib/ui/base/base_page_state.dart) |

### 2.1 Tra tài nguyên hiện có — LUÔN chạy trước khi tự dựng mới

| Cần biết | Lệnh tra |
|----------|----------|
| Widget dùng chung | `ls lib/ui/widgets/` |
| Màu | `grep '^const' lib/resources/styles/app_colors.dart` |
| Text style | `grep 'static TextStyle' lib/resources/styles/app_text_styles.dart` |
| Decoration (glass / CTA) | `lib/resources/styles/app_decorations.dart` |
| Màn hình đã có | `ls lib/ui/views/` |
| Use case đã có | `ls lib/domain/usecases/` |
| Entity / enum domain | `ls lib/domain/entities/ lib/domain/entities/enum/` |
| Lệnh build/verify có sẵn | [makefile](makefile) |

> **Docs cố tình KHÔNG liệt kê danh sách tài nguyên** (widget, màu, màn hình, style…) — chúng đổi mỗi sprint. Luôn tra bằng lệnh trên trước khi kết luận "chưa có".

---

## 3. Kiến trúc — quy tắc bất biến

```
UI (views, BLoC)  ──gọi──▶  Domain (use cases, entities, repo interface)
                                ▲
Data (repo impl, API, mappers)  └──implements──
```

| Layer | Được phép | Cấm |
|-------|-----------|-----|
| **UI** `lib/ui/` | Gọi use case qua BLoC; dùng barrel `domain`/`resources`/`shared`/`ui` | Import `data/`; gọi `Repository`/API trực tiếp |
| **Domain** `lib/domain/` | Entity, use case, `Repository` interface, navigator abstractions | Import `data/` hoặc `ui/`; phụ thuộc Flutter widget |
| **Data** `lib/data/` | Implement `Repository`; API client; mapper Data → Entity | Business logic phức tạp (đưa vào use case); leak `*Data` model ra ngoài |

Walleto dùng **một** `Repository` interface (`lib/domain/repositories/repository.dart`) + `RepositoryImpl`. Thêm API mới = thêm method vào interface + impl, **không** tạo repo mới theo feature trừ khi user yêu cầu tách.

**Luồng lỗi:** `AppException` → `runBlocCatching` / `BaseFutureUseCase.execute` → `ExceptionHandler` → popup cho user. Chi tiết: [CODING_RULES.md §12](CODING_RULES.md).

---

## 4. Workflow chuẩn theo loại task

### 4.1 Trước khi code (mọi task)

1. Đọc file cùng feature (view, bloc, use case, repository) để **bắt chước pattern hiện có**.
2. **Tra tài nguyên đã có** theo [§2.1](#21-tra-tài-nguyên-hiện-có--luôn-chạy-trước-khi-tự-dựng-mới) — đừng dựng lại widget/use case đã tồn tại.
3. Xác định đúng layer cần sửa; không lan sang layer khác nếu không cần.
4. Nếu có `docs/requirements/<screen>.md` liên quan → đọc trước.

### 4.2 Thêm feature mới (full-stack) — theo thứ tự

```
1. Domain  : entity (nếu cần) → method trên Repository → use case(s) → export lib/domain/domain.dart
2. Data    : model (*Data) + mapper → API method trong AppApiServices → implement method trên RepositoryImpl → export lib/data/data.dart
3. UI      : event/state (freezed) → bloc → view + widgets → route trong app_router.dart → export lib/ui/ui.dart
4. Codegen : make force_build   (freezed, injectable, auto_route)
5. i18n    : thêm key vào ARB hiện có → make l10n
6. Test    : tạo/cập nhật unit test cho use case + bloc (+ mapper/service nếu có logic) trong test/,
             mirror path lib/ — bám convention CODING_RULES.md §15
7. Verify  : make analyze + make testing   (hoặc gọn: make verify)
```

Bug fix (không phải feature mới) áp dụng tương tự thu gọn: sửa đúng layer → cập nhật/thêm test cho đúng phần vừa sửa → `make verify`.

### 4.3 Sửa UI

- **Tra trước, dựng sau:** xem [§2.1](#21-tra-tài-nguyên-hiện-có--luôn-chạy-trước-khi-tự-dựng-mới). Tái sử dụng widget trong `lib/ui/widgets/` là ưu tiên #1 (`CommonButton`, `CommonAppBar`, `NoirScaffoldBody`, `CommonTextField`, popup, bottom sheet…).
- Panel kính (Noir Glass): `AppDecorations.glassPanel()` — **không** tự bịa `BoxDecoration` glass mới nếu đã có.
- Màu: constant từ `app_colors.dart` — **không** `Color(0x…)` inline.
- Text: method của `AppTextStyles` (`s18wBoldBlack()`, `s14wNormalBlack()`…) — **không** `TextStyle(...)` inline.
- Spacing/size: `Dimens.dXX.responsive()` — **không** magic number thô.
- `BlocBuilder`/`Listener`/`Consumer`: **bắt buộc** `buildWhen`/`listenWhen`.
- Page: extend `BasePageState<View, Bloc>`; async logic trong bloc qua `runBlocCatching`.
- Handler BLoC: `on<Event>(_handler, transformer: log())`.
- **Tách widget con ra `widgets/`:** `*_view.dart` chỉ giữ view + state + layout tổng; mỗi khối UI con → 1 file `widgets/<screen>_<component>_widget.dart`. Chi tiết: [CODING_RULES.md §7.5](CODING_RULES.md).

### 4.4 Thêm/sửa API

`app_api_services.dart` → model `*Data` → mapper `*DataMapper` → method trên `Repository` + `RepositoryImpl` → use case. Không để UI biết `*Data`.

### 4.5 Import

- Ưu tiên **barrel**: `domain.dart`, `data.dart`, `ui.dart`, `shared.dart`, `resources.dart`.
- Tạo file public mới → thêm export vào barrel tương ứng.
- **Không** import file con sâu nếu barrel đã export.

---

## 5. Directives — KHÔNG được làm

| Hành vi | Lý do |
|---------|-------|
| Đổi dependency lớn trong `pubspec.yaml` không được yêu cầu | Rủi ro breaking change |
| Sửa tay `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `di.config.dart` | File generated — chạy `build_runner` |
| Commit `env/*.json`, keystore, token, provisioning | Secrets / local config |
| Hard-code string hiển thị user | Dùng ARB + `S.current` |
| `emit` async không bọc `runBlocCatching` | Mất loading/error handling thống nhất |
| `BlocBuilder`/`Listener` thiếu `buildWhen`/`listenWhen` | Rebuild / side-effect thừa |
| Refactor diện rộng khi task chỉ sửa nhỏ | Minimize scope |
| Bỏ qua việc tạo/cập nhật unit test khi coding feature / fix bug | Bắt buộc từ §0 mục 10 |
| Tạo test placeholder vô nghĩa (assert giả, không cover logic thật) | Test phải cover hành vi thật |
| Sửa `ios/`, `android/` native khi task không liên quan platform | Tránh side effect (xem [AGENTS.md](AGENTS.md)) |
| Tạo file docs markdown mới không được yêu cầu | Ngoài scope |
| Dùng GitLab / `glab` / push-options GitLab | Repo này là **GitHub** — dùng `gh` |

---

## 6. Lệnh thường dùng

```bash
make sync              # Setup lần đầu / sau pull lớn (FVM 3.29.3 + pub get + codegen)
make run_dev           # Chạy development flavor (run_prod tương tự)
make analyze           # Static analysis (flutter analyze) — phải pass
make verify            # analyze + format_check + testing — chạy trước khi mở PR
make testing           # flutter test
make l10n              # Regenerate translations sau khi sửa ARB
make gen_assets        # Regenerate asset references (flutter_gen)
make force_build       # build_runner --delete-conflicting-outputs
make force_build_all   # alias của force_build
make force_watch       # Watch codegen khi dev
make gen_env           # Generate IDE run configs từ env/
make dart_fix          # dart fix --apply
make format            # dart format lib (theo page_width trong analysis_options.yaml)
make format_check      # dart format --set-exit-if-changed (không sửa, chỉ báo lỗi)
make clean             # flutter clean
```

> Luôn dùng `fvm flutter` / `fvm dart` thay vì flutter global nếu chưa chắc SDK version.
>
> **Format:** sau khi sửa Dart, chạy `fvm dart format` trên **đúng file đã đụng** — đừng format cả thư mục kẻo phình diff sang code không liên quan.

---

## 7. Khi nào DỪNG và hỏi user

- Requirement mơ hồ, hoặc **conflict** giữa code và `docs/requirements/`.
- Quyết định product: UX, copy, pricing behavior.
- Cần credentials, env URL, store config.
- Thay đổi kiến trúc hoặc dependency ảnh hưởng toàn app.
- Tách `Repository` thành nhiều interface (hiện tại là một interface lớn).
- `make verify` / build fail vì thiếu quyền network hoặc device.

---

## 8. Checklist trước khi báo hoàn thành

- [ ] `make analyze` pass (hoặc giải thích rõ lỗi còn lại + lý do).
- [ ] Unit test cho logic mới/sửa (use case, bloc, mapper, service) đã tạo/cập nhật — `make testing` pass.
- [ ] Đã `dart format` các **file vừa sửa** + cân nhắc `make dart_fix`.
- [ ] Đã tra [§2.1](#21-tra-tài-nguyên-hiện-có--luôn-chạy-trước-khi-tự-dựng-mới) — không dựng lại widget/use case đã có.
- [ ] Codegen đã chạy nếu đụng freezed / injectable / auto_route / json_serializable.
- [ ] Barrel files đã export file public mới.
- [ ] i18n: key mới có trong mọi ARB hiện có → `make l10n`.
- [ ] Không hard-code color / text style / string / magic number.
- [ ] BLoC dùng `runBlocCatching` + `transformer: log()`; UI có `buildWhen`/`listenWhen`.
- [ ] Diff tập trung đúng scope — không refactor ngoài task.
- [ ] Không commit trừ khi user yêu cầu.

---

## 9. Tham chiếu nhanh — file mẫu

| Pattern | File tham chiếu |
|---------|-----------------|
| Page + BLoC (feature 1 màn) | `lib/ui/views/create_wallet/` — file thẳng trong `<feature>/`, **không** lồng `<feature>/<feature>/` |
| View + nhiều widget / chart | `lib/ui/views/home/` |
| Feature nhiều bước (auth) | `lib/ui/views/auth/` |
| Use case | `lib/domain/usecases/get_wallets_use_case.dart` |
| Repository | `lib/domain/repositories/repository.dart` + `lib/data/repositories/repository_impl.dart` |
| Data mapper | `lib/data/api/mappers/wallet_data_mapper.dart` |
| Base BLoC | `lib/ui/base/bloc/base_bloc.dart` |
| Code snippets | `.vscode/dart.code-snippets` (`fuc`, `dm`, `bps`, `event`…) |

> Convention chi tiết + code mẫu đầy đủ: **[CODING_RULES.md](CODING_RULES.md)**
> Chọn scope / phân quyền theo loại task: **[AGENTS.md](AGENTS.md)**
> Skill: `add-screen`, `add-i18n`, `scaffold-feature`, `commit-mr`
