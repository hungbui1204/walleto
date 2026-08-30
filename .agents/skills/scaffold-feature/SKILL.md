---
name: scaffold-feature
description: Sinh khung một feature full-stack mới trong Walleto theo đúng thứ tự Clean Architecture (domain → data → ui) + codegen + i18n + analyze. Dùng khi user muốn "thêm feature mới", "tạo màn hình kèm API/use case", hoặc scaffold end-to-end một chức năng.
---

# Scaffold feature full-stack (Walleto)

Tạo khung một feature mới theo Clean Architecture của Walleto. Bám sát `CLAUDE.md §4.2` và `CODING_RULES.md`. **Bắt chước file mẫu**, không bịa pattern.

## 0. Trước khi bắt đầu
- Hỏi/nhận rõ: tên feature, danh sách use case (API nào), các field entity, màn hình đi kèm (nếu có).
- Nếu có `docs/requirements/<feature>.md` → đọc trước.
- Mở file mẫu: `lib/domain/usecases/get_wallets_use_case.dart`, `lib/data/api/mappers/wallet_data_mapper.dart`, `lib/ui/views/create_wallet/`.
- **Tra xem đã có sẵn chưa:** `ls lib/domain/usecases/ lib/domain/entities/ lib/ui/views/`.

## 1. Domain (làm trước)
1. Entity (nếu chưa có): `lib/domain/entities/<name>.dart` — pure Dart, không import `flutter/`/`dio`/`data/`.
2. **Thêm method vào `Repository`** (`lib/domain/repositories/repository.dart`) — return type là entity. **Không** tạo repo mới theo feature trừ khi user yêu cầu tách.
3. Use case(s): `lib/domain/usecases/<verb>_<noun>_use_case.dart` — extend `BaseFutureUseCase<Input, Output>`, `@injectable`, inject `Repository`, logic trong `buildUseCase`. Input/Output `@freezed sealed class` extends `BaseInput`/`BaseOutput`.
4. Export tất cả vào `lib/domain/domain.dart`.

## 2. Data
1. Model API: `lib/data/api/models/<name>_data.dart` — suffix `Data`, `@freezed` + `json_serializable`, `@JsonKey`.
2. Mapper: `lib/data/api/mappers/<name>_data_mapper.dart` — extend `BaseDataMapper<Data, Entity>`, `@injectable`, null-safe default. Cần 2 chiều → `with DataMapperMixin`.
3. API method trong `lib/data/api/app_api_services.dart` (đúng client: Auth / Rest / Functions / Storage).
4. Implement method trên `RepositoryImpl` — `@LazySingleton(as: Repository)`, không leak `*Data`.
5. Export vào `lib/data/data.dart`.

## 3. UI (nếu feature có màn hình)
**Dùng skill `add-screen`** cho toàn bộ phần UI. Tóm tắt: BLoC extend `BaseBloc` `@injectable`, mọi `emit` async bọc `runBlocCatching`, `transformer: log()`; View extend `BasePageState`, `@RoutePage()`, `BlocBuilder` có `buildWhen`; không hard-code; tái sử dụng `lib/ui/widgets/`.

## 4. Codegen
```bash
make force_build
```
Sinh `*.freezed.dart`, `*.g.dart`, `di.config.dart`, `*.gr.dart`. **Không sửa tay** file generated.

## 5. i18n (nếu có string user-facing)
Thêm key vào mọi ARB hiện có rồi `make l10n`. (Skill `add-i18n`.)

## 6. Test (bắt buộc — `CLAUDE.md §0 mục 10`)
- Use case: `test/domain/usecases/<verb>_<noun>_use_case_test.dart` — mock `Repository`, cover happy path + lỗi (`AppException` propagate, lỗi lạ bọc `AppUncaughtException`).
- Mapper (nếu mapping logic thật): `test/data/api/mappers/<name>_data_mapper_test.dart`.
- Bloc/view → skill `add-screen`.
- Mock local theo file. Chi tiết: `CODING_RULES.md §15`.
- Nếu chưa có `bloc_test`/`mocktail` → thêm `dev_dependencies` khi viết test đầu tiên.

## 7. Verify
```bash
make verify
```
Gồm analyze + format_check + testing. Checklist `CLAUDE.md §8`.

## Ràng buộc
- Layer một chiều `ui → domain ← data`; UI không gọi `Repository`/API trực tiếp.
- Import qua barrel; export file public mới.
- Không hard-code color/style/string/magic number.
- Minimize scope; không commit trừ khi user yêu cầu.
- Không bỏ qua Test — feature mới bắt buộc kèm unit test tương ứng.
