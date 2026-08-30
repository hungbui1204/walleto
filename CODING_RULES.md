# CODING_RULES.md — Walleto Coding Conventions

> Guideline chi tiết cho dev & AI agent. Mỗi rule kèm **code mẫu** để bắt chước.
> Quy tắc hành vi AI tổng quan: [CLAUDE.md](CLAUDE.md) · Phân quyền theo task: [AGENTS.md](AGENTS.md)

---

## Cheat sheet (copy nhanh)

| Cần làm | Dùng | Không dùng |
|---------|------|------------|
| Màu | `primaryColor`, `scaffoldBackgroundColor` (`app_colors.dart`) | `Color(0xFF...)` |
| Text style | `AppTextStyles.s18wBoldBlack()` | `TextStyle(...)` |
| Panel kính | `AppDecorations.glassPanel()` | `BoxDecoration` glass tự bịa |
| Spacing/size | `Dimens.d16.responsive()` | `16`, `EdgeInsets.all(16)` |
| String user | `S.current.home` + ARB | `Text('Home')` |
| Async trong BLoC | `runBlocCatching(action: ...)` | `emit` trần |
| Rebuild UI | `buildWhen` / `listenWhen` | thiếu 2 cái này |
| Import | barrel (`domain.dart`…) | import file con sâu |
| Gọi data từ UI | use case qua BLoC | `Repository`/API trực tiếp |
| Logic dẫn xuất trên entity/`*Data` | `domain/utils/<entity>_extensions.dart` (§5.1) | getter/method nghiệp vụ thêm thẳng vào entity |

---

## Mục lục

