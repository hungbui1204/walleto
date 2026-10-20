# Review feature và UI Walleto — 18/10/2026

## Phạm vi

Review tĩnh 18 nhóm feature trong `lib/ui/views/`, navigation, BLoC, các luồng domain/data liên quan và test hiện có. Đây là danh sách việc cần kiểm tra và sửa; chưa xác minh hành vi trên thiết bị thật hoặc backend Supabase. Không có file ứng dụng nào được sửa trong lượt review.

## Ưu tiên cao

### 1. Request ghi có thể bị retry và tạo giao dịch trùng

- **Vị trí:** `lib/data/api/middleware/retry_on_error_interceptor.dart:30-52`, `lib/data/api/app_api_services.dart:166`, `lib/ui/views/create_transaction/bloc/create_transaction_bloc.dart:262-293`.
- **Điều kiện:** server đã nhận và lưu `POST /transactions`, nhưng response bị mất hoặc client timeout. Interceptor retry mà không kiểm tra HTTP method. Ngoài ra, hai lần chạm Lưu nhanh có thể chạy hai handler tạo giao dịch đồng thời.
- **Ảnh hưởng:** có thể có giao dịch trùng và số dư/thống kê sai. Chưa xác minh backend có cơ chế idempotency.
- **Hướng sửa:** chỉ tự retry request đọc an toàn; nếu muốn retry mutation, cần idempotency key được backend bảo đảm. Chặn submit lặp ở BLoC và phản ánh trạng thái đang lưu lên nút.
- **Test cần có:** mô phỏng response bị mất sau khi server nhận POST; gửi hai event xác nhận trước khi use case hoàn tất và xác nhận chỉ một lần ghi.

### 2. Có thể lưu sai số tiền khi đổi loại tiền giao dịch

- **Vị trí:** `lib/ui/views/create_transaction/bloc/create_transaction_bloc.dart:262-282,339-380`, `lib/ui/views/edit_transaction/bloc/edit_transaction_bloc.dart:267-287,343-384`.
- **Điều kiện:** chọn loại tiền khác loại tiền của ví rồi bấm Lưu trước khi request tỷ giá hoàn tất. `selectedCurrency` và `convertedAmount` chỉ được cập nhật sau `await`, trong khi nút Lưu vẫn có thể bật. Nếu đổi ví/loại tiền liên tiếp, response cũ cũng có thể ghi đè lựa chọn mới.
- **Ảnh hưởng:** số nhập chưa quy đổi có thể được lưu dưới đơn vị tiền của ví; response về sai thứ tự có thể dùng tỷ giá không còn phù hợp.
- **Hướng sửa:** lưu trạng thái đang lấy tỷ giá, vô hiệu hóa Lưu đến khi tỷ giá của cặp tiền hiện hành sẵn sàng; bỏ qua hoặc hủy response cũ; kiểm tra lại điều kiện trong handler Lưu.
- **Test cần có:** dùng `Completer` cho lúc tỷ giá đang tải và hai request trả về ngược thứ tự, ở cả form tạo và sửa.

### 3. Form ví kiểm tra số dư sai và có thể lưu thành 0

- **Vị trí:** `lib/ui/views/create_wallet/bloc/create_wallet_bloc.dart:29-30,44-52,73-90`, `lib/ui/views/edit_wallet/bloc/edit_wallet_bloc.dart:30-49`.
- **Điều kiện:** form tạo ví tính `isConfirmButtonEnabled` từ state cũ trước khi đưa tên/số dư vừa nhập vào state mới. Nhập số dư trước rồi tên có thể không bật Lưu; nhập tên trước rồi nhập giá trị không hợp lệ có thể bật Lưu. Form sửa ví dùng `double.tryParse(...) ?? 0`, nên dán chuỗi không phải số vào ví có số dư khác 0 có thể lưu số dư 0.
- **Ảnh hưởng:** không thể lưu dữ liệu hợp lệ trong một số thứ tự nhập; dữ liệu tài chính có thể bị thay bằng 0.
- **Hướng sửa:** tính điều kiện từ giá trị mới; chỉ cho lưu khi parse thành công và thỏa quy tắc số dư; không dùng 0 làm giá trị thay thế cho input sai. Kiểm tra lại input ngay trong handler Lưu.
- **Test cần có:** hai thứ tự nhập tên/số dư, giá trị âm hoặc không phải số, và thao tác dán vào form sửa ví.

## Ưu tiên vừa

### 4. Không lưu được khi chỉ sửa ngày hoặc ghi chú giao dịch

- **Vị trí:** `lib/ui/views/edit_transaction/bloc/edit_transaction_bloc.dart:57-93,299-310`, `lib/ui/views/edit_transaction/bloc/edit_transaction_state.dart:16`.
- **Điều kiện:** mở giao dịch, chỉ đổi ngày hoặc ghi chú. Hai handler chỉ cập nhật field tương ứng; `confirmButtonEnable` mặc định vẫn `false`.
- **Ảnh hưởng:** nút Lưu bị vô hiệu hóa dù người dùng đã sửa thông tin.
- **Hướng sửa:** tính lại điều kiện Lưu sau các thay đổi liên quan; nếu sản phẩm chỉ cho lưu khi có thay đổi, theo dõi dirty state riêng.
- **Test cần có:** mỗi luồng chỉ đổi ngày và chỉ đổi ghi chú.

