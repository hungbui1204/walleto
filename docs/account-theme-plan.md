# Kế hoạch: chọn Light / Dark theme từ màn Account

**Trạng thái:** Thiết kế lịch sử; phần triển khai đã được merge qua [PR #40](https://github.com/hungbui1204/walleto/pull/40). Mục “Hiện trạng” ghi lại repo tại thời điểm lập kế hoạch.

**Trạng thái thiết kế:** đã chốt **phương án A — Pearl Teal** cho Light theme. Coding agent dùng [preview A](previews/light-theme/option-a.png) và [trang so sánh](previews/light-theme/index.html#concept-a) làm tham chiếu trực quan; B/C chỉ là phương án đã xem, không nằm trong phạm vi triển khai.

## 1. Mục tiêu và giả định sản phẩm

- Thêm hai nút biểu tượng mặt trời (Light) và mặt trăng (Dark) vào màn Account. Chạm nút nào thì **toàn app** đổi sang theme tương ứng; nút đang chọn có trạng thái rõ ràng và nhãn đọc màn hình.
- Lựa chọn được lưu trên thiết bị và phục hồi trước khung hình đầu tiên khi mở lại app. Mặc định **Dark** để giữ trải nghiệm hiện tại. Chỉ có hai chế độ thủ công, không có chế độ theo hệ thống.
- Theme là cài đặt của thiết bị, tiếp tục giữ sau đăng xuất/đăng nhập. Không đồng bộ backend.
- Light dùng hướng **Pearl Teal** đã chọn: nền ngọc trai, thẻ trắng, chữ xanh đen và teal đậm. Giữ cấu trúc màn hiện có; preview dùng dữ liệu mẫu, không yêu cầu đổi nội dung nghiệp vụ.
- Tài liệu ghi lại quyết định thiết kế trước khi thay đổi Dart và asset.

## 2. Hiện trạng đã kiểm tra

| Vị trí | Kết quả |
| --- | --- |
| `lib/ui/views/account/account_view.dart` | Account hiển thị thông tin cá nhân, My Wallets, Categories, Sign Out; chưa có điều khiển theme. `AccountBloc` chỉ tải user. |
| `lib/ui/app/walleto_application.dart` | `MaterialApp.router` chỉ nhận `AppThemes.appTheme`; `BlocBuilder<AppBloc, AppState>` có `buildWhen: (_, _) => false`, nên app không thể rebuild theo theme hiện tại. |
| `lib/resources/styles/app_themes.dart` | Chỉ có `ThemeData.dark`, `ColorScheme.dark` và date picker tối. |
| `lib/resources/styles/app_colors.dart`, `app_text_styles.dart`, `app_decorations.dart` | Màu tối là các hằng số toàn cục, kể cả `blackColor` đang là chữ sáng `#EDEDEF`; nhiều text style/decorations lấy trực tiếp các hằng số này. Đổi riêng `ThemeData` không đổi màu của chúng. |
| `lib/ui/widgets/noir_backdrop.dart`, `lib/ui/views/main/main_view.dart`, `lib/ui/views/main/widgets/custom_bottom_navigation_bar.dart` | Nền, tab scaffold và bottom bar đều dùng màu tối cố định. |
| `lib/data/preferences/app_preferences.dart`, `lib/di/di.dart`, `pubspec.yaml` | `SharedPreferencesAsync` đã có dependency và đăng ký DI; `AppPreferences` hiện chỉ dùng secure storage cho auth. Không cần package mới. |
| `lib/main.dart`, `lib/config/app_config.dart` | Có luồng khởi tạo trước `runApp`; system bars đang đặt màu icon cố định qua `UiConstants.systemUiOverlay` / `EdgeToEdgeHelper`. |
| `assets/icons/`, `lib/resources/l10n/intl_en_US.arb` | Chưa có icon sun/moon hoặc key Light/Dark/Appearance; có thể dùng `Icons.light_mode_outlined` và `Icons.dark_mode_outlined`, không cần asset/codegen icon. |
| `test/` | Đã có convention unit/widget test để làm theo; chưa có test cho theme. |

Phạm vi UI thực tế rộng hơn Account: tìm kiếm hiện tại cho thấy nhiều chỗ trong `lib/ui/` dùng `blackColor`, `surfaceColor`, `scaffoldBackgroundColor`, `AppTextStyles` và `AppDecorations`. Cần rà cả login, các tab, form, sheet, dialog, chart, shimmer và popup để Light thật sự dùng được.

## 3. Thiết kế triển khai đề xuất

### 3.1 Nguồn trạng thái và lưu trữ

1. Tạo enum thuần Dart `AppThemePreference { light, dark }` trong domain. Dùng giá trị ổn định (`light` / `dark`) khi lưu; giá trị trống hoặc không hợp lệ trả về `dark`.
2. Thêm key vào `SharedPreferenceKeys`, phương thức đọc/ghi trong `AppPreferences` bằng `SharedPreferencesAsync`. Theme không phải dữ liệu nhạy cảm; **không** đưa vào secure storage và **không** xóa khi sign out.
3. Thêm `getAppThemePreference` / `setAppThemePreference` vào `Repository` và `RepositoryImpl`, rồi use case đọc/ghi theo pattern hiện có. Không gọi data layer từ Account hoặc root UI; không thêm API server.
4. Đọc preference sau khi DI sẵn sàng, trước `runApp` tại luồng bootstrap trong `main.dart`, truyền giá trị ban đầu vào `WalletoApplication`. Nếu đọc lỗi, dùng Dark và ghi log phù hợp, không chặn mở app. Giá trị theme hiệu lực tại root và trạng thái chọn ở Account phải khớp ngay khung hình đầu tiên, không nháy Dark khi preference là Light.
5. Dùng `AppBloc` làm nguồn cập nhật toàn app: thêm trạng thái theme và event chọn theme; handler gọi use case ghi preference trong `runBlocCatching` với `transformer: log()`. Root `BlocBuilder` chỉ rebuild khi theme đổi. Khi ghi lỗi, giữ/khôi phục theme trước đó và báo lỗi theo cơ chế sẵn có. Disable hai lựa chọn trong lúc lưu để tránh các lần chạm liên tiếp làm giá trị lưu và giao diện lệch nhau.

### 3.2 Hai theme và màu semantic

1. Giữ nguyên palette Dark đang dùng. Tạo palette Light **Pearl Teal** theo bảng dưới; mở rộng thành các vai trò màu semantic cần thiết (background, surface, foreground, secondary text, border, accent, error, glass, shimmer, overlay, chart) trong `resources/styles`. Widget đọc palette theo `BuildContext`/`ThemeExtension` hoặc `ColorScheme`, không lấy hằng số Dark cho bề mặt/chữ của Light.
2. Cập nhật `AppThemes` thành `lightTheme` và `darkTheme`, cấu hình `theme`, `darkTheme`, `themeMode` tại `MaterialApp.router`; date picker, dialog, sheet, app bar, selection, tab và FAB có màu đúng với từng chế độ.
3. Chuyển các chỗ cần màu semantic từ hằng số Dark sang palette: `AppTextStyles`, `AppDecorations`, `NoirBackdrop`/`NoirScaffoldBody`, các common widgets, Account, Main/bottom nav và các view đang dùng màu cố định. Có thể giữ tên widget `NoirScaffoldBody` trong đợt này để hạn chế diff; hành vi của nó phải theo theme.
4. Rà các trường hợp màu có ý nghĩa cố định (ví dụ chữ trắng trên CTA, xanh/đỏ cho số tiền) riêng với màu foreground/surface theo theme; không thay hàng loạt theo tên `blackColor` vì tên này hiện không phản ánh giá trị thật.
5. Đồng bộ status bar/navigation bar icon brightness theo độ sáng theme; rà các `SystemUiOverlayStyle` đang hard-code trong bootstrap và `AppConfig` để lần đổi theme không bị ghi đè.

**Token Light đã duyệt từ preview A** (đưa vào token/style tập trung khi code, không copy mã màu vào từng widget):

| Vai trò | Màu | Cách dùng |
| --- | --- | --- |
| Background | `#F4F7F5` | Nền màn hình, khoảng trống quanh các panel. |
| Surface | `#FFFFFF` | Card, input, sheet, bottom navigation. |
| Foreground | `#172B28` | Tiêu đề, nội dung và số tiền trung tính. |
| Secondary foreground | `#526964` | Nhãn phụ, thời gian, subtitle. |
| Border/divider | `#DBE6E1` | Viền thẻ và đường chia nhẹ. |
| Primary teal | `#0B7266` | CTA, tab được chọn, icon nhấn, focus và chart chính. |
| Selected/tonal teal | `#E2F3EF` | Nền option Light đang chọn, chip/segment được chọn. |
| Positive | `#08755C` | Số tiền thu; đi kèm dấu `+`/nhãn, không chỉ báo bằng màu. |
| Negative | `#B84856` | Số tiền chi hoặc hành động Sign Out; đi kèm dấu `−`/nhãn. |
| Icon well | `#E8F3EF` | Nền tròn sau icon danh sách. |

Ưu tiên cấu trúc, typography Space Grotesk + DM Sans, bo góc panel và nhịp khoảng cách của app hiện có. Preview A thể hiện cụ thể Home, Transactions và Account; các màn khác áp dụng cùng token. Shadow, shimmer, chart phụ và scrim có thể tinh chỉnh trong lúc code để đạt tương phản và phân tầng tương đương preview, nhưng không đổi hướng màu đã chốt.

### 3.3 Giao diện Account

1. Tạo widget con `lib/ui/views/account/widgets/account_theme_selector_widget.dart`; đặt trong khối Utilities, sau Categories như preview A. Hai `Pressable` icon mặt trời/mặt trăng có vùng chạm tối thiểu theo `Dimens`; option đang chọn có viền teal, nền tonal và dấu check, kèm `Semantics`/nhãn Light, Dark. Giữ text bên cạnh icon để không phải đoán nghĩa biểu tượng.
2. Dùng `BlocBuilder<AppBloc, AppState>` với `buildWhen` chỉ quan sát theme/trạng thái lưu. Chạm option đang chọn là no-op; chạm option khác gửi event lên `AppBloc`. Account không cần gọi use case hoặc lưu preference trực tiếp.
3. Cập nhật `AccountLoadingSkeletonWidget` để chiều cao skeleton khớp khối mới, tránh layout nhảy khi tải user.
4. Thêm các key hiển thị cần thiết (ví dụ `appearance`, `lightTheme`, `darkTheme`) và mô tả `@key` trong **mọi** ARB hiện có; chạy `make l10n`.

## 4. Thứ tự công việc và file dự kiến

| Bước | File chính | Kết quả |
| --- | --- | --- |
| 1. Preference | `lib/domain/entities/enum/`, `lib/domain/repositories/repository.dart`, `lib/domain/usecases/`, `lib/data/preferences/app_preferences.dart`, `lib/data/repositories/repository_impl.dart`, `lib/shared/constants/shared_preference_constants.dart` | Đọc/ghi Light/Dark cục bộ với fallback Dark. Export file public qua barrel. |
| 2. Root state | `lib/main.dart`, `lib/ui/app/walleto_application.dart`, `lib/ui/app/bloc/app_{bloc,event,state}.dart` | Nạp theme trước `runApp`, đổi theme toàn app qua `AppBloc`; không làm mất router/state khi rebuild. |
| 3. Palette | `lib/resources/styles/app_{colors,themes,text_styles,decorations}.dart` và các common widgets | Theme Light/Dark có màu semantic và các component dùng màu đúng. |
| 4. Account | `lib/ui/views/account/account_view.dart`, `widgets/account_theme_selector_widget.dart`, skeleton, `lib/ui/ui.dart`, ARB | Hai icon chọn theme, phản hồi và accessibility đầy đủ. |
| 5. Rà UI | Các view/widget đang dùng màu Dark cố định, đặc biệt Home, Transactions, Budgets, Wallets, Categories, forms, popup, bottom sheet, chart, tab bar | Không còn vùng tối cố định hay chữ mất tương phản trong Light. Chỉ đổi style; không sửa logic nghiệp vụ. |
| 6. Verify | `test/` mirror path phần thay đổi | Test persistence/fallback, AppBloc đổi theme và lỗi lưu, widget selector, khôi phục theme khi khởi động; kiểm tra tay các màn chính trên cả hai theme. |

## 5. Tiêu chí hoàn thành

- Chọn Light/Dark trên Account đổi đồng thời Account, các tab và trang con; dấu chọn luôn đúng. Chuyển tab, mở sheet/dialog hoặc logout/login không đặt lại theme.
- Đóng mở app vẫn giữ lựa chọn; cài mới hoặc preference hỏng/không tồn tại thì mở Dark; không có nháy sai theme lúc khởi động.
- Nền/chữ/icon/biểu đồ/loading/sheet/dialog/date picker/system bars đọc được ở cả hai chế độ; thao tác bằng screen reader phân biệt được hai lựa chọn.
- Light trên Home, Transactions và Account bám [preview A](previews/light-theme/option-a.png) về màu, phân tầng thẻ và trạng thái chọn; các màn khác nhất quán cùng palette. Kiểm tra tương phản chữ thường tối thiểu 4.5:1 và vùng chạm icon tối thiểu 44×44pt / 48×48dp theo platform.
- Unit/widget test bao phủ logic mới theo `CLAUDE.md`; chạy `make force_build` nếu thay freezed/DI, `make l10n`, format file Dart đã sửa và `make verify` (analyze + format_check + testing).

## 6. Quyết định đã chốt và giới hạn

- Mặc định Dark, chỉ Light/Dark, lưu theo thiết bị và giữ sau sign out. Không thêm System mode hoặc đồng bộ tài khoản trong task này.
- Light đã chốt Pearl Teal (A). Không cần chọn lại màu nền, surface, chữ hay teal trước khi code; chỉ tinh chỉnh vai trò màu chưa thể hiện trong preview theo cùng hệ token và kiểm tra tương phản.
- Preview là mockup HTML độc lập. Coding agent cần chuyển thiết kế sang Flutter theo pattern repo, không nhúng HTML hoặc lấy dữ liệu mẫu trong preview làm nội dung sản phẩm.
