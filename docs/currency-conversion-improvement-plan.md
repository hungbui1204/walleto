# Plan cải thiện quy đổi ngoại tệ Walleto

Ngày lập: 22/10/2026.

Trạng thái: kế hoạch bàn giao từ kết quả review; chưa thực hiện thay đổi Flutter hoặc Supabase.

## 1. Mục tiêu và cách nhận việc

Sửa các đường đi có thể làm sai số tiền; thống nhất quy đổi giữa nhập giao dịch, số dư, báo cáo và AI; sau đó cải thiện hiệu năng và vận hành nguồn tỷ giá.

Agent nhận việc phải:

1. Đọc [CLAUDE.md](../CLAUDE.md), [AGENTS.md](../AGENTS.md), [CODING_RULES.md](../CODING_RULES.md) và kiểm tra lại working tree trước khi sửa. Review ban đầu đã bao gồm nhiều thay đổi chưa commit của user; không reset hoặc ghi đè chúng.
2. Làm theo từng đợt bên dưới, giữ diff đủ nhỏ để review. Mỗi đợt phải có test và báo cáo kết quả riêng.
3. Giữ kiến trúc `ui → domain ← data`, một interface `Repository`, BLoC và conventions hiện có. Không nhân dịp này đổi state management hoặc tách repository toàn app.
4. Không tự commit, push, mở PR, apply migration lên remote hoặc deploy Edge Function. Việc giao file plan không đồng nghĩa đã cho phép các hành động đó.
5. Phân biệt sửa source với thay đổi hệ thống đang chạy. Khi giao thực thi backend, cần nêu rõ phạm vi `supabase/**`; phân quyền role hiện tại của repo chưa liệt kê riêng phạm vi này.
6. Khi thiếu quyết định nghiệp vụ hoặc quyền truy cập backend, tiếp tục phần việc độc lập và nêu chính xác phần còn chờ; không tự chọn thay user một policy làm thay đổi lịch sử tiền.

Phạm vi dự kiến khi được giao implement:

- Flutter: `lib/**`, `test/**`, ARB hiện có và generated output tạo bằng codegen.
- Backend: migration mới, RPC, Edge Function và test trong `supabase/**`.
- Dependency mới, thay đổi CI/native và thao tác remote chỉ trong phạm vi user cho phép rõ ràng.

## 2. Bằng chứng và giới hạn của review đầu vào

Đã đọc các luồng Flutter, migration Supabase và Edge Function AI trong repo. Kết quả kiểm tra ở thời điểm review:

- `make analyze`: pass, không có issue.
- 44 test liên quan conversion, default currency, create/edit transaction, Home, Transactions, calculator và currency picker: pass.
- Đã mô phỏng phép JOIN/GROUP BY bằng SQLite in-memory: một giao dịch 10 USD với hai rate active cùng giá trị 25.000 cho tổng 500.000 thay vì 250.000; các currency có rate khác nhau tạo nhiều dòng cùng kỳ.

Giới hạn:

- Mô phỏng SQLite chỉ xác nhận lỗi phép ghép/tổng hợp, không thay thế kiểm thử function thật trên PostgreSQL.
- Chưa đối chiếu schema, function definitions, migrations đã apply, grants, RLS, dữ liệu và cron trên Supabase đang triển khai.
- Repo chưa có baseline tạo các bảng FX/currency/wallet/transaction cần thiết để tái dựng đầy đủ database từ đầu. Chưa thấy pipeline nạp FX hoặc test FX cho SQL/Edge Function trong repo; không được suy ra production không có chúng.
- 44 test pass không chứng minh các trường hợp thiếu rate, rate không hợp lệ, rounding và SQL aggregate đã đúng. Agent phải chạy lại checks sau implementation.

## 3. Danh sách vấn đề cần xử lý

### FX-01 — P1: tổng hợp tháng có thể nhân tiền hoặc tách sai kỳ

Nguồn: [migration tổng hợp/security hiện có](../supabase/migrations/20260913104500_secure_otp_rpc_rls_cron.sql), function `get_monthly_summary`.

- JOIN tất cả rate active có `created_at` cùng tháng giao dịch, không chọn duy nhất một quote.
- `GROUP BY p.label, p.month_date, er.rate` tách một tháng theo rate; lỗi xuất hiện ngay cả khi mỗi cặp chỉ có một rate nhưng tháng có nhiều currency.
- Nhiều bản ghi rate cùng giá trị có thể nhân số tiền trong SUM.

