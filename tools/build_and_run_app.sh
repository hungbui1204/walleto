#!/bin/bash
parent_path=$( cd "$(dirname "$0")" ; pwd -P )
root_project_path="$(dirname "$parent_path")"
env_path="$root_project_path/env/$1.json"

dart_define=""

# Read JSON file and construct dart-define arguments
while IFS=":" read -r key value; do
    # Remove leading and trailing whitespaces
    key=$(echo $key | tr -d '[:space:]' | tr -d '"')
    value=$(echo $value | tr -d '[:space:]' | tr -d '",')

    # Check if key and value are not empty
    if [[ ! -z "$key" && ! -z "$value" ]]; then
        dart_define+="--dart-define=$key=$value "
    fi
done < "$env_path"

debug=""

# if [ "$1" == "development" ]; then
#     debug="--debug"
# fi

cd ..

# $1: development/staging/production
# $2: build/run
# $3: apk/appbundle/ios/ipa
# $4 (optional): --obfuscate
# $5 (optional): --split-debug-info=./debug
# $6 (optional): --export-options-plist=ios/exportOptions.plist
cmd="fvm flutter $2 $3 $debug $4 $5 $6 -t lib/main.dart --flavor $1 $dart_define"
echo $cmd
eval $cmd
