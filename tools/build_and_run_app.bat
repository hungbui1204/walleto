@echo off
setlocal enabledelayedexpansion

:: Get the parent directory of the script
for %%I in ("%~dp0.") do set "parent_path=%%~fI"
set "root_project_path=%parent_path%\.."
set "env_path=%root_project_path%\env\%1.json"

set "dart_define="

:: Read JSON file and construct dart-define arguments
for /f "tokens=1,* delims=:" %%A in ('type "%env_path%"') do (
    set "key=%%A"
    set "value=%%B"

    rem Remove leading and trailing whitespaces and quotes from key and value
    for /f "tokens=*" %%C in ("!key!") do set "key=%%~C"
    for /f "tokens=*" %%D in ("!value!") do set "value=%%~D"

    rem Check if key and value are not empty
    if not "!key!"=="" if not "!value!"=="" (
        rem Remove trailing quotation mark and comma except for the last key-value pair
        if "!value:~-1!"=="," set "value=!value:~0,-2!" (
            set "dart_define=!dart_define! --dart-define=!key!=!value!"
        )
    )
)

cd /d "%root_project_path%"

:: Usage:
:: %1: develop
:: %2: build/run
:: %3 (optional): apk/appbundle/ios/ipa
:: %4 (optional): --obfuscate 
:: %5 (optional): --split-debug-info=./debug
:: %6 (optional): --export-options-plist=ios/exportOptions.plist
set "cmd=fvm flutter %2 %3 %4 %5 %6 -t lib\main.dart --flavor %1 !dart_define!"
echo %cmd%
%cmd%

endlocal