### FX-02 — P1: thiếu hoặc sai rate bị biến thành số tiền có vẻ hợp lệ

Nguồn:

- [ConvertAmountsToCurrencyUseCase](../lib/domain/usecases/convert_amounts_to_currency_use_case.dart).
- [ExchangeRateDataMapper](../lib/data/api/mappers/exchange_rate_data_mapper.dart).
- [CreateTransactionBloc](../lib/ui/views/create_transaction/bloc/create_transaction_bloc.dart), [EditTransactionBloc](../lib/ui/views/edit_transaction/bloc/edit_transaction_bloc.dart).
- `get_monthly_summary` trong migration nêu trên.

Mã tiền rỗng và rate không dương có thể được thay bằng `1`. RPC trả null được mapper biến thành entity rate `0`; form chỉ kiểm tra rate/converted amount non-null nên có thể cho gửi amount `0`. SQL cũng dùng `COALESCE(er.rate, 1)` cho currency khác nhau. Chưa xác minh constraint live có chặn ghi amount không hợp lệ hay không.

### FX-03 — P2: precision, input và edit chưa theo currency

Nguồn: [NumberFormatConstants](../lib/shared/constants/format/number_format_constants.dart), [TransactionAmountCalculator](../lib/ui/utils/transaction_amount_calculator.dart), [NumericKeyboard](../lib/ui/widgets/numeric_keyboard.dart), `EditTransactionBloc`.

Tiền/rate dùng `double`; phép nhân FX không lượng tử hóa theo currency đích; format chung tối đa hai số lẻ. `Currency.decimalPlaces` chưa tham gia tính toán/format. Edit tạo input từ chuỗi đã format, nên sửa note/ngày có thể làm mất phần lẻ của amount đã lưu. Bàn phím thiếu dấu thập phân.

### FX-04 — P2: default currency chưa đồng bộ giữa lưu cấu hình và các màn

Nguồn: [HomeBloc](../lib/ui/views/home/bloc/home_bloc.dart), [AppBloc](../lib/ui/app/bloc/app_bloc.dart), [TransactionsBloc](../lib/ui/views/transactions/bloc/transactions_bloc.dart).

Home phát event persist rồi emit số liệu mới, không chờ lưu profile thành công. Transactions cập nhật danh sách ví/Total nhưng chưa tính lại `allDayTransactions` khi base currency đổi.

### FX-05 — P2: AI tính tổng tháng từ dữ liệu bị giới hạn

Nguồn: [ai_chat/index.ts](../supabase/functions/ai_chat/index.ts), `TX_QUERY_LIMIT`, `getLatestRateMap` và phần dựng finance context.

Tối đa 100 giao dịch được dùng để tính tổng tháng. Giao dịch thiếu rate bị bỏ qua; lỗi truy vấn rate trở thành map rỗng. Prompt có thông tin thiếu rate nhưng chưa có hợp đồng tổng hợp thể hiện đầy đủ/không đầy đủ bằng dữ liệu có cấu trúc.

### FX-06 — P2: xếp hạng ví so trực tiếp tiền khác đơn vị

Nguồn: function `get_top_wallet_stats` trong migration tổng hợp/security hiện có.

`ORDER BY wt.total_amount DESC` so số raw giữa các ví có currency khác nhau; cần đổi về cùng đơn vị trước khi xếp hạng.

### FX-07 — P2: Home thiếu bảo vệ lựa chọn currency mới nhất

Nguồn: `HomeBloc`, [EventTransformerMixin](../lib/ui/base/bloc/mixin/event_transformer_mixin.dart).

`log()` dùng `flatMap`, cho event chạy đồng thời. Home chưa có request generation guard như create/edit transaction; response cũ có thể emit và persist currency cũ sau lựa chọn mới.

### FX-08 — P2: cache ngắn hạn và nhiều RPC tuần tự

Nguồn: `ConvertAmountsToCurrencyUseCase`, `TransactionsBloc`.

Cache nằm trong mỗi lần gọi use case; mỗi ngày lại gọi use case mới. 30 ngày × 3 cặp có thể phát sinh 90 request cho tổng ngày. Subscription mọi AppState còn tính lại Total khi chỉ đổi flag không liên quan.

### FX-09 — cải tiến mô hình: chưa giữ nguồn gốc phép quy đổi

Nguồn: [Transaction](../lib/domain/entities/transaction.dart), [TransactionData](../lib/data/api/models/transaction_data.dart), create/edit transaction và API ghi giao dịch.

