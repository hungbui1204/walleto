---
name: commit-mr
description: Commit thay đổi hiện tại và tạo Pull Request vào nhánh develop cho Walleto (GitHub hungbui1204/walleto). Tự tạo branch feature/* nếu đang ở develop/main, commit theo conventional style, push rồi gh pr create. Dùng khi user muốn "commit", "tạo PR/pull request", "push tạo PR vào develop", "mở pull request".
---

# Commit + tạo PR vào develop (Walleto)

Repo dùng **GitHub** (`https://github.com/hungbui1204/walleto.git`), flow `feature/* → develop → main`.
Dùng **`gh`**. Không dùng GitLab / `glab` / git push-options `merge_request.*`.

> Chỉ chạy skill này khi user yêu cầu rõ ràng commit/tạo PR (đây chính là sự cho phép). Push là hành động ra ngoài — không tự ý làm nếu user chưa yêu cầu.

## 0. Nắm scope
```bash
git branch --show-current
git status --short
git diff --stat
```
- Đọc kỹ diff các file sẽ commit. **Chỉ** `git add` đúng file thuộc scope task — không add đại `git add -A`.
- **Tuyệt đối không commit:** `env/*.json`, keystore/secrets/token, `key.properties`, provisioning, file generated (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `di.config.dart` — đã gitignore).
- Nếu diff lẫn code ngoài scope → hỏi user trước, đừng gộp bừa.

## 1. Pre-flight (bắt buộc pass trước khi commit)
Nếu vừa sửa Dart mà chưa kiểm tra:
```bash
make analyze                       # phải "No issues found" (hoặc giải thích lỗi còn lại)
fvm dart format <các-file-đã-sửa>  # format đúng file, không format cả thư mục
```
- Đụng freezed/injectable/auto_route/json_serializable → `make force_build`. Thêm string → ARB + `make l10n`.
- Analyze fail → **dừng, sửa xong mới commit.**

## 2. Tạo branch (nếu cần)
- Đang ở `develop` / `main` → **bắt buộc** tạo nhánh mới `feature/<mô-tả-kebab>`:
```bash
git checkout -b feature/<mo-ta-ngan-gon>
```
- Đang ở sẵn một `feature/*` phù hợp → commit thẳng.
- Tên branch ngắn, mô tả đúng thay đổi. Nếu không chắc → đề xuất 1 tên rồi tiếp tục.

## 3. Commit
Message theo **conventional commits** (`feat:` / `fix:` / `refactor:` / `build:` / `chore:` …), tiếng Anh, tiêu đề ≤ ~72 ký tự, thân giải thích *tại sao*:

```bash
git add <đúng-các-file>
git commit -m "$(cat <<'EOF'
<type>: <tóm tắt thay đổi>

<thân: bối cảnh + lý do, không chỉ liệt kê file>

EOF
)"
```

Không `--no-verify`. Không amend commit đã push.

## 4. Push + tạo PR
PR description **bám** `.github/pull_request_template.md` nếu file tồn tại.

```bash
git push -u origin HEAD

gh pr create --base develop --title "<type>: <tóm tắt>" --body "$(cat <<'EOF'
## Summary
<1-3 bullet points: what and why>

## Test plan
- [ ] make analyze
- [ ] make testing (nếu có test mới/sửa)
- [ ] Manual: <bước kiểm tra UI/flow nếu có>

EOF
)"
```

- **Không** `--force`. Không đổi base sang `main` trừ khi user yêu cầu.
- PR đã tồn tại cho branch này → chỉ `git push` (không `gh pr create` lần nữa). Trả URL PR hiện có: `gh pr view --web` / `gh pr view --json url`.
- Tick checklist **đã thật sự làm**. Không bịa ticket/link.

## 5. Báo cáo
Trả lại cho user:
- Tên branch, hash commit, và **link PR**.
- Nhắc review + merge vào `develop`.

## Xử lý sự cố
- **`gh` chưa login / thiếu quyền:** báo user; commit local vẫn giữ.
- **Push bị từ chối:** báo user, không `--force` trừ khi user yêu cầu rõ.
