---
name: commit-mr
description: Commit thay đổi hiện tại và tạo Merge Request vào nhánh develop cho STG-VT (GitLab gitlab.dc.local). Tự tạo branch feature/* nếu đang ở develop/main, commit theo conventional style, push kèm GitLab push-options để mở MR. Dùng khi user muốn "commit", "tạo MR/merge request", "push tạo MR vào develop", "mở merge request".
---

# Commit + tạo MR vào develop (STG-VT)

Repo dùng **GitLab** (`git@gitlab.dc.local:skg.stg-vt/stg-vt.git`), flow `feature/* → develop → main`.
**Không có `gh`; `glab` KHÔNG cài** → tạo MR bằng **git push-options**, không dùng CLI khác.

> Chỉ chạy skill này khi user yêu cầu rõ ràng commit/tạo MR (đây chính là sự cho phép). Push là hành động ra ngoài — không tự ý làm nếu user chưa yêu cầu.

## 0. Nắm scope
```bash
git branch --show-current
git status --short
git diff --stat
```
- Đọc kỹ diff các file sẽ commit. **Chỉ** `git add` đúng file thuộc scope task — không add đại `git add -A`.
- **Tuyệt đối không commit:** `env/*.json`, keystore/secrets/token, provisioning, file generated không liên quan (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `di.config.dart`) trừ khi codegen tạo ra đúng cho thay đổi này.
- Nếu diff lẫn code ngoài scope → hỏi user trước, đừng gộp bừa.

## 1. Pre-flight (bắt buộc pass trước khi commit)
Nếu vừa sửa Dart mà chưa kiểm tra:
```bash
make analyze                       # phải "No issues found"
fvm dart format <các-file-đã-sửa>  # format đúng file, không format cả thư mục
```
- Custom lint `stg_vt_lints` **không** hiện qua `make analyze` → chạy thêm `fvm dart analyze <file đã sửa>` cho file Dart quan trọng.
- Đụng freezed/injectable/auto_route/json_serializable → `make force_build_all`. Thêm string → 3 ARB + `make l10n`.
- Analyze fail → **dừng, sửa xong mới commit.**

## 2. Tạo branch (nếu cần)
- Đang ở `develop` / `main` → **bắt buộc** tạo nhánh mới `feature/<mô-tả-kebab>`:
```bash
git checkout -b feature/<mo-ta-ngan-gon>
```
- Đang ở sẵn một `feature/*` phù hợp → commit thẳng, bỏ qua bước tạo branch.
- Tên branch ngắn, mô tả đúng thay đổi (vd `feature/device-binding-headers`). Nếu không chắc tên → đề xuất 1 tên rồi tiếp tục.

## 3. Commit
Message theo **conventional commits** (`feat:` / `fix:` / `refactor:` / `build:` / `chore:` …), tiếng Anh, tiêu đề ≤ ~72 ký tự, thân giải thích *tại sao*. Kết thúc bằng trailer Co-Authored-By của Codex:
```bash
git add <đúng-các-file>
git commit -F - <<'EOF'
<type>: <tóm tắt thay đổi>

<thân: bối cảnh + lý do, không chỉ liệt kê file>

Co-Authored-By: Codex Opus 4.8 <noreply@anthropic.com>
EOF
```
> Dùng đúng model trailer của phiên hiện tại (mặc định `Codex Opus 4.8 <noreply@anthropic.com>`).

## 4. Push + tạo MR (dùng template MR của repo)
MR description **bắt buộc** theo template repo: `.gitlab/merge_request_templates/Default.md`.

> Khi tạo MR bằng push-option, GitLab **KHÔNG** tự áp template và **KHÔNG** expand `%{first_multiline_commit}`. Phải tự dựng description từ file template rồi truyền vào. Push-option **hỗ trợ nhiều dòng** (giữ trong biến shell là được).

```bash
# Dựng description từ template repo, thay %{first_multiline_commit} bằng commit message.
MR_DESC="$(python3 - <<'PY'
import subprocess
tpl = open('.gitlab/merge_request_templates/Default.md').read()
msg = subprocess.run(['git', 'log', '-1', '--pretty=%B'], capture_output=True, text=True).stdout.strip()
print(tpl.replace('%{first_multiline_commit}', msg), end='')
PY
)"

git push -u origin <branch> \
  -o merge_request.create \
  -o merge_request.target=develop \
  -o merge_request.remove_source_branch \
  -o merge_request.title="<type>: <tóm tắt>" \
  -o merge_request.description="$MR_DESC"
```
- **Chỉ điền phần chắc chắn:** `%{first_multiline_commit}` → commit message. Có link Redmine/Backlog/ticket do user đưa → thay vào chỗ `xxxxxx`; **không có thì giữ nguyên placeholder** của template (đừng bịa link).
- Tick mục checklist **đã thật sự làm** (vd `[x] Import only barrel file`); mục chưa làm để `[ ]`.
- `/assign me` cuối template là quick-action GitLab → giữ nguyên, đừng xoá.
- MR đã tồn tại cho branch này (push lần 2+) → **bỏ** mọi `-o merge_request.*`, chỉ `git push` (options tạo MR sẽ báo lỗi "MR already exists").
- **Không** `--force`. Không đổi target sang `main`.

## 5. Báo cáo
GitLab in URL MR trong output remote (`View merge request ...`). Trả lại cho user:
- Tên branch, hash commit, và **link MR** (dạng `http://gitlab.dc.local/skg.stg-vt/stg-vt/-/merge_requests/<id>`).
- Nhắc user vào MR review + assign reviewer.

## Xử lý sự cố
- **Push-option MR không tạo** (GitLab cũ / bị tắt): branch vẫn push lên. Lấy URL "create merge request" mà remote in ra, hoặc mở thủ công: `http://gitlab.dc.local/skg.stg-vt/stg-vt/-/merge_requests/new?merge_request%5Bsource_branch%5D=<branch>&merge_request%5Btarget_branch%5D=develop`.
- **Push bị từ chối / mất mạng nội bộ:** báo user (cần VPN/quyền tới `gitlab.dc.local`), đã commit local xong — không mất gì.