Contract hiện chủ yếu giữ amount đã đổi và currency ví, không có đủ original amount/currency và quote đã áp dụng để tái dựng phép tính. Đây là giới hạn thiết kế cần xử lý, không phải bằng chứng mọi giao dịch hiện có đều sai.

### FX-10 — cải tiến integrity: cần kiểm soát ghi tiền tại backend

Nguồn: [AppApiServices](../lib/data/api/app_api_services.dart), `update_transaction`, trigger cập nhật số dư trong migration tổng hợp/security.

Client gửi amount đã tính; RPC cho đổi `currency_code`; trigger cộng/trừ raw amount. Cần xác minh và enforce currency của amount ghi sổ phải khớp ví, ownership và quote hợp lệ. Không giả định constraint/RLS live bị thiếu chỉ vì chưa có baseline trong repo.

## 4. Quyết định cần chốt trước phần nâng cấp mô hình

Các đề xuất dưới đây chưa phải quyết định sản phẩm đã được user duyệt. Hotfix bỏ fallback giả, sửa cardinality SQL và giữ amount khi sửa metadata có thể làm trước mà không chờ toàn bộ phần này.

- [ ] **Tiền ghi vào ví:** đề xuất lưu khoản tăng/giảm thực tế của ví; tỷ giá tham chiếu là gợi ý. Có cho nhập actual amount/rate và phí riêng không?
- [ ] **Tổng tài sản hiện tại:** đề xuất dùng cùng snapshot tỷ giá hiện tại, hiển thị là ước tính; không viết lại số dư từng ví.
- [ ] **Báo cáo lịch sử:** đề xuất tỷ giá theo ngày giao dịch, thống nhất Home, tổng ngày và AI. Xác định rõ snapshot đã khóa hay có cho lịch sử thay đổi khi provider hiệu chỉnh rate.
- [ ] **Rounding:** chọn biểu diễn tiền, rounding mode, bước rounding và xử lý phần chênh; dùng currency metadata được dự án hỗ trợ, không áp một quy tắc hai số lẻ cho tất cả.
- [ ] **Missing/stale:** chọn giới hạn tuổi quote theo provider/lịch publish; cách dùng last-known-good cuối tuần; chặn ghi hay cho nhập actual; cách hiển thị báo cáo thiếu dữ liệu.
- [ ] **Edit/duplicate:** sửa note giữ nguyên tiền/quote; đổi ngày có tính lại không; duplicate dùng quote cũ hay tạo quote mới? Không tự mặc định reprice giao dịch cũ.
- [ ] **Provider/cross rate:** độ phủ currency đang hỗ trợ, historical data, license/chi phí, tần suất và cặp trực tiếp hoặc qua pivot. Chưa chọn nhà cung cấp trong plan này.

Ghi lại quyết định vào mục này khi user xác nhận. Không hard-code TTL, scale tối đa hoặc behavior mới dựa trên một ví dụ minh họa.

## 5. Trình tự thực hiện

### Đợt 0 — Đối chiếu backend và khóa baseline

Mục tiêu: biết chính xác mình đang sửa contract nào, tránh migration dựa trên giả định.

- [ ] Ghi nhận branch/commit, các thay đổi chưa commit và toolchain thực tế.
- [ ] Nếu đã có kết nối, kiểm tra read-only đúng project/environment: migrations đã apply; function definitions/overloads; cột tiền/rate và scale; FK/check/unique/index; grants/RLS; trigger; provider và cron FX.
- [ ] Thống kê không chứa PII: currency được hỗ trợ, cặp thiếu, số quote active/cặp, tuổi quote và timestamp bất thường. Không ghi token hoặc dữ liệu giao dịch cá nhân vào báo cáo/log.
- [ ] Xác định baseline dựng local/test DB; nếu cần lấy schema từ remote, chỉ dùng thao tác đọc và không ghi đè migration/schema user đang có.
- [ ] Không có quyền live thì ghi giới hạn rõ ràng, vẫn tiếp tục Flutter/test và chuẩn bị migration có thể review được.

**Nghiệm thu:** có baseline và danh sách drift/unknown; không gọi một migration là đã triển khai chỉ vì file tồn tại. Không tự reset database để dựng baseline.

### Đợt 1 — Hotfix độ đúng của số tiền

Xử lý FX-01, FX-02 và phần edit metadata của FX-03.