1. [Kiến trúc & phụ thuộc layer](#1-kiến-trúc--phụ-thuộc-layer)
2. [Cấu trúc thư mục](#2-cấu-trúc-thư-mục)
3. [Naming conventions](#3-naming-conventions)
4. [Barrel files & imports](#4-barrel-files--imports)
5. [Domain layer](#5-domain-layer)
6. [Data layer](#6-data-layer)
7. [UI layer & BLoC](#7-ui-layer--bloc)
8. [Design system & UI styling](#8-design-system--ui-styling)
9. [Localization (i18n)](#9-localization-i18n)
10. [Navigation](#10-navigation)
11. [Dependency injection](#11-dependency-injection)
12. [Error handling](#12-error-handling)
13. [Codegen](#13-codegen)
14. [Lint & formatting](#14-lint--formatting)
15. [Testing](#15-testing)
16. [Git, commit & PR](#16-git-commit--pr)
17. [Phụ lục — checklist feature mới](#phụ-lục--checklist-feature-mới)

---

## 1. Kiến trúc & phụ thuộc layer

**Clean Architecture** 3 layer, dependency rule một chiều:

```
lib/ui/  ──calls──▶  lib/domain/  ◀──implements──  lib/data/
```

| Layer | Trách nhiệm |
|-------|-------------|
| **domain** | Business rules: entities, use cases, `Repository` interface |
| **data** | API, persistence, mappers, `RepositoryImpl` |
| **ui** | Widgets, BLoC, navigation, exception UI |

**✅ Đúng — BLoC gọi use case:**

```dart
// lib/ui/views/create_wallet/bloc/create_wallet_bloc.dart
await runBlocCatching(
  action: () async {
    await _createWalletUseCase.execute(
      CreateWalletInput(wallet: wallet),
    );
    emit(state.copyWith(isSuccess: true));
  },
);
```

**❌ Sai — BLoC gọi repository / API trực tiếp:**

```dart
final wallets = await _repository.getWallets(); // ❌ UI/BLoC không được gọi
```

Walleto dùng **một** `Repository` (không tách repo theo feature). Thêm API = thêm method vào interface + `RepositoryImpl`. Không tự tách repo trừ khi user yêu cầu.

---

## 2. Cấu trúc thư mục

```
lib/
├── config/              # AppConfig
├── data/
│   ├── api/             # Dio clients, AppApiServices, models, mappers, middleware
│   ├── preferences/     # SharedPreferences / secure storage
│   └── repositories/    # RepositoryImpl
├── di/                  # get_it + injectable (di.dart, di.config.dart generated)
├── domain/
│   ├── entities/        # Pure Dart models (+ entities/enum/)
│   ├── repositories/    # abstract Repository
│   ├── usecases/        # Flat: <verb>_<noun>_use_case.dart + base/
│   └── navigation/      # AppNavigator, AppRouteInfo, AppPopupInfo (abstractions)
├── initializer/         # App initialization
├── resources/           # styles, dimens, l10n, gen assets
├── shared/              # constants, extensions, exceptions, utils
└── ui/
    ├── app/             # Root app widget, AppBloc
    ├── base/            # BasePageState, BaseBloc, base event/state
    ├── navigation/      # auto_route, guards, mappers
    ├── views/           # Feature screens — danh sách thật: `ls lib/ui/views/`
    │   ├── <feature>/           # Feature 1 màn → file nằm THẲNG trong <feature>/
    │   │   ├── bloc/
    │   │   ├── widgets/
    │   │   └── <feature>_view.dart
    │   └── <feature>/           # Feature nhiều màn (vd auth/) → mỗi màn 1 thư mục con
    └── widgets/         # Shared: Common*, NoirScaffoldBody, popup/, bottom_sheet/
```

**Đặt feature mới:**

- **Feature 1 màn hình** (mặc định): file nằm thẳng trong `lib/ui/views/<feature>/` — **KHÔNG** lồng `<feature>/<feature>/`.
  Vd: `lib/ui/views/create_wallet/create_wallet_view.dart`.
- **Feature nhiều màn / nhiều bước** (vd `auth/`): mỗi màn hoặc nhóm bước trong `lib/ui/views/<feature>/`.
- BLoC: `bloc/<screen>_bloc.dart` + `*_event.dart` + `*_state.dart` (part files)
- Widget con: `widgets/<screen>_<component>_widget.dart`
- Use case: **flat** trong `lib/domain/usecases/<verb>_<noun>_use_case.dart` (không tạo folder theo feature trừ khi user yêu cầu)

---

## 3. Naming conventions

| Loại | Convention | Ví dụ |
|------|------------|-------|
| File | `snake_case.dart` | `create_wallet_view.dart` |
| Class | `PascalCase` | `CreateWalletView` |
| Entity | Danh từ | `Wallet`, `Transaction` |
| Use case | `<Verb><Noun>UseCase` | `GetWalletsUseCase` |
| Use case I/O | `<UseCase>Input` / `Output` | `GetWalletsInput` |
| Repository | `Repository` / `RepositoryImpl` | (một interface) |
| Data model (API) | `<Noun>Data` | `WalletData` |
| Mapper | `<Noun>DataMapper` | `WalletDataMapper` |
| BLoC | `<Screen>Bloc` | `CreateWalletBloc` |
| Event | `<Screen><Action>` | `CreateWalletConfirmButtonPressed` |
| View | `<Screen>View` | `CreateWalletView` |
| Widget | `<Screen><Purpose>Widget` | `HomeRecentTransactionsWidget` |
| Enum domain | `PascalCase` trong `entities/enum/` | `CategoryType` |
| Route (generated) | `<Screen>Route` | `CreateWalletRoute` |

**Event naming — mô tả ý định user/system, không mô tả implementation:**

```dart
// ✅
const factory CreateWalletConfirmButtonPressed() = _CreateWalletConfirmButtonPressed;

// ❌
const factory CreateWalletCallCreateApi() = _CreateWalletCallCreateApi;
```

---

## 4. Barrel files & imports

**Luôn import qua barrel khi có thể:**

```dart
import 'package:walleto/domain/domain.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/ui/ui.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/resources/resources.dart';
```

**Tạo file public mới → thêm export vào barrel tương ứng:**

| File mới | Barrel |
|----------|--------|
| `lib/domain/**` (entity, use case, repo interface) | `lib/domain/domain.dart` |
| `lib/data/**` (mapper, repo impl, model dùng chung) | `lib/data/data.dart` |
| `lib/ui/**` (view, widget dùng chung) | `lib/ui/ui.dart` |
| `lib/shared/**` (util, extension, constant) | `lib/shared/shared.dart` |
| `lib/resources/**` (style, dimens…) | `lib/resources/resources.dart` |

**Thứ tự import (`directives_ordering`):**

1. `dart:`
2. `package:` — Flutter SDK trước → third-party → `walleto`
3. Relative imports (hạn chế — ưu tiên package import)

---

## 5. Domain layer

### 5.1 Entities

- Pure Dart; dùng `freezed` khi cần immutability / `copyWith`.
- **Không** import `flutter/`, `dio`, hay `data/`.
- **Chỉ chứa field + constructor.** **Không** thêm computed getter, method nghiệp vụ, hay static helper vào entity/`*Data` model.
- Logic dẫn xuất từ field → `lib/domain/utils/<entity>_extensions.dart` (Dart `extension`). Nếu cần Flutter/`S` → `lib/shared/extensions/`.
- Logic kết hợp **nhiều** entity → class helper `static` trong `domain/utils/`.

```dart
// lib/domain/entities/wallet.dart — chỉ field + constructor
@freezed
sealed class Wallet with _$Wallet {
  const factory Wallet({
    @Default(0) int id,
    @Default('') String name,
    @Default(0) double amount,
    String? userId,
    @Default('') String iconUrl,
    @Default('') String currencyCode,
  }) = _Wallet;
}
```

### 5.2 Use cases

- Extend `BaseFutureUseCase<Input, Output>` (`lib/domain/usecases/base/future/base_future_use_case.dart`).
- Annotate `@injectable`.
- Logic trong `buildUseCase`; `execute` đã lo logging + wrap `AppException`.
- Input/Output: `@freezed sealed class` extends `BaseInput` / `BaseOutput`.
- Inject `Repository` (một interface), **không** inject API client.

```dart
@injectable
class GetWalletsUseCase extends BaseFutureUseCase<GetWalletsInput, GetWalletsOutput> {
  const GetWalletsUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetWalletsOutput> buildUseCase(GetWalletsInput input) async {
    final response = await _repository.getWallets();

    return GetWalletsOutput(wallets: response);
  }
}

@freezed
sealed class GetWalletsInput extends BaseInput with _$GetWalletsInput {
  const GetWalletsInput._();
  const factory GetWalletsInput() = _GetWalletsInput;
}

@freezed
sealed class GetWalletsOutput extends BaseOutput with _$GetWalletsOutput {
  const GetWalletsOutput._();
  const factory GetWalletsOutput({
    @Default(<Wallet>[]) List<Wallet> wallets,
  }) = _GetWalletsOutput;
}
```

Snippet VS Code: prefix `fuc`.

### 5.3 Repository interface

- Một file: `lib/domain/repositories/repository.dart`.
- Method return **entity** domain (không phải `*Data`).
- Thêm API mới → thêm method vào đây + `RepositoryImpl`.

```dart
abstract class Repository {
  Future<List<Wallet>> getWallets();
  Future<void> createWallet(Wallet wallet);
}
```

---

## 6. Data layer

### 6.1 API models

- Suffix `Data`; JSON qua `freezed` + `json_serializable`.
- Chỉ dùng nội bộ data layer.
- **Chỉ chứa field + `fromJson`/`toJson`.** Parse/transform thuộc về mapper.

```dart
@freezed
sealed class WalletData with _$WalletData {
  const factory WalletData({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
  }) = _WalletData;

  factory WalletData.fromJson(Map<String, dynamic> json) => _$WalletDataFromJson(json);
}
```

### 6.2 Data mappers

- Extend `BaseDataMapper<Data, Entity>` (`lib/data/api/mappers/base/base_data_mapper.dart`).
- Đặt ở `lib/data/api/mappers/` (số nhiều).
- `@injectable`; map null-safe với default hợp lý.
- Cần map 2 chiều → `with DataMapperMixin` (`mapToData`).

```dart
@injectable
class WalletDataMapper extends BaseDataMapper<WalletData, Wallet> with DataMapperMixin {
  const WalletDataMapper();

  @override
  Wallet mapToEntity(WalletData? data) {
    return Wallet(
      id: data?.id ?? 0,
      name: data?.name ?? '',
    );
  }
}
```

Snippet VS Code: prefix `dm`.

### 6.3 Repository implementation

- `@LazySingleton(as: Repository)`.
- Inject `AppApiServices` + mappers + `AppPreferences`.
- **Không leak** `*Data` model ra ngoài data layer.

### 6.4 API services

- Khai báo endpoint trong `AppApiServices` (`lib/data/api/app_api_services.dart`).
- Clients: `_serverApiClientAuth` / `_serverApiClientRest` / `_serverApiFunctionsClient` / `_serverApiClientStorage`.
- Dùng response mapper có sẵn (`SuccessResponseMapperType.jsonObject` / `jsonArray`…).
- API base URL lấy từ flavor (`--dart-define-from-file=env/<flavor>.json`).

---

## 7. UI layer & BLoC

### 7.1 Page structure

> Màn mẫu: `lib/ui/views/create_wallet/` (1 màn + bloc inject use case). Home (`lib/ui/views/home/`) phức tạp hơn (chart, nhiều section).

```dart
@RoutePage()
class CreateWalletView extends StatefulWidget {
  const CreateWalletView({super.key, this.isFromSignUp = false});

  final bool isFromSignUp;

  @override
  State<CreateWalletView> createState() => _CreateWalletViewState();
}

class _CreateWalletViewState extends BasePageState<CreateWalletView, CreateWalletBloc> {
  @override
  void initState() {
    super.initState();
    bloc.add(const CreateWalletViewInitiated());
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.createWallet),
      body: NoirScaffoldBody(
        child: /* ... */,
      ),
    );
  }
}
```

Snippet VS Code: prefix `bps`.

### 7.2 BLoC structure

- Extend `BaseBloc<Event, State>` (`lib/ui/base/bloc/base_bloc.dart`).
- `@injectable`.
- Event handler: `on<Event>(_handler, transformer: log())`.
- **Mọi `emit` trong async handler phải nằm trong `runBlocCatching`.**

```dart
@injectable
class CreateWalletBloc extends BaseBloc<CreateWalletEvent, CreateWalletState> {
  CreateWalletBloc(this._createWalletUseCase) : super(const CreateWalletState()) {
    on<CreateWalletViewInitiated>(_onCreateWalletViewInitiated, transformer: log());
    on<CreateWalletConfirmButtonPressed>(
      _onCreateWalletConfirmButtonPressed,
      transformer: log(),
    );
  }

  final CreateWalletUseCase _createWalletUseCase;

  Future<void> _onCreateWalletConfirmButtonPressed(
    CreateWalletConfirmButtonPressed event,
    Emitter<CreateWalletState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        await _createWalletUseCase.execute(CreateWalletInput(wallet: wallet));
        emit(state.copyWith(isSuccess: true));
      },
    );
  }
}
```

### 7.3 Event & State (freezed)

- `event.dart` / `state.dart` là `part of '<bloc>.dart'`.
- Event: `sealed class XxxEvent extends BaseBlocEvent`.
- State: `@freezed sealed class XxxState extends BaseBlocState`.

```dart
part of 'create_wallet_bloc.dart';

sealed class CreateWalletEvent extends BaseBlocEvent {
  const CreateWalletEvent();
}

@freezed
sealed class CreateWalletConfirmButtonPressed extends CreateWalletEvent
    with _$CreateWalletConfirmButtonPressed {
  const CreateWalletConfirmButtonPressed._();
  const factory CreateWalletConfirmButtonPressed() = _CreateWalletConfirmButtonPressed;
}
```

### 7.4 BlocBuilder / BlocListener / BlocConsumer

**Bắt buộc** khai báo `buildWhen` / `listenWhen`:

```dart
BlocBuilder<CreateWalletBloc, CreateWalletState>(
  buildWhen: (previous, current) => previous.walletName != current.walletName,
  builder: (context, state) => /* ... */,
)
```

### 7.5 Tách widget — mỗi widget con 1 file trong `widgets/`

**Quy tắc cho code mới:** `*_view.dart` **chỉ giữ** `<Screen>View`, `_<Screen>ViewState`, và `buildPage` lắp ráp layout tổng. Khối UI con (header, card, section, field, empty/loading/error…) **tách ra file riêng** trong `widgets/`.

Màn hiện có (vd `home_view.dart`) vẫn còn widget `_private` cùng file — **đừng** refactor hàng loạt trừ khi task yêu cầu. Code mới không bắt chước anti-pattern đó.

| | Quy ước |
|---|---|
| File | `widgets/<screen>_<component>_widget.dart` |
| Class | **public** `<Screen><Component>Widget` |
| `State` con | Giữ `_private` **cùng file** với widget |
| Barrel | Export file mới vào `lib/ui/ui.dart` |
| Import | Widget ↔ view qua barrel `package:walleto/ui/ui.dart` |

- **Stateless** khi có thể; nhận data qua constructor.
- **Không** gọi use case / repository / load data trong widget — chỉ hiển thị + bắn event qua callback.
- `BlocBuilder`/`Listener` trong widget con vẫn **bắt buộc** `buildWhen`/`listenWhen`.
- **Không để widget dead-code** trong `widgets/`.

### 7.6 Sub-BLoC

- Dùng `initSubBloc()` + `subBlocProviders` từ `BasePageState` khi cần.

---

## 8. Design system & UI styling

Visual: **Noir Glass** — OLED dark (`scaffoldBackgroundColor` `#050506`) + teal accent (`primaryColor` `#2DD4BF`).

| Thành phần | Cách dùng | Tra danh sách thật |
|------------|-----------|--------------------|
| Màu | Constant từ `app_colors.dart` | `grep '^const' lib/resources/styles/app_colors.dart` |
| Typography | Method của `AppTextStyles` (`s{size}w{weight}{Color}`) | `grep 'static TextStyle' lib/resources/styles/app_text_styles.dart` |
| Decoration | `AppDecorations.glassPanel()` / `primaryCta()` | `lib/resources/styles/app_decorations.dart` |
| Spacing | `Dimens.d{number}.responsive()` | `lib/resources/dimens/` |
| Assets | `Assets.images.xxx` (flutter_gen) | `lib/resources/gen/` |
| Component | Widget trong `lib/ui/widgets/` | `ls lib/ui/widgets/` |
| Scaffold body | `NoirScaffoldBody` | `lib/ui/widgets/noir_backdrop.dart` |

> **Không chép danh sách màu / style vào file này.** Luôn `grep` file nguồn trước khi kết luận "chưa có".

```dart
// ✅ Đúng
padding: EdgeInsets.all(Dimens.d16.responsive()),
style: AppTextStyles.s18wBoldBlack(),
backgroundColor: scaffoldBackgroundColor,
decoration: AppDecorations.glassPanel(),

// ❌ Sai
padding: const EdgeInsets.all(16),
style: const TextStyle(fontSize: 18, color: Color(0xFFEDEDEF)),
backgroundColor: const Color(0xFF050506),
```

**Responsive:** mọi giá trị từ `Dimens` phải gọi `.responsive()` (tuỳ chọn `tablet:`, `ultraTablet:`). Layout co giãn ưu tiên `Expanded`/`Flexible`/`Wrap`.

---

## 9. Localization (i18n)

- ARB: `lib/resources/l10n/intl_en_US.arb` (main locale, hiện là locale duy nhất).
- Truy cập trong UI: `S.current.<key>` (generated). **Không** hard-code string end-user.
- Thêm key mới vào **mọi** file ARB hiện có rồi `make l10n`. Khi thêm locale mới sau này → đủ tất cả ARB, không locale nào trống.
- Metadata `@key` (description) đặt ở file main `intl_en_US.arb`.

```dart
Text(S.current.createWallet)
```

```jsonc
"createWallet": "Create wallet",
"@createWallet": { "description": "Create wallet screen title" }
```

---

## 10. Navigation

- `auto_route` với `@RoutePage()` trên View (`replaceInRouteName: 'View,Route'`).
- Đăng ký route trong `AppRouter` (`lib/ui/navigation/routes/app_router.dart`).
- Navigate qua `AppNavigator` / `AppRouteInfo` — **không** `Navigator.push` thô trừ case đặc biệt.
- Protected route: `AuthRouteGuard`. Nested tab: `meta: {'hideBottomNav': true}` khi cần ẩn bottom nav.

```dart
AutoRoute(
  page: CreateWalletRoute.page,
  path: 'create-wallet-from-account',
  meta: const {'hideBottomNav': true},
),
```

> Sau khi thêm route: `make force_build` để generate `*.gr.dart`.

---

## 11. Dependency injection

- `get_it` + `injectable`.
- Annotate: `@injectable`, `@LazySingleton`, `@LazySingleton(as: Repository)`.
- Cần module: `@module` trong `lib/di/`.
- Sau khi thêm/sửa DI: `make force_build`.
- Resolve trong UI qua `GetIt` sẵn trong `BasePageState` — **không** tự `GetIt.instance.register` runtime.

---

## 12. Error handling

| Context | Cơ chế |
|---------|--------|
| BLoC async | `runBlocCatching` → `ExceptionHandler` → popup |
| Use case | `BaseFutureUseCase.execute` wrap `AppException` |
| `main()` bootstrap | `runCatching` + `Result<T>` |
| Uncaught | `runZonedGuarded` log trong `main.dart` |

```dart
await runBlocCatching(
  action: () async { /* ... */ },
  overrideErrorMessage: S.current.somethingWentWrong,
  handleLoading: true,
  handleError: true,
  doOnError: (e) async { /* optional */ },
);
```

Map server error: `ErrorCodeConstants` + `ExceptionMessageMapper`.

---

## 13. Codegen

| Tool | Output | Lệnh |
|------|--------|------|
| `build_runner` | `*.freezed.dart`, `*.g.dart`, `di.config.dart` | `make force_build` |
| `auto_route_generator` | `*.gr.dart` | (cùng build_runner) |
| `flutter_gen` | `lib/resources/gen/` | `make gen_assets` |
| `intl_utils` | `lib/resources/l10n/generated/` | `make l10n` |

> **Không sửa tay file generated.** Conflict → `make force_build` (`--delete-conflicting-outputs`).
> Dev liên tục: `make force_watch`.
> VS Code snippets: `.vscode/dart.code-snippets`.

Generated files đã gitignore — không `git add` chúng.

---

## 14. Lint & formatting

- Config: `analysis_options.yaml` (`package:flutter_lints/flutter.yaml` + rules team).
- Page width: **100** ký tự · trailing commas · `prefer_const_*`.
- Repo **không** có custom lint plugin. Convention hard-code / `runBlocCatching` / `buildWhen` vẫn **bắt buộc** — review + agent enforce, không dựa vào analyzer plugin.

```bash
make analyze                 # flutter analyze — phải pass
fvm dart format <file.dart>  # format đúng file đã đụng
make format_check            # CI / pre-PR
```

---

## 15. Testing

- Framework: `flutter_test`. Khi viết test đầu tiên: thêm `bloc_test` + `mocktail` vào `dev_dependencies` nếu chưa có.
- Chạy: `make testing`.
- **Bắt buộc** (xem [CLAUDE.md §0 mục 10](CLAUDE.md)): mọi feature mới / bug fix phải kèm test tương ứng.
- Hiện repo **chưa có `test/`** — test đầu tiên **thiết lập convention**, đừng bịa helper dùng chung.
- Test mirror structure: `test/domain/...`, `test/data/...`, `test/ui/...` — path giống `lib/`.

### Convention

- **Mock local theo file:** `class _MockX extends Mock implements X {}` ở đầu mỗi file test — không tạo `test/helpers/mocks.dart` dùng chung.
- **BLoC harness:** dựng bloc qua constructor thật (deps mock), cascade-assign field `BaseBlocDelegate` giống `BasePageStateDelegate` lúc runtime:

```dart
bloc = CreateWalletBloc(mockCreateWalletUseCase)
  ..navigator = navigator
  ..disposeBag = DisposeBag()
  ..appBloc = appBloc
  ..commonBloc = commonBloc
  ..exceptionHandler = exceptionHandler
  ..exceptionMessageMapper = const ExceptionMessageMapper();
```

- **Use case error contract:** domain `AppException` propagate nguyên vẹn; lỗi lạ bọc `AppUncaughtException`.
- **`registerFallbackValue`** trong `setUpAll` cho type tuỳ biến dùng với `any()`.
- Widget test cho `BasePageState`: đăng ký mock vào `getIt` (unregister trước, register trong `setUp`, unregister trong `tearDown`).

### Gotcha

- Codegen cũ: `fvm flutter test` fail nếu freezed stale → `make force_build` trước.
- `Platform.isIOS`/`isAndroid` không test được dưới `flutter test` trên host.
- `DateTime.now()` không có seam trừ khi dùng `package:clock`.
- Logic `_private` không gọi được từ `test/` — `@visibleForTesting` nếu thật sự cần.

---

## 16. Git, commit & PR

### Branch flow

```
main ← develop ← feature/<description>
```

Repo: **GitHub** `hungbui1204/walleto`. Dùng `gh`. Không GitLab.

### Commit message (Conventional Commits, tiếng Anh)

```
feat: add create wallet confirmation flow
fix: handle empty wallet list on home
refactor(ui): extract home recent transactions widget
chore: bump dio to 5.8.0
docs: add AI agent coding rules
```

- **AI agent không tự commit/push/PR** trừ khi user yêu cầu rõ ràng.
- Skill `commit-mr` khi user bảo commit / tạo PR.

### PR checklist

- [ ] Export file mới vào barrel
- [ ] Import chỉ qua barrel
- [ ] `.responsive()` trên mọi `Dimens`
- [ ] Không comment code thừa
- [ ] Test cases (khi applicable)
- [ ] Xoá code / dependency không dùng
- [ ] Screenshot cho thay đổi UI

Chạy local trước PR: `make verify`.

---

## Phụ lục — checklist feature mới

```
[ ] Requirement từ docs/requirements/ hoặc user confirm
[ ] Domain: entity (nếu cần), method Repository, use case(s) → export domain.dart
[ ] Data: model *Data, mapper, API method, RepositoryImpl → export data.dart
[ ] UI: bloc (event/state freezed), view, widgets → export ui.dart
[ ] Route: @RoutePage + AutoRoute trong AppRouter
[ ] DI: @injectable / @LazySingleton
[ ] Test: use case + bloc (+ mapper/service nếu có logic) trong test/, mirror path lib/
[ ] i18n: ARB hiện có + make l10n
[ ] make force_build
[ ] make verify   (analyze + format_check + testing — đều pass)
```
