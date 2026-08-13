#!/bin/bash
#
# This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
#
# SPDX-FileCopyrightText: 2026 Stanford University
#
# SPDX-License-Identifier: MIT
#

set -euo pipefail

: "${DESTINATION:?DESTINATION must be set}"
: "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE must be set}"
: "${ONLY_TESTING:?ONLY_TESTING must be set}"
: "${RESULT_BUNDLE_PATH:?RESULT_BUNDLE_PATH must be set}"
: "${TEST_PRODUCTS_PATH:?TEST_PRODUCTS_PATH must be set}"

only_testing_args=()
while IFS= read -r test_identifier; do
    if [[ -n "$test_identifier" ]]; then
        only_testing_args+=("-only-testing:$test_identifier")
    fi
done <<< "$ONLY_TESTING"

if [[ ${#only_testing_args[@]} -eq 0 ]]; then
    echo "No UI tests were selected for this shard." >&2
    exit 1
fi

cd "$GITHUB_WORKSPACE"

xcodebuild \
    test-without-building \
    -testProductsPath "$TEST_PRODUCTS_PATH" \
    -destination "$DESTINATION" \
    -resultBundlePath "$RESULT_BUNDLE_PATH" \
    -enableCodeCoverage YES \
    -parallel-testing-enabled NO \
    -retry-tests-on-failure \
    -test-iterations 2 \
    -test-repetition-relaunch-enabled YES \
    "${only_testing_args[@]}" \
| xcbeautify