**Flutter/domain/data:**

- [ ] Validate currency thuộc tập được hỗ trợ; không coi hai mã rỗng là identity. Normalize mã ở boundary một cách nhất quán.
- [ ] Chỉ cùng currency hợp lệ mới trả rate `1` mà không gọi API.
- [ ] Quote currency khác nhau phải đúng cặp, active, rate dương và hữu hạn. Null/malformed/invalid không được map thành quote có thể sử dụng.
- [ ] Phân biệt lỗi missing, invalid, stale và lỗi mạng bằng cơ chế exception/state hiện có; bổ sung i18n tương ứng.
- [ ] Create/edit không cho submit khi quote lỗi hoặc converted amount không hợp lệ. Giữ các guard request cũ, loading và chống submit trùng hiện có.
- [ ] Kiểm tra amount giao dịch sau tính toán theo invariant nghiệp vụ; không áp quy tắc amount giao dịch cho số dư ví, vì ví có thể bằng 0 hoặc âm.
- [ ] Chỉ sửa note/category/date theo policy thì giữ raw amount đã lưu; không lấy chuỗi hiển thị đã rounding để ghi lại tiền.

**SQL:**

- [ ] Migration mới sửa aggregate: mỗi giao dịch ghép tối đa một quote; SUM rồi GROUP BY kỳ, không GROUP BY rate.
- [ ] Thứ tự chọn quote phải deterministic, có tie-breaker ID và thời điểm định giá. Dùng `LATERAL ... ORDER BY ... LIMIT 1` hoặc cách tương đương có test.
- [ ] Không dùng `created_at cùng tháng` như một policy FX ngầm. Nếu historical policy chưa chốt, ghi rõ policy hotfix và không tự chuyển toàn app từ latest sang historical.
- [ ] Bỏ fallback `1` cho cặp khác currency. Đợt đầu có thể trả lỗi rõ ràng thay vì một tổng giả đầy đủ; subtotal chỉ được hiển thị khi contract/UI có trạng thái incomplete.
- [ ] Trả đúng một dòng/kỳ theo contract đang được client dùng; tháng không có giao dịch vẫn có kết quả xác định. UI chọn kỳ bằng nhãn/khoảng thời gian, không dựa tùy tiện vào vị trí `first` sau `reversed`.

**Nghiệm thu:** fixture nhiều currency/nhiều rate không nhân hoặc mất tiền; missing rate không bị tính 1:1; rate 0 không thể dẫn tới submit amount 0; sửa note không đổi amount. Có pgTAP/PostgreSQL test cho SQL thật.

### Đợt 2 — Chuẩn hóa tiền, quote và lịch sử giao dịch

Phụ thuộc: quyết định tại mục 4 đã chốt cho phần tương ứng. Xử lý FX-03, FX-09, FX-10.

**Hợp đồng dữ liệu đề xuất, tên field có thể điều chỉnh theo conventions:**

- Tiền ghi sổ: giữ nghĩa hiện tại của `amount` và `currency_code` là amount theo đơn vị ví để giảm breaking change.
- Nguồn nhập: `original_amount`, `original_currency`.
- Quote đã dùng: `applied_rate`, `rate_id`, `rate_source`, `rate_effective_at`, `rate_type`, phiên bản rounding/policy nếu cần để tái dựng.
- Quote/catalog: phân biệt `effective_at` và `fetched_at`; định nghĩa rõ `is_active` là bản ghi còn hợp lệ hay chỉ bản mới nhất. Historical lookup không được vô tình loại bỏ toàn bộ rate cũ chỉ vì refresh latest.
- Tổng hợp: `base_currency`, `valuation_at`, `valuation_policy`, snapshot/version, `is_complete`, `missing_pairs`, `excluded_count`. Với tổng theo lịch sử, snapshot là tập các quote được chọn, không có nghĩa mọi giao dịch dùng một thời điểm rate.

**Tiền chính xác:**

