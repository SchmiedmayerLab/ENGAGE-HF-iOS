#!/bin/bash
#
# This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
#
# SPDX-FileCopyrightText: 2026 Stanford University
#
# SPDX-License-Identifier: MIT
#

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <shard-manifest> <test-products-path> <destination>" >&2
    exit 2
fi

manifest_path="$1"
test_products_path="$2"
destination="$3"

: "${RUNNER_TEMP:?RUNNER_TEMP must be set}"

jq -e '
    .shards as $shards
    | ($shards | length) == 4
    and ($shards | map(.name) | unique | length) == 4
    and ($shards | map(.shard) | unique | length) == 4
    and all(
        $shards[];
        (.name | type == "string" and length > 0)
        and (.shard | type == "string" and length > 0)
        and (.tests | type == "array" and length > 0)
        and all(.tests[]; type == "string" and length > 0)
    )
' "$manifest_path" > /dev/null

validation_dir="$(mktemp -d "$RUNNER_TEMP/engagehf-ui-shards.XXXXXX")"
trap 'rm -rf "$validation_dir"' EXIT

enumerated_tests="$validation_dir/enumerated-tests.json"
normalized_tests="$validation_dir/normalized-tests.txt"
selectors="$validation_dir/selectors.txt"

xcodebuild \
    test-without-building \
    -testProductsPath "$test_products_path" \
    -destination "$destination" \
    -enumerate-tests \
    -test-enumeration-style flat \
    -test-enumeration-format json \
    -test-enumeration-output-path "$enumerated_tests"

jq -e '(.errors | length) == 0' "$enumerated_tests" > /dev/null
jq -r '
    .values[].enabledTests[].identifier
    | select(endswith("()"))
    | sub("\\(\\)$"; "")
' "$enumerated_tests" | sort -u > "$normalized_tests"
jq -r '.shards[].tests[]' "$manifest_path" | sort > "$selectors"

validation_failed=false

while IFS= read -r test_identifier; do
    match_count=0
    while IFS= read -r selector; do
        if [[ "$test_identifier" == "$selector" || "$test_identifier" == "$selector/"* ]]; then
            match_count=$((match_count + 1))
        fi
    done < "$selectors"
    if [[ $match_count -ne 1 ]]; then
        echo "Expected exactly one shard selector for $test_identifier, found $match_count." >&2
        validation_failed=true
    fi
done < "$normalized_tests"

while IFS= read -r selector; do
    has_match=false
    while IFS= read -r test_identifier; do
        if [[ "$test_identifier" == "$selector" || "$test_identifier" == "$selector/"* ]]; then
            has_match=true
            break
        fi
    done < "$normalized_tests"
    if [[ "$has_match" == false ]]; then
        echo "Shard selector does not match an enabled UI test: $selector" >&2
        validation_failed=true
    fi
done < "$selectors"

if [[ "$validation_failed" == true ]]; then
    exit 1
fi

echo "Validated $(wc -l < "$normalized_tests" | tr -d ' ') enabled UI tests across four shards."
