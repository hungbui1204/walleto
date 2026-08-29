---
name: scaffold-feature
description: Sinh khung một feature full-stack mới trong STG-VT theo đúng thứ tự Clean Architecture (domain → data → ui) + codegen + i18n + analyze. Dùng khi user muốn "thêm feature mới", "tạo màn hình kèm API/use case", hoặc scaffold end-to-end một chức năng.
---

# Scaffold feature full-stack (STG-VT)

Tạo khung một feature mới theo Clean Architecture của STG-VT. Bám sát `AGENTS.md §4.2` và `CODING_RULES.md`. **Bắt chước file mẫu**, không bịa pattern.

## 0. Trước khi bắt đầu
- Hỏi/nhận rõ: tên feature, danh sách use case (API nào), các field entity, màn hình đi kèm (nếu có).
- Nếu có `docs/requirements/<feature>.md` → đọc trước.
- Mở file mẫu để copy pattern: `lib/domain/usecases/subscription/`, `lib/data/api/mapper/plan_data_mapper.dart`, `lib/ui/views/change_password/` (feature 1 màn — file thẳng trong `<feature>/`, không lồng `<feature>/<feature>/`).
- **Tra xem đã có sẵn chưa** trước khi tạo mới: `ls lib/domain/usecases/*/ lib/domain/entities/ lib/ui/views/`.

## 1. Domain (làm trước)
1. Entity: `lib/domain/entities/<name>.dart` — pure Dart, không import `flutter/`/`dio`/`data/`.
2. Repository interface: `lib/domain/repositories/<name>_repository.dart` — return type là entity.
3. Use case(s): `lib/domain/usecases/<feature>/<verb>_<noun>_use_case.dart` — extend `BaseFutureUseCase<Input, Output>`, `@injectable`, logic trong `buildUseCase`. Input/Output là `@freezed sealed class` extends `BaseInput`/`BaseOutput`.
4. Export tất cả vào `lib/domain/domain.dart`.

## 2. Data
1. Model API: `lib/data/api/models/<name>_data.dart` — suffix `Data`, `@freezed` + `json_serializable`, `@JsonKey`.
2. Mapper: `lib/data/api/mapper/<name>_data_mapper.dart` — extend `BaseDataMapper<Data, Entity>`, `@injectable`, null-safe default.
3. API method trong `lib/data/api/app_api_services.dart`.
4. Repository impl: `lib/data/repositories/<name>_repository_impl.dart` — `@LazySingleton(as: <Name>Repository)`, inject `AppApiService` + mapper, không leak `*Data`.
5. Export vào `lib/data/data.dart`.

## 3. UI (nếu feature có màn hình)
**Dùng skill `add-screen`** cho toàn bộ phần UI — nó lo trọn: bloc (event/state) + view + code UI theo design system + route + i18n + barrel. Tóm tắt ràng buộc: BLoC extend `BaseBloc` `@injectable`, mọi `emit` async bọc `runBlocCatching`; View extend `BasePageState`, `@RoutePage()`, `BlocBuilder` có `buildWhen`; không hard-code, dùng lại component `design_system`.

## 4. Codegen
```bash
make force_build_all
```
Sinh `*.freezed.dart`, `*.g.dart`, `di.config.dart`, `*.gr.dart`. **Không sửa tay** file generated.

## 5. i18n (nếu có string user-facing)
Thêm key vào cả 3 file ARB (ja/en/ko) rồi `make l10n`. (Có thể dùng skill `add-i18n`.)

## 6. Test (bắt buộc — `AGENTS.md §0 mục 10`)
- Use case: `test/domain/usecases/<feature>/<verb>_<noun>_use_case_test.dart` — mock repository, cover happy path + lỗi (`AppException` propagate nguyên vẹn, lỗi lạ bọc `AppUncaughtException`). Bám file mẫu `test/domain/usecases/subscription/verify_iap_purchase_use_case_test.dart`.
- Mapper (nếu có mapping logic thật, không phải copy field thẳng): `test/data/api/mapper/<name>_data_mapper_test.dart`.
- Bloc/view của phần UI → làm cùng lúc với skill `add-screen` (skill đó tự lo test cho bloc/view).
- Mock local theo file (`class _MockX extends Mock implements X {}`), không dùng helper chung. Chi tiết convention + gotcha: `CODING_RULES.md §15`.

## 7. Verify
```bash
make verify
```
Gồm analyze + **lint** + format_check + testing — tất cả phải pass. Kiểm checklist `AGENTS.md §8`.

> ⚠️ `make analyze` một mình **KHÔNG** bắt custom lint `stg_vt_lints` (plugin chỉ chạy khi `dart analyze` nhận path file cụ thể) — đừng dừng ở `make analyze`.

## Ràng buộc (không vi phạm)
- Layer một chiều `ui → domain ← data`; UI không gọi repository/API trực tiếp.
- Import qua barrel; export file public mới.
- Không hard-code color/style/string/magic number.
- Minimize scope; không commit trừ khi user yêu cầu.
- Không bỏ qua bước Test — feature mới bắt buộc kèm unit test tương ứng.