- [ ] Chọn decimal chính xác hoặc integer minor units cho nghiệp vụ tiền. Backend dùng `numeric` hoặc minor units sau khi kiểm tra schema thật; precision phải bao phủ range app hỗ trợ.
- [ ] Không hard-code `numeric(...,2)` cho mọi currency. Quote giữ độ chính xác cao hơn tiền; kiểm tra cả NaN/Infinity theo khả năng kiểu dữ liệu.
- [ ] Bảo toàn precision trên đường JSON/API; decimal string hoặc minor units không được chuyển qua binary `double` rồi coi là phép tính chính xác.
- [ ] Dùng `decimal_places` cho input, format, validation và lượng tử hóa. Cho nhập phần lẻ với currency phù hợp; không làm tròn trung gian nhiều lần.
- [ ] Tách amount nghiệp vụ khỏi chuỗi format có dấu phân nhóm/locale. Sửa metadata không thay đổi giá trị legacy, kể cả legacy có phần lẻ chưa chuẩn; chuẩn hóa legacy là migration riêng có đối soát.

**RPC ghi nhận atomic:**

- [ ] Xác thực ownership transaction và mọi ví liên quan; lấy user từ phiên xác thực, không tin user ID do client gửi.
- [ ] Enforce amount ghi sổ khớp currency ví. Quote auto phải đúng cặp, policy/time và còn hợp lệ; manual actual amount/rate chỉ khi policy đã cho phép và được đánh dấu nguồn.
- [ ] Server tính/validate amount và rounding; preview Flutter dùng cùng contract và giữ quote/snapshot đã xác nhận. Không lặng lẽ đổi quote giữa preview và save.
- [ ] Ghi transaction và delta số dư trong một transaction DB. Nếu giữ trigger hiện có thì RPC không cộng/trừ số dư lần thứ hai.
- [ ] Hỗ trợ idempotency theo user + operation key; cùng key/payload trả lại kết quả cũ, cùng key/payload khác trả conflict. Có unique constraint để chặn request đồng thời.
- [ ] Insert/update/delete/move wallet/duplicate/adjust balance đều được kiểm tra. Lock nhiều ví theo thứ tự ổn định, rollback toàn bộ khi lỗi.
- [ ] Rà direct table writes và RPC cũ để không bypass invariant, đồng thời lập lộ trình tương thích client cũ trước khi revoke quyền.

**Nghiệm thu:** reconstruct được phép quy đổi mới; cập nhật nguồn FX không đổi giao dịch đã ghi; không double-update balance; retry không tạo trùng; metadata edit không đổi tiền; test currency 0/2/3 số lẻ và amount biên đều pass.

### Đợt 3 — Một policy tổng hợp cho Home, Transactions và AI

Xử lý FX-01 đầy đủ, FX-05, FX-06 và khác biệt current/historical giữa các luồng.

- [ ] Tạo/reuse RPC tổng hợp dùng cùng resolver FX và contract mục 4–5. Không để AI có thuật toán rate riêng khác Home khi cùng policy/kỳ.
- [ ] Query toàn bộ tập giao dịch phù hợp để tính aggregate trong DB; giới hạn/pagination chỉ dùng cho danh sách chi tiết và ngữ cảnh AI.
- [ ] AI nhận aggregate đầy đủ, trạng thái missing/stale/error; không gọi subtotal là total đầy đủ. Khi không đủ dữ liệu, câu trả lời phải nói rõ phạm vi thiếu.
- [ ] Mọi tổng thu/chi/net/category và xếp hạng ví đều cùng base trước khi so sánh. Có thể hiển thị thêm amount gốc của ví.
- [ ] Historical quote phải đúng hướng cặp, không lấy quote tương lai; cuối tuần chọn bản trước đó trong ngưỡng policy. Không thay thế rate lịch sử thiếu bằng latest một cách ngầm định.
- [ ] Chuẩn hóa khoảng thời gian và timezone của user giữa SQL, Flutter và Edge Function. Ưu tiên range `[start, end)` trên timestamp UTC được tính từ timezone của user; tránh cộng thêm ngày hai lần hoặc chọn kỳ theo timezone server.
- [ ] Xác định aggregation rounding: tổng tiền đã ghi theo wallet và tổng quy đổi báo cáo phải có policy rõ ràng; chênh do rounding không được bị diễn giải thành mất giao dịch.

**Nghiệm thu:** cùng dataset, base currency, kỳ, timezone và policy cho cùng tổng trên Home/Transactions/AI; hơn 100 và hơn giới hạn trả dòng Data API không làm thiếu aggregate. Ví chi 100 USD đứng trên 500.000 VND với fixture 1 USD = 25.000 VND.

### Đợt 4 — Đồng bộ state và xử lý concurrency

Xử lý FX-04, FX-07.

