ifeq ($(OS),Windows_NT)
    BUILD_CMD=.\build_and_run_app.bat
else
    BUILD_CMD=./build_and_run_app.sh
endif

update_app_icon:
	fvm dart run flutter_launcher_icons:main
update_splash:
	fvm dart run flutter_native_splash:create
remove_splash:
	fvm dart run flutter_native_splash:remove

l10n:
	fvm dart run intl_utils:generate

gen_assets:
	fluttergen

test:
	fvm flutter test

clean:
	fvm flutter clean

pub_get:
	fvm flutter pub get

pub_upgrade:
	fvm flutter pub upgrade

dart_fix:
	fvm dart fix --apply

analyze:
	fvm flutter analyze --no-pub --suppress-analytics

gen_env:
	fvm dart pub get --directory=tools/gen_env
	fvm dart run tools/gen_env/lib/main.dart

sync:
	fvm use 3.29.3 -f
	fvm flutter pub get
	fluttergen
	fvm dart run intl_utils:generate
	fvm dart run build_runner build --delete-conflicting-outputs

testing:
	fvm flutter test

build_all:
	fvm dart run build_runner build
force_build:
	fvm dart run build_runner build --delete-conflicting-outputs

watch:
	fvm dart run build_runner watch
force_watch:
	fvm dart run build_runner watch --delete-conflicting-outputs

run_dev:
	cd tools && $(BUILD_CMD) development run
run_prod:
	cd tools && $(BUILD_CMD) production run

build_dev_apk:
	cd tools && $(BUILD_CMD) development build apk 
build_staging_apk:
	 cd tools && $(BUILD_CMD) staging build apk --obfuscate --split-debug-info=./debug
build_prod_apk:
	 cd tools && $(BUILD_CMD) production build apk --obfuscate --split-debug-info=./debug
build_dev_bundle:
	cd tools && $(BUILD_CMD) development build appbundle
build_staging_bundle:
	cd tools && $(BUILD_CMD) staging build appbundle
build_prod_bundle:
	cd tools && $(BUILD_CMD) production build appbundle

build_dev_ios:
	cd tools && chmod +x ./build_and_run_app.sh && $(BUILD_CMD) development build ios
build_staging_ios:
	cd tools && chmod +x ./build_and_run_app.sh && $(BUILD_CMD) staging build ios --obfuscate --split-debug-info=./debug
build_prod_ios:
	cd tools && chmod +x ./build_and_run_app.sh && $(BUILD_CMD) production build ios --obfuscate --split-debug-info=./debug
build_dev_ipa:
	cd tools && chmod +x ./build_and_run_app.sh && $(BUILD_CMD) development build ipa --export-options-plist=ios/ExportOptions.plist
build_staging_ipa:
	cd tools && chmod +x ./build_and_run_app.sh && $(BUILD_CMD) staging build ipa --obfuscate --split-debug-info=./debug --export-options-plist=ios/ExportOptions.plist
build_prod_ipa:
	cd tools && chmod +x ./build_and_run_app.sh && $(BUILD_CMD) production build ipa --obfuscate --split-debug-info=./debug --export-options-plist=ios/ExportOptions.plist
