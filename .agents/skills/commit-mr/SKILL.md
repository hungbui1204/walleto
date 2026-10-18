---
name: commit-mr
description: Commit, push hoặc tạo GitHub Pull Request cho Walleto theo đúng hành động user đã yêu cầu. Dùng khi user nói rõ commit, push hay mở PR; mỗi hành động chỉ được thực hiện trong phạm vi đã được cho phép.
---

# Git delivery — Walleto

Repo dùng GitHub `hungbui1204/walleto`, `gh` và flow `feature/* → develop → main`. Đọc `CLAUDE.md`, `AGENTS.md` và phần Git trong `CODING_RULES.md`. **"Commit" chỉ cho phép commit; "push" và "tạo PR" là hành động riêng.** Không suy rộng một yêu cầu thành tất cả bước.

## Xác định diff

1. Xem branch, `git status --short`, `git diff` và `git diff --cached`. Đọc từng file dự định đưa vào commit; working tree có thể chứa thay đổi của user hoặc task khác. Stage đúng path thuộc yêu cầu, không dùng `git add -A` theo thói quen.
2. Không stage secrets, `env/*.json`, keystore, `key.properties`, provisioning profile hay file generated đã ignore. Nếu thay đổi ngoài scope lẫn trong cùng file, tách hunk an toàn hoặc hỏi user trước khi commit phần chưa được yêu cầu.
3. Nếu thay đổi Dart, xác nhận codegen/l10n cần thiết đã chạy, format đúng file đã sửa, và `make verify` đã pass. Với docs/skill-only, kiểm tra format/link/validation phù hợp thay vì chạy Flutter test vô ích. Báo rõ gate chưa chạy hoặc lỗi do trạng thái workspace; không ghi "pass" khi chưa thấy kết quả.

## Commit theo yêu cầu

- Nếu đang ở `develop`/`main` và cần commit feature, tạo branch `feature/<mô-tả>` theo quy ước repo; nếu đã ở branch phù hợp thì dùng branch đó. Không đổi branch khi có thay đổi chưa phân định được chủ sở hữu hoặc khi thao tác có thể mang theo diff ngoài scope.
- Commit message tiếng Anh theo Conventional Commits, mô tả lý do khi cần. Không `--no-verify`, không amend commit đã push nếu user chưa yêu cầu. Dùng cách ghi message phù hợp shell hiện tại; không sao chép heredoc Bash vào PowerShell.
- Sau commit, dừng nếu user chỉ yêu cầu commit. Trả branch và hash cùng kết quả kiểm chứng.

## Push/PR khi được yêu cầu

- Push branch hiện tại bằng `git push -u origin HEAD` nếu user đã yêu cầu push hoặc PR. Không force push nếu chưa được yêu cầu rõ. Khi bị từ chối, giữ local commit và báo nguyên nhân.
- Trước khi tạo PR, kiểm tra PR hiện có cho branch. Nếu đã có, cập nhật branch và trả URL; không tạo bản trùng. PR mới dùng `gh pr create --base develop` trừ khi user chỉ định base khác. Theo `.github/pull_request_template.md` nếu có; nội dung nêu thay đổi, lý do, các test **đã thực chạy**, rủi ro hoặc phần chưa kiểm chứng. Viết body vào file tạm rồi dùng `--body-file` để giữ xuống dòng trên cả PowerShell và Bash.
- Trả URL PR và trạng thái CI quan sát được. Không tự review, approve hoặc merge PR.

Khi `gh` thiếu đăng nhập/quyền hoặc push bị chặn, hoàn tất phần local đã được phép và báo rõ bước nào chưa xong.