- [ ] Một luồng chịu trách nhiệm persist base currency, xác nhận thành công rồi phát state/event thống nhất. Không gọi repository trực tiếp từ UI/BLoC.
- [ ] Lưu thất bại phải giữ hoặc khôi phục nhất quán lựa chọn và số liệu cũ; không để Home mới nhưng AppBloc/profile cũ.
- [ ] Home, danh sách ví Total, tổng ngày và các chart liên quan phản ứng đúng khi base currency thay đổi, kể cả tab đã được giữ sống.
- [ ] Dùng request generation/guard cho kết quả đọc cũ và điều phối tuần tự/coalesce thao tác persist. Chỉ hủy emit không đủ vì request ghi cũ vẫn có thể hoàn tất sau request mới.
- [ ] Kết quả và cache gắn dữ liệu user phải bị vô hiệu hóa khi session/account thay đổi. Tách quote công khai khỏi aggregate/user cache.
- [ ] State có loading/error/stale rõ ràng; dùng `runBlocCatching`, `buildWhen`/`listenWhen` và transformer theo conventions, không tạo rebuild/side effect thừa.

**Nghiệm thu:** chọn EUR rồi JPY, response đảo thứ tự vẫn giữ JPY ở UI/AppBloc/backend; save preference lỗi không chia đôi state; đổi currency cập nhật tổng ngày; response phiên cũ không xuất hiện trong phiên mới.

### Đợt 5 — Batch, cache và tối ưu query

Xử lý FX-08 sau khi contract rate/policy ổn định.

- [ ] Gom unique lookup keys cho toàn kỳ rồi gọi batch; key gồm pair, valuation time/date phù hợp, rate type và policy/provider khi cần. Historical lookup không được cache chỉ theo pair.
- [ ] Cache quote ở data layer, gộp các request đang chạy; không cache lỗi thành success/rate 0. Historical và current có invalidation khác nhau.
- [ ] Lọc subscription theo wallets/base currency thực sự thay đổi. Không fetch lại FX vì mọi event reload flag/theme không liên quan.
- [ ] Dùng cùng snapshot trong một lần tính để không trộn quote từ nhiều thời điểm refresh.
- [ ] Thiết kế composite/partial index theo query thật: equality pair/provider trước, thời gian và tie-breaker sau. Chỉ dùng điều kiện active phù hợp mô hình historical/latest đã chốt.
- [ ] Kiểm tra query plan bằng `EXPLAIN`; chỉ chạy `EXPLAIN ANALYZE` trên fixture/local/staging đã được phép. Tránh filter `date_trunc` trên cột giao dịch nếu range timestamp có thể dùng index phù hợp.

**Nghiệm thu:** 30 ngày dùng cùng một cặp/current snapshot không phát 30 RPC; batch historical có số lookup theo unique keys cần thiết; concurrent calls không nhân request; có đo query count/latency trước–sau với cùng fixture.

### Đợt 6 — Nguồn tỷ giá và vận hành

Thực hiện sau khi kiểm tra pipeline hiện hữu; không tạo cron/provider trùng.

- [ ] Adapter provider chỉ phía server; khóa provider trong secret manager/Vault phù hợp, không bundle vào Flutter hoặc ghi vào migration.
- [ ] Refresh job idempotent theo source/pair/effective time, cập nhật snapshot có tính nguyên tử, retry/backoff và tránh job chồng lấn.
- [ ] Validate supported currencies, rate dương/hữu hạn, timestamps và biến động bất thường; quarantine dữ liệu lỗi thay vì ghi đè last-known-good.
- [ ] Cross rate/reciprocal chỉ dùng khi cùng loại rate và snapshot tương thích. Với mid quotes cùng base, A→B = quote(B)/quote(A); không áp phép nghịch đảo mid một cách ngây thơ cho bid/ask.
- [ ] Theo dõi freshness, missing-pair count, refresh failures, quote outliers và latency; không đưa amount, note, user ID hoặc token vào telemetry không cần thiết.
- [ ] Chỉ enable/schedule/deploy lên remote khi user cho phép và có cấu hình cụ thể của environment.

**Nghiệm thu:** provider gián đoạn không sinh tỷ giá giả; stale được nhận diện; refresh trùng không nhân bản quote; đủ coverage currency thực tế của app và có vận hành/rollback rõ ràng.

## 6. Migration, tương thích và quyền truy cập

