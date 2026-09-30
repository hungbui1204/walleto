# Kế hoạch nâng Flutter 3.47.5 và Android target SDK 37

**Ngày khảo sát:** 2026-09-29  
**Trạng thái:** Kế hoạch; chưa triển khai, chưa chạy build hoặc nâng package.  
**Phạm vi:** Flutter/Dart, Android toolchain và SDK, toàn bộ dependency trực tiếp, kiểm thử hồi quy Android. Kiểm tra iOS sau khi nâng Flutter/plugin vì các package dùng chung cũng ảnh hưởng iOS.

## 1. Mục tiêu và quyết định kỹ thuật

- Ghim Flutter **3.47.5** qua FVM; dùng Dart đi kèm bản Flutter đó.
- Đặt Android `compileSdk = 37` và **`targetSdk = 37` rõ ràng**, xác nhận giá trị cuối trong merged manifest và AAB/APK. Giữ `minSdk = 24` trừ khi dependency bắt buộc nâng và đã đánh giá tác động người dùng.
- Nâng AGP từ `8.6.0` lên **9.4.0** (mục tiêu, đang hỗ trợ API 37), Gradle wrapper lên **9.6.0** và giữ JDK **17**. Nếu plugin chưa tương thích AGP 9.4, dùng **AGP 9.1.1 + Gradle 9.3.1** làm mốc tối thiểu hỗ trợ API 37, ghi rõ blocker và lên việc xử lý tiếp. Không dùng AGP 8.x cho bản bàn giao target 37: bảng tương thích chính thức hiện ghi tối thiểu 9.1.1.
- Nâng toàn bộ dependency trực tiếp lên bản stable mới nhất **tương thích đồng thời** Flutter 3.47.5, Dart đi kèm, AGP đã chọn, Android 37 và iOS đang hỗ trợ. Chốt số phiên bản sau khi chạy dependency solver và đọc changelog; tránh ghi sẵn số phiên bản chưa được kiểm chứng trong plan này.
- Giữ ba flavor `development`, `staging`, `production`, `applicationId = com.hungbui.walleto.app`, dữ liệu người dùng và luồng nghiệp vụ. Tách thay đổi toolchain, package/codegen và thay đổi hành vi Android thành các đợt dễ kiểm tra.