### 5. Đổi ví sau khi lọc khoảng ngày làm mất giao dịch ngày cuối

- **Vị trí:** `lib/ui/views/transactions/bloc/transactions_bloc.dart:238-252,269-285`.
- **Điều kiện:** chọn một khoảng ngày rồi đổi ví. Nhánh chọn khoảng ngày gửi `toDate = end + 1 ngày`, nhưng nhánh đổi ví gửi thẳng `selectedDateRange.end` (đầu ngày cuối).
- **Ảnh hưởng:** các giao dịch trong ngày kết thúc có thể biến mất khỏi kết quả sau khi đổi ví.
- **Hướng sửa:** thống nhất quy ước mốc kết thúc, lý tưởng là dùng một hàm tạo `GetTransactionsInput` cho mọi nhánh lọc.
- **Test cần có:** chọn khoảng ngày, sau đó đổi ví và kiểm tra `toDate` vẫn bao gồm trọn ngày cuối.

### 6. Kéo để tải lại có thể quay mãi hoặc kết thúc quá sớm

- **Vị trí:** `lib/ui/views/transactions/transactions_view.dart:55-59`, `lib/ui/views/wallets/wallets_view.dart:30-34`.
- **Điều kiện:** `RefreshIndicator` chờ `bloc.stream.first` hoặc `appBloc.stream.first`. Nếu dữ liệu mới bằng dữ liệu cũ, BLoC có thể không phát state nên spinner không dừng. Với AppBloc, một state khác không liên quan cũng có thể làm spinner dừng trước khi request tải ví xong.
- **Ảnh hưởng:** người dùng không biết refresh đã hoàn tất hay chưa.
- **Hướng sửa:** chờ completion của chính tác vụ refresh, hoặc phát trạng thái refresh có vòng đời rõ ràng, thay vì chờ state bất kỳ.
- **Test cần có:** refresh danh sách rỗng/không đổi và AppBloc phát state không liên quan trong lúc đang tải ví.

### 7. Nội dung AI chat xuất hiện trong debug log

- **Vị trí:** `lib/ui/views/ai_chat/bloc/ai_chat_event.dart:22-25`, `lib/ui/base/bloc/app_bloc_observer.dart:54-58`, `lib/shared/utils/log_redactor.dart:47-57`, `lib/domain/usecases/base/stream/base_stream_use_case.dart:12-14`, `lib/data/api/middleware/custom_log_interceptor.dart:37-40`, `lib/data/api/app_api_services.dart:422-435`.
- **Điều kiện:** debug build hoặc môi trường thu thập debug log. Event, use case input và request body chứa nguyên trường `message`; bộ redact hiện không che trường này.
- **Ảnh hưởng:** nội dung tài chính hoặc riêng tư người dùng nhập vào chat có thể xuất hiện trong log thiết bị/IDE.
- **Hướng sửa:** chỉ log tên event/use case hoặc che nội dung `message` ở mọi đường log liên quan. Không dựa vào `toString()` của object chứa dữ liệu người dùng.
- **Test cần có:** đưa một chuỗi chat nhạy cảm qua các hàm log và xác nhận chuỗi không xuất hiện trong output.

### 8. Chạm thông báo Android không điều hướng

**Trạng thái: Pending.** Chưa có contract thống nhất cho payload thông báo và route đích; `handleNavigate` vẫn no-op cho đến khi xác định UX đích đến và dữ liệu cần thiết.

- **Vị trí:** `lib/ui/helper/local_notification_service.dart:60-86`.
- **Điều kiện:** người dùng mở app từ thông báo khi app đang nền hoặc đã đóng. Hai listener gọi `handleNavigate`, nhưng hàm này chưa có logic.
- **Ảnh hưởng:** chạm thông báo chỉ mở app, không dẫn đến nội dung được thông báo.
- **Hướng sửa:** xác định contract dữ liệu thông báo, ánh xạ từng loại tới route phù hợp và xử lý cả cold start lẫn background resume. Cần làm rõ UX đích đến trước khi implement.

## Khoảng trống sản phẩm đã thấy

- `lib/ui/views/budgets/budgets_view.dart:14-29` là placeholder; tab hiện mở AI Chat theo `lib/ui/navigation/routes/app_router.dart:83-89`. Đây là trạng thái được ghi rõ trong code, chưa kết luận là bug. Nếu Budgets nằm trong phạm vi phát hành tiếp theo, cần requirement riêng.

## Kiểm tra và giới hạn

- `git diff --check` không báo lỗi diff; chỉ có cảnh báo chuyển LF/CRLF cho vài file Markdown đang thay đổi sẵn trong working tree.
- Chưa chạy được `make analyze` hoặc `make testing`: cả `fvm flutter --version` và Flutter SDK trực tiếp đều không trả output sau 10 giây, nên các tiến trình đã được dừng. Agent sửa cần chạy `make verify` khi môi trường Flutter hoạt động.
- Chưa xác minh cơ chế idempotency/RLS trên backend, hành vi thiết bị thật, text scaling hay release build. Review này không chứng minh toàn bộ app không còn lỗi khác.
- Các file đang thay đổi sẵn trong working tree thuộc về người dùng; review này không sửa chúng.
