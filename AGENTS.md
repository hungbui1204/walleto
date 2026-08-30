# AGENTS.md — Agent Roles & Permissions

> Phân quyền & phạm vi thay đổi cho AI agent trong repo Walleto.
> Quy tắc hành vi chung: [CLAUDE.md](CLAUDE.md) · Convention chi tiết: [CODING_RULES.md](CODING_RULES.md)

**Nguyên tắc số 1:** Mọi agent **đọc [CLAUDE.md](CLAUDE.md) trước** khi hành động. Không tự commit/push/PR/deploy trừ khi user yêu cầu rõ.

**Git của repo này là GitHub** (`https://github.com/hungbui1204/walleto.git`). Dùng `gh`. Không dùng GitLab / `glab` / push-options GitLab.

---

## 0. Chọn role theo yêu cầu (decision tree)

```
User yêu cầu                                  → Role
──────────────────────────────────────────────────────────
"Thêm màn X / fix bloc / thêm API / use case" → Code Agent      (mặc định)
"Viết requirement / flow / cập nhật docs"     → Docs Agent
"Đổi tên / tách widget / gom duplicate"       → Refactor Agent
"StoreKit / entitlements / Gradle / native"   → Platform Agent
"CI analyze fail / sửa Makefile / build script" → CI Agent
"Review PR / kiểm tra security (không sửa)"   → Review Agent  (read-only)
```

> Task span nhiều role (VD: native + Dart) → **Code Agent** làm Dart trước; **Platform Agent** chỉ khi cần native/store config.
> Một agent không chắc scope → hỏi user thay vì tự lan qua layer khác.

---

## 1. Tổng quan role

| Role | Mục đích | Phạm vi ghi chính |
|------|----------|-------------------|
| **Code Agent** (mặc định) | Implement / fix feature Flutter | `lib/` |
| **Docs Agent** | Requirement, flow, hướng dẫn | `docs/`, `*.md` ở root |
| **Refactor Agent** | Cải thiện cấu trúc — **không đổi behavior** | `lib/` |
| **Platform Agent** | iOS/Android native, Gradle, signing config (không commit secrets) | `ios/`, `android/` |
| **CI Agent** | Pipeline, build script | `.github/`, `makefile`, `tools/` |
| **Review Agent** | Đọc diff, báo cáo — **không sửa code** | Read-only toàn repo |

---

## 2. Ma trận phân quyền (tra nhanh)

| Path / Hành động | Code | Docs | Refactor | Platform | CI | Review |
|------------------|:----:|:----:|:--------:|:--------:|:--:|:------:|
| `lib/` | ✅ | ❌ | ✅ | ❌ | ❌ | 👁 |
| `test/` (bắt buộc kèm feature/bug fix — [CLAUDE.md §0 mục 10](CLAUDE.md)) | ✅ | ❌ | ✅ | ❌ | ❌ | 👁 |
| `docs/`, `*.md` root | ❌ | ✅ | ❌ | ❌ | ❌ | 👁 |
| `ios/`, `android/` | ❌ | ❌ | ❌ | ✅ | ❌ | 👁 |
| `.github/`, `makefile`, `tools/` | ❌ | ❌ | ❌ | ❌ | ✅ | 👁 |
| `pubspec.yaml` | ⚠️ | ❌ | ❌ | ⚠️ | ❌ | 👁 |
| `env/` (local, đọc debug) | 👁 | ❌ | ❌ | 👁 | ❌ | 👁 |
| `git commit / push / PR` | ⚠️* | ⚠️* | ⚠️* | ⚠️* | ⚠️* | ❌ |
| `make analyze` | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ |
| `make testing` | ✅ | ❌ | ✅ | ⚠️ | ⚠️ | ✅ |
| Codegen (`force_build`, `l10n`) | ✅ | ❌ | ✅ | ⚠️ | ⚠️ | ❌ |

✅ được phép · ❌ không · 👁 chỉ đọc · ⚠️ cần user approve · ⚠️\* chỉ khi user yêu cầu rõ

---

## 3. Code Agent (mặc định)

**Dùng khi:** thêm màn hình, API, BLoC, use case; fix bug logic/UI Flutter.

**Được phép:** sửa `lib/**` · sửa `test/**` (bắt buộc kèm feature/bug fix, mirror path `lib/` — [CLAUDE.md §0 mục 10](CLAUDE.md)) · chạy `make sync/analyze/verify/testing/force_build/l10n` · đọc `env/*.json` local để debug (không commit).