- [ ] Tạo migration mới bằng Supabase CLI sau khi kiểm tra version/`--help`; không sửa migration lịch sử để giả định DB sẽ tự cập nhật. Chỉ thử schema changes trên local/disposable DB hoặc environment đã được cho phép.
- [ ] Nếu schema mới ảnh hưởng client đang phát hành, dùng cách expand → migrate → contract: thêm contract/field tương thích trước, phát hành client sau, chỉ bỏ quyền/contract cũ khi có điều kiện cắt rõ ràng.
- [ ] Không backfill original currency/quote bằng cách đoán từ amount hiện tại. Legacy không có bằng chứng phải được đánh dấu unknown/legacy; chỉ backfill dữ kiện suy ra chắc chắn.
- [ ] Chuyển kiểu/rounding dữ liệu tiền cần bản đối soát trước–sau: amount từng transaction, số dư theo ví và tổng theo currency. Không so trực tiếp số tiền khác đơn vị.
- [ ] Không mặc định số dư ví = tổng giao dịch nếu có opening balance/adjustment; dùng phương trình đối soát thực tế của app.
- [ ] Giữ RLS và grants trên `exchange_rates`: authenticated đọc theo mô hình shared reference data; client không được ghi rate. Grants của function và table là các lớp kiểm soát khác nhau.
- [ ] Ưu tiên `SECURITY INVOKER`; nếu cần `SECURITY DEFINER`, document lý do, hạn chế EXECUTE, pin search_path và schema-qualify đối tượng, kiểm tra ownership trong body. Không thêm DEFINER để chữa permission error.
- [ ] Bảo vệ invariant kể cả khi client gọi REST trực tiếp. Không revoke đường ghi của app cũ trước khi có phương án tương thích.
- [ ] Rollback phải giữ tiền và FX snapshot đã ghi; không xóa cột chứa dữ liệu mới hoặc đảo rounding mù quáng. Ưu tiên forward fix và versioned RPC khi cần.

## 7. Kiểm thử bắt buộc

### Flutter

- [ ] Use case/mapper/API: same currency hợp lệ không fetch; null/malformed quote, sai cặp, inactive, 0/âm/NaN/Infinity, mã rỗng và stale không thành rate 1/0 hợp lệ.
- [ ] Create/edit: loading/error chặn submit, retry hoạt động, amount thay đổi trong lúc fetch được tính đúng, đổi ví/currency bỏ qua response cũ; chống submit trùng vẫn đúng.
- [ ] Precision: currency 0/2/3 số lẻ, nhập `12.50`, amount lớn, FX rate nhỏ, rounding boundary; chuỗi format/locale không đổi raw money.
- [ ] Edit note/date theo policy không đổi amount/quote; duplicate và move wallet theo policy đã chốt.
- [ ] Base currency: persistence lỗi, request đảo thứ tự, các tab giữ sống, tổng ngày refresh và session/account đổi.
- [ ] Cache: batch/dedup, TTL, historical key, provider failure, logout invalidation của dữ liệu user và event không liên quan.

Đặt/cập nhật test mirror `lib/` trong `test/`, bao gồm các file hiện có: `convert_amounts_to_currency_use_case_test.dart`, `update_user_default_currency_use_case_test.dart`, test create/edit transaction, Home, Transactions, calculator; thêm test mapper/contract nơi chưa có.

### PostgreSQL / pgTAP

- [ ] Cardinality một dòng/kỳ với nhiều currencies/rates, tie timestamp, tháng rỗng và missing quote.
- [ ] Historical lookup không lấy rate tương lai; cuối tuần, timezone, giao dịch tại biên tháng.
- [ ] Precision/scale và constraint; dữ liệu đặc biệt không vượt qua validation.
- [ ] Ownership/roles: anonymous, user A, user B, backend writer; không sửa rate hoặc transaction/ví người khác.
- [ ] Trigger và RPC atomic cho insert/update/delete/move/duplicate/adjustment; concurrent writes không lost update hoặc double-count.
- [ ] Idempotency cùng key/payload và key/payload khác; unique constraint hoạt động dưới concurrency.
- [ ] Migration chạy trên baseline được hỗ trợ, client contract cũ còn hoạt động theo lộ trình và đối soát tiền pass.

### Edge Function và kiểm thử xuyên luồng

- [ ] AI tổng hợp đúng với 101 giao dịch và tập lớn hơn row limit; recent list limit không giới hạn aggregate.
- [ ] Rate query lỗi, thiếu/stale quote và timezone được truyền thành trạng thái chính xác; AI không bịa tổng.
- [ ] Bộ fixture chung so sánh Home/Transactions/AI theo cùng policy.
- [ ] Smoke test thiết bị/emulator: nhập ngoại tệ, sửa metadata, đổi ví/base currency, mất mạng/retry, duplicate, refresh và hiển thị thông tin tỷ giá.