**Nguồn cho mốc phiên bản:** [Flutter 3.47.5](https://github.com/flutter/flutter/releases/tag/3.47.5), [AGP theo API level](https://developer.android.com/build/releases/about-agp), [AGP 9.4.0](https://developer.android.com/build/releases/agp-9-4-0-release-notes), [AGP 9.1.1](https://developer.android.com/build/releases/agp-9-1-0-release-notes).

## 2. Hiện trạng trong repo

| Thành phần | Hiện trạng | Nơi kiểm tra |
|---|---|---|
| Flutter | FVM `3.29.3`; `make sync` cũng ghim `3.29.3` | `.fvmrc`, `makefile`, `README.md`, `CLAUDE.md` |
| Dart constraint | `^3.7.2` | `pubspec.yaml` |
| Android | `compileSdk = 35`; `targetSdk = flutter.targetSdkVersion` nên giá trị thực phụ thuộc SDK Flutter đang dùng; `minSdk = 24` | `android/app/build.gradle` |
| Build | AGP `8.6.0`, Gradle `8.10.2`, Kotlin Gradle plugin `2.0.20`, Google Services `4.4.3`, Java/Kotlin target 17 | `android/settings.gradle`, `android/gradle/wrapper/gradle-wrapper.properties`, `android/app/build.gradle` |
| Native libraries | Firebase BoM `34.0.0`, `androidx.multidex:multidex:2.0.1`, `desugar_jdk_libs:2.1.5`; NDK theo `flutter.ndkVersion` | `android/app/build.gradle` |
| Android Kotlin | App đang áp dụng `kotlin-android` và `kotlinOptions` | `android/app/build.gradle` |
| Package | Tất cả dependency trong `pubspec.yaml` đang ghim phiên bản chính xác; có `pubspec.lock` | `pubspec.yaml`, `pubspec.lock` |
| iOS | Deployment target 13.0, có `Podfile.lock` | `ios/Podfile`, `ios/Podfile.lock` |
| Quy trình | `make verify` = analyze + format check + test; build Android đi qua script `tools/build_and_run_app.*` | `makefile`, `tools/` |

Repo đang có thay đổi làm việc sẵn tại `.fvmrc` và `.vscode/settings.json` lúc khảo sát. Khi triển khai phải kiểm tra và giữ lại các thay đổi đó; tài liệu này không chỉnh các file ấy.

## 3. Thứ tự công việc

### Phase 0 — Chụp baseline và lập ma trận tương thích

- [ ] Ghi `fvm flutter --version`, `fvm flutter doctor -v`, `java -version`, SDK/NDK đã cài, Gradle/JDK Android Studio sử dụng, `git status` và giá trị target thực từ bản build hiện tại.
- [ ] Chạy baseline `make verify` và build ít nhất development APK + production AAB trên trạng thái hiện tại; lưu lỗi có sẵn để phân biệt với lỗi nâng cấp. Nếu chưa có môi trường Android/signing thì ghi blocker, không đánh dấu pass.
- [ ] Chạy `fvm flutter pub outdated` sau khi có Flutter 3.47.5; lưu bảng **current / resolvable / latest** cho cả dependency trực tiếp và transitive, kiểm tra package ngừng bảo trì hoặc bị thu hồi.
- [ ] Đọc Flutter breaking changes từ **3.32, 3.35, 3.38, 3.41, 3.44, 3.47**, đặc biệt Android Gradle, Material/UI, predictive back, codegen và deprecated APIs. Lập danh sách file Dart thật sự cần sửa.
- [ ] Lập bảng mỗi Flutter plugin Android: phiên bản chọn, `minSdk`, `compileSdk`, AGP/Kotlin cần thiết, có dùng Kotlin Gradle plugin cũ hoặc AGP DSL cũ hay không, trạng thái bảo trì. Ưu tiên kiểm tra nhóm notification, Firebase, storage, auth, intent, link và media.
- [ ] Kiểm tra các manifest merge hiện tại và quyền mà plugin tự thêm vào; đối chiếu hành vi Android 15/16/17 với chức năng Walleto.

**Gate:** Có baseline, danh sách package và blocker cụ thể trước khi đổi version hàng loạt.

### Phase 1 — Nâng Flutter/Dart và công cụ dự án

- [ ] Cài Flutter 3.47.5 bằng FVM, cập nhật `.fvmrc`, `make sync`, README/quy ước version khi bước triển khai được giao; xác nhận mọi script/IDE dùng đúng SDK FVM.
- [ ] Kiểm tra và điều chỉnh `environment.sdk` trong `pubspec.yaml` theo Dart đi kèm và yêu cầu package; không nâng giới hạn tối thiểu vô cớ.
- [ ] Chạy `fvm flutter pub get`, `fvm flutter analyze --no-pub`, `fvm flutter test`; sửa lỗi Dart/Flutter mới theo từng nhóm. Chỉ dùng `dart fix` sau khi xem diff, không format toàn repo.
- [ ] Chạy lại generator sau khi đã chốt nhóm codegen: `build_runner`, `freezed`, `json_serializable`, `injectable`, `auto_route`, FlutterGen và l10n. Không sửa tay file generated; kiểm tra diff và barrel import.
- [ ] Rà `tools/gen_env/pubspec.yaml` và lock riêng vì script phụ trợ dùng Dart từ FVM.

**Gate:** Pub resolve được, analyze/test pass hoặc có danh sách lỗi được phân loại rõ trước khi chuyển sang Android build.

### Phase 2 — Nâng Android build stack

- [ ] Cài Android SDK Platform 37 và SDK Build Tools phù hợp, kiểm tra Android Studio/JDK. Tài liệu AGP 9.4 ghi tối thiểu Gradle 9.6.0, JDK 17; xác nhận NDK Flutter/plugin yêu cầu trước khi ghim NDK.
- [ ] Nâng `com.android.application` tại `android/settings.gradle`, Gradle wrapper, Google Services plugin và các native dependency (Firebase BoM, desugaring, multidex nếu vẫn cần) theo ma trận tương thích, từng nhóm để dễ truy lỗi.
- [ ] Xử lý migration **AGP 9 built-in Kotlin**: app hiện dùng `kotlin-android`. Kiểm tra trạng thái của *mọi plugin Android* trước khi bỏ Kotlin Gradle plugin/kotlinOptions và chuyển cấu hình JVM target. Flutter 3.47 có thể dùng `android.builtInKotlin=true` sau khi app và plugin tương thích; `android.newDsl=false`/`android.builtInKotlin=false` chỉ là cầu nối tạm nếu còn blocker, phải ghi việc loại bỏ.
- [ ] Rà `android/build.gradle` và `android/settings.gradle` để tránh khai báo Google Services lặp hoặc khác version; kiểm tra Gradle deprecated APIs, flavor, signing, shrinker/R8 và ProGuard trên cả debug/release.
- [ ] Chạy Gradle sync, build APK và AAB cho ba flavor. Dùng signing hiện có qua local secrets, không đưa credentials vào repo. Kiểm tra version, applicationId, Firebase config và artifact release sau minify.

**Gate:** Android build stack chạy ổn với AGP ≥ 9.1.1 trước khi đổi target SDK. [Hướng dẫn Flutter về built-in Kotlin](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers).

### Phase 3 — Nâng `compileSdk` rồi `targetSdk` lên 37

- [ ] Đặt `compileSdk = 37` trước, build và sửa lỗi compile của app/plugin/native dependency. Kiểm tra Android SDK Upgrade Assistant và merged manifest.
- [ ] Kiểm thử app hiện tại trên Android 17 **trước** khi đổi target để tách lỗi tương thích hệ điều hành khỏi lỗi do target mới.
- [ ] Đặt `targetSdk = 37` rõ ràng trong `defaultConfig` (không dựa vào `flutter.targetSdkVersion`); giữ `minSdk = 24` nếu dependency cho phép. Build lại cả ba flavor và xác nhận `targetSdkVersion=37` từ APK/AAB hoặc merged manifest.
- [ ] Đánh giá thay đổi khi đi qua API 35/36/37: edge-to-edge và insets; predictive back/dialog/bottom sheet; layout tablet/màn hình gập; permission notification và media; intent/deep link; security/network. Không thêm quyền chỉ vì Android giới thiệu quyền mới: chỉ khai báo nếu Walleto thật sự dùng chức năng đó.
- [ ] Android 17: xác minh lưu lượng LAN có hay không trước khi cân nhắc `ACCESS_LOCAL_NETWORK`; kiểm tra ECH/TLS với backend, memory limit, thư viện native/reflection, OTP/SMS (nếu có), và giới hạn màn hình lớn. Những mục không có đường code tương ứng được đánh dấu “không áp dụng” sau khi kiểm chứng.

**Gate:** Build target 37 thành công và các luồng cốt lõi hoạt động trên Android 17. [Android 17 setup](https://developer.android.com/about/versions/17/setup-sdk), [thay đổi cho mọi app](https://developer.android.com/about/versions/17/behavior-changes-all), [thay đổi khi target 37](https://developer.android.com/about/versions/17/behavior-changes-17).

## 4. Danh mục package cần nâng và kiểm tra

Phiên bản dưới đây là **phiên bản đang ghim**, không phải phiên bản đích. Ở Phase 0/1, cập nhật từng nhóm sang bản stable mới nhất mà solver giải được, ghi version cuối + lý do nếu phải giữ bản cũ. Sau mỗi nhóm: `pub get` → analyze/test → build Android khi có native plugin → smoke test chức năng liên quan. Không dùng `dependency_overrides` làm giải pháp cuối nếu chưa xử lý xung đột thực sự.

| Nhóm | Package hiện tại | Việc cần kiểm tra sau nâng |
|---|---|---|
| Firebase/notification | `firebase_core 3.14.0`, `firebase_messaging 15.2.7`, `flutter_local_notifications 19.2.1`, `flutter_app_badge 2.0.2`, `timezone 0.10.1` | Bộ FlutterFire tương thích nhau và Firebase BoM; quyền notification, channel, foreground/background/tap, badge, callback và R8. `LocalNotificationService` là điểm test chính. |
| Lưu trữ và bảo mật | `shared_preferences 2.5.3`, `flutter_secure_storage 9.2.4`, `path_provider 2.1.5`, `local_auth 2.3.0`, `local_auth_android 1.0.49`, `local_auth_darwin 1.4.3` | Dữ liệu người dùng cũ vẫn đọc được; biometric, Android Keystore/backup, migration API của federated plugins; kiểm tra minimum iOS sau nâng. |
| Platform/permission/file | `permission_handler 12.0.0+1`, `device_info_plus 11.5.0`, `package_info_plus 8.3.0`, `connectivity_plus 6.1.4`, `android_intent_plus 5.3.0`, `app_links 6.4.0`, `media_scanner 2.2.0` | Android 37 và AGP 9; merged permissions, deep links/intents, kết nối, lưu file vào Downloads. `FileUtils` đang dùng đường dẫn `/storage/emulated/0/Download` và `MediaScanner`: kiểm tra scoped storage, quyền và khả năng hoạt động trước khi quyết định giữ/thay package. |
| UI | `flutter_svg 2.2.0`, `cupertino_icons 1.0.8`, `infinite_scroll_pagination 4.1.0`, `shimmer 3.0.0`, `carousel_slider 5.1.1`, `fl_chart 1.0.0`, `lottie 3.3.1`, `flutter_screenutil 5.9.3`, `flutter_widget_from_html 0.16.0` | Breaking API/widget behavior, pagination, chart, SVG/animation, HTML và layout màn hình lớn. Với major upgrade, chỉnh đúng nơi dùng và thêm test hành vi cần thiết. |
| State/DI/routing/codegen | `flutter_bloc 9.1.1`, `get_it 8.0.3`, `injectable 2.5.0`, `auto_route 10.1.0`, `freezed_annotation 3.0.0`, `json_annotation 4.9.0` | Giữ cặp runtime/generator cùng major, DI và route generated hoạt động, navigation/predictive back không hồi quy. |
| Network/utility | `dio 5.8.0+1`, `dio_cookie_manager 3.2.0`, `cookie_jar 4.0.8`, `dartx 1.2.0`, `rxdart 0.28.0`, `async 2.12.0`, `intl 0.19.0`, `uuid 4.5.1` | HTTP/cookie/auth/token vẫn hoạt động; `intl` tương thích phiên bản do `flutter_localizations` ghim; kiểm tra package thực sự còn dùng, bỏ dependency thừa bằng diff riêng. |
| Dev/codegen/test | `bloc_test 10.0.0`, `mocktail 1.0.5`, `flutter_lints 5.0.0`, `build_runner 2.5.1`, `flutter_gen_runner 5.10.0`, `auto_route_generator 10.1.0`, `freezed 3.0.6`, `json_serializable 6.9.5`, `injectable_generator 2.7.0`, `flutter_native_splash 2.4.6`, `flutter_launcher_icons 0.14.4`, `intl_utils 2.8.10` | Solver/analyzer mới, output codegen, asset/l10n/splash/icon. Chạy lại generator có liên quan và kiểm tra generated diff; `flutter_test` theo Flutter SDK. |

**Dependency Flutter SDK:** `flutter`, `flutter_localizations`, `flutter_test` đi theo FVM 3.47.5, không đặt version riêng. **Native/transitive:** ghi version resolved trong `pubspec.lock`, `ios/Podfile.lock` và Gradle dependency graph; cập nhật native BOM/Google Services/desugar theo compatibility, không chỉ sửa `pubspec.yaml`.

## 5. Kiểm thử và nghiệm thu

- [ ] `make verify` pass; test mới/cập nhật cho logic phải đổi do breaking APIs (theo `CLAUDE.md`/`CODING_RULES.md`). Review diff generated, lockfile, manifest merge và cảnh báo Gradle.
- [ ] Build `development`, `staging`, `production` ở debug và release phù hợp; ít nhất production AAB release có R8/minify chạy và không mất class/plugin runtime.
- [ ] Kiểm tra trên Android 13/14, Android 15, 16, 17; phone và tablet/foldable; gesture navigation và 3-button navigation; cold start, resume, rotate, dark mode, keyboard/insets, offline/online.
- [ ] Smoke test đăng nhập/đăng xuất, biometric, dữ liệu ví/giao dịch/ngân sách, lưu/đọc file, API/cookie, notification FCM ở foreground/background/terminated, tap notification, badge, app link/deep link, điều hướng Back và các màn có bottom sheet.
- [ ] Kiểm tra update-in-place từ bản production hiện tại để phát hiện lỗi mất dữ liệu trong secure storage/preferences. Kiểm tra memory/crash/logcat và upload artifact qua kênh thử nghiệm nội bộ khi người phụ trách phát hành cho phép.
- [ ] Trên macOS, chạy `pod install`/iOS build và smoke test các plugin đa nền tảng sau khi nâng package; ghi rõ nếu iOS chưa được xác minh. Không tự nâng iOS deployment target nếu chưa có yêu cầu từ package hoặc phạm vi phát hành.
- [ ] Xác nhận lại version Flutter, AGP, Gradle, `compileSdk`, `targetSdk`, Dart constraint, lockfiles và tài liệu setup trước khi đóng việc.

**Definition of Done:** Flutter 3.47.5 được ghim thống nhất; Android release AAB xác nhận compile/target 37; AGP ≥ 9.1.1 theo ma trận API 37; dependency trực tiếp có version cuối và lý do cho mọi ngoại lệ; `make verify` và build các flavor pass; smoke test Android 17 cùng update-in-place pass; không có secrets hoặc thay đổi applicationId/minSdk ngoài quyết định đã ghi.

## 6. Điểm dễ phát sinh blocker

1. **AGP 9/Kotlin:** một plugin cũ có thể vẫn áp dụng KGP hoặc AGP DSL cũ. Xác định plugin bằng Gradle error/ma trận, nâng hoặc thay thế đúng package; chỉ dùng compatibility flags tạm thời với việc theo dõi loại bỏ.
2. **Package ít bảo trì:** `media_scanner`, `flutter_app_badge` và các plugin native khác cần kiểm tra lịch sử release/AGP 9 trước khi chốt; nếu không tương thích, đề xuất phương án thay thế kèm test chức năng.
3. **Storage/downloads:** đường dẫn Downloads hard-code có thể không phù hợp trên các Android mới; cần test thật trên API 35–37, không kết luận chỉ từ việc compile pass.
4. **Release shrinker:** AGP/R8 mới có thể làm debug pass nhưng release lỗi; production AAB là gate bắt buộc.
5. **Flavor/signing:** ba flavor dùng chung `applicationId`; kiểm tra cấu hình Firebase, deep links và ký release trên artifact thực, giữ secrets ở nơi hiện có.

## 7. Tài liệu gốc để đối chiếu khi thực hiện

- [Flutter 3.47.5 release](https://github.com/flutter/flutter/releases/tag/3.47.5) · [Flutter breaking changes](https://docs.flutter.dev/release/breaking-changes) · [Flutter built-in Kotlin migration](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers).
- [AGP/API compatibility](https://developer.android.com/build/releases/about-agp) · [AGP 9.4 compatibility](https://developer.android.com/build/releases/agp-9-4-0-release-notes) · [AGP 9.1.1 compatibility](https://developer.android.com/build/releases/agp-9-1-0-release-notes).
- [Android 17 SDK setup](https://developer.android.com/about/versions/17/setup-sdk) · [Android 15 target changes](https://developer.android.com/about/versions/15/behavior-changes-15) · [Android 16 target changes](https://developer.android.com/about/versions/16/behavior-changes-16) · [Android 17 changes for all apps](https://developer.android.com/about/versions/17/behavior-changes-all) · [Android 17 target 37 changes](https://developer.android.com/about/versions/17/behavior-changes-17).