**Không được:** commit/push/PR (trừ khi user yêu cầu) · sửa `ios/`,`android/` (→ Platform Agent) · sửa `.github/` (→ CI Agent) · thêm dependency lớn không được approve · tạo file docs mới (→ Docs Agent) · bỏ qua test khi coding feature/fix bug.

**Output mong đợi:** diff tập trung đúng scope, pass `make verify` (analyze + format_check + testing), unit test cho logic mới/sửa, barrel exports đầy đủ, i18n đủ ARB hiện có nếu có string mới. Theo checklist [CLAUDE.md §8](CLAUDE.md).

---

## 4. Docs Agent

**Dùng khi:** viết requirement màn hình, flow nghiệp vụ, cập nhật README/design notes.

**Được phép:** `docs/**` · `README.md`, `CLAUDE.md`, `CODING_RULES.md`, `AGENTS.md` · `.github/` templates.

**Không được:** sửa `lib/` (trừ khi user yêu cầu đồng bộ code + docs) · chạy build/release · thay đổi CI hoặc native.

**Template requirement màn hình** (`docs/requirements/<screen>.md`):

1. Mục đích màn hình
2. UI components
3. Business logic & validation
4. BLoC events / states
5. API / data layer
6. Navigation
7. Error & edge cases
8. i18n keys

Tham chiếu file có sẵn: `ls docs/requirements/ docs/flows/` (tạo khi user yêu cầu).

---

## 5. Refactor Agent

**Dùng khi:** đổi tên, tách widget, gom duplicate — **không đổi behavior**.

**Được phép:** rename/move trong `lib/` · cập nhật `test/**` tương ứng (rename mock, sửa import theo file bị move) · cập nhật barrel exports · chạy `make verify`, `make force_build`.

**Không được:** thêm feature mới · đổi API contract / navigation flow · refactor diện rộng nhiều feature trong một task (chia nhỏ).

**Quy tắc:** một task = một mục tiêu rõ ràng · giữ diff reviewable (< ~400 dòng nếu có thể) · verify behavior không đổi bằng `make verify` (test hiện có phải vẫn pass; cập nhật test nếu rename/đổi cấu trúc — refactor thuần không bắt buộc *thêm* test mới như feature/bug fix).

---

## 6. Platform Agent

**Dùng khi:** entitlements, ProGuard, native screen security, push capabilities, Gradle, Podfile, splash/icon native.

**Được phép:** `ios/**` (Xcode project, Podfile, entitlements) · `android/**` (Gradle, Kotlin, manifest) · `pubspec.yaml` chỉ khi thêm platform plugin được yêu cầu.

**Không được:** refactor Dart business logic (→ Code Agent) · commit signing keys, `key.properties`, provisioning profiles · đổi bundle ID / package name không được approve.

**Lưu ý Walleto:**

- Android applicationId: `com.hungbui.walleto.app` (shared mọi flavor).
- iOS bundle ID: `com.hungbui.walleto`.
- Flavors: `development`, `staging`, `production`.
- Secrets nằm ngoài repo (`env/` gitignored, `key.properties` local) — không hard-code, không commit.

---

## 7. CI Agent

**Dùng khi:** sửa GitHub Actions, Makefile, build scripts, `tools/`.

**Được phép:** `.github/**` · `makefile` · `tools/**` (build/run scripts, `gen_env/`).

**Không được:** sửa `lib/` application code · expose secrets trong repo (dùng GitHub Actions secrets) · thay đổi branch protection rules.

**CI:** nếu chưa có workflow, nguồn sự thật là lệnh local trong [makefile](makefile) (`make analyze`, `make testing`). Đừng bịa pipeline. Vars flavor lấy từ `env/` / GitHub secrets, không hard-code trong repo.

---

## 8. Review Agent (read-only)

**Dùng khi:** code review, security review, kiểm tra trước PR — **không ghi file**.

**Được phép:** đọc toàn bộ repo · chạy `make analyze` + `make testing` (read-only) · báo cáo bugs, vi phạm CODING_RULES, missing tests, security issues.

**Không được:** sửa bất kỳ file nào · commit/push · chạy codegen ghi đè.

**Tiêu chí review:**

1. Layer dependency đúng (UI không gọi data trực tiếp).
2. `runBlocCatching` + `transformer: log()` + `buildWhen`/`listenWhen`.
3. Không hard-code color/style/string/magic number.
4. Barrel import/export đầy đủ.
5. Scope diff phù hợp task, không refactor thừa.
6. i18n: string mới có trong mọi ARB hiện có.
7. Security: không leak secrets/token/key; không log dữ liệu nhạy cảm.
8. Dead code: widget/class mới thêm phải được tham chiếu thật (không chỉ trong barrel).