## 8. Kiểm tra trước khi bàn giao implementation

Theo role và quyền của task triển khai:

```bash
# Chỉ khi thay đổi annotations/model/DI/routes cần sinh lại.
make force_build

# Chỉ khi thêm/sửa chuỗi; cập nhật mọi ARB hiện có.
make l10n

# Format đúng các file Dart đã sửa, không format diện rộng.
fvm dart format <cac-file-da-sua>

# Chạy focused regression tests trước, rồi bộ kiểm tra của repo.
make verify
```

Với Supabase, agent kiểm tra CLI version và `--help` để chọn lệnh đúng cho migration/DB tests, không đoán flags. Ghi nguyên lệnh, environment và kết quả vào bàn giao. Chạy SQL regression trên PostgreSQL thật, Edge tests và advisors phù hợp; phân biệt rõ local/staging với production, test chưa chạy với test pass.

Tự review bằng các skill `walleto-code-review`, `walleto-bloc-check`, `walleto-security-review` và Supabase/Postgres best practices theo phạm vi thay đổi. Docs-only plan hiện tại không cần chạy lại build hoặc test app.

Definition of done cho từng đợt:

- [ ] Những mục đã làm được tick, kèm quyết định nghiệp vụ liên quan và thay đổi contract.
- [ ] Có regression test cho lỗi sửa; checks bắt buộc pass hoặc blocker được mô tả bằng bằng chứng.
- [ ] Có diff tập trung, barrel/i18n/codegen đúng conventions.
- [ ] Có đánh giá tương thích mobile client cũ, dữ liệu legacy, rollout/rollback và kết quả đối soát nếu chạm tiền/schema.
- [ ] Nêu rõ migration/Edge Function mới chỉ chuẩn bị hay đã triển khai trên environment nào với quyền nào.
- [ ] Không commit/push/PR/deploy nếu chưa được yêu cầu riêng.

## 9. Mẫu giao việc cho agent triển khai

> Đọc `docs/currency-conversion-improvement-plan.md` và các rules của repo. Thực hiện Đợt 0 và Đợt 1 trước; phạm vi source được giao gồm `lib/**`, `test/**` và `supabase/**`. Chỉ kiểm tra remote theo chế độ đọc nếu kết nối sẵn; không apply migration, deploy, commit, push hoặc tạo PR. Giữ nguyên thay đổi chưa commit của tôi. Thêm regression tests cho lỗi tiền và SQL, chạy kiểm tra phù hợp rồi báo diff/kết quả. Chỉ chuyển sang các đợt sau khi đã xác định dependency và chốt những policy ảnh hưởng chúng; tiếp tục phần độc lập nếu còn quyết định cần hỏi.

Mẫu trên là nội dung để user giao ở task tiếp theo; bản thân việc tạo plan chưa thực thi hoặc cấp quyền deploy.

## 10. Tài liệu tham chiếu

Các đề xuất áp dụng cho Walleto là kết luận review; tài liệu dưới đây hỗ trợ nguyên tắc kỹ thuật, không thay thế quyết định sản phẩm.

- [PostgreSQL numeric types](https://www.postgresql.org/docs/current/datatype-numeric.html): decimal chính xác và giới hạn floating point.
- [Supabase database functions](https://supabase.com/docs/guides/database/functions): function security, ownership và grants.
- [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security): kết hợp grants và row policies.
- [Supabase database testing](https://supabase.com/docs/guides/database/testing): kiểm thử PostgreSQL/pgTAP.
- [PostgreSQL partial indexes](https://www.postgresql.org/docs/current/indexes-partial.html), [multicolumn indexes](https://www.postgresql.org/docs/current/indexes-multicolumn.html): index theo query thực tế.
- [PostgreSQL locking/deadlocks](https://www.postgresql.org/docs/current/explicit-locking.html#LOCKING-DEADLOCKS): thứ tự lock nhất quán.
- [ECB reference rates](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html): phân biệt reference rate và khoản thanh toán thực tế; không phải lựa chọn provider đã chốt cho Walleto.
- [Supabase changelog](https://supabase.com/changelog.md): agent triển khai kiểm tra thay đổi liên quan và tài liệu hiện hành trước khi dùng API/CLI.
