#!/usr/bin/env bats

load '../lib/test_helper'

@test "scripts/test.sh lists nested bats files recursively" {
  run "$REPO_ROOT/scripts/test.sh" --list
  [ "$status" -eq 0 ]
  [[ "$output" == *"tests/install/test_install_global.bats"* ]]
  [[ "$output" == *"tests/verification/test_cross_agent_verification_contract.bats"* ]]
}

@test "scripts/test.sh lists explicit file args in caller order without duplicates" {
  run "$REPO_ROOT/scripts/test.sh" --list \
    tests/version/test_version_contract.bats \
    tests/smoke/test_recursive_test_runner.bats \
    tests/version/test_version_contract.bats

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" = "tests/version/test_version_contract.bats" ]
  [ "${lines[1]}" = "tests/smoke/test_recursive_test_runner.bats" ]
}

@test "scripts/test.sh supports fixed-substring filters" {
  run "$REPO_ROOT/scripts/test.sh" --list --filter test_version_contract.bats

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [ "${lines[0]}" = "tests/version/test_version_contract.bats" ]
}

@test "scripts/test.sh unions explicit files and filters" {
  run "$REPO_ROOT/scripts/test.sh" --list \
    tests/smoke/test_recursive_test_runner.bats \
    --filter test_version_contract.bats

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" = "tests/smoke/test_recursive_test_runner.bats" ]
  [ "${lines[1]}" = "tests/version/test_version_contract.bats" ]
}

@test "scripts/test.sh rejects filters with no matches" {
  run "$REPO_ROOT/scripts/test.sh" --list --filter no-such-bats-test-pattern

  [ "$status" -eq 1 ]
  [[ "$output" == *"no bats tests matched selection"* ]]
}

@test "scripts/test.sh rejects missing file args" {
  run "$REPO_ROOT/scripts/test.sh" --list tests/smoke/no-such-file.bats

  [ "$status" -eq 1 ]
  [[ "$output" == *"missing bats test file"* ]]
}

@test "scripts/test.sh rejects non-bats file args" {
  run "$REPO_ROOT/scripts/test.sh" --list README.md

  [ "$status" -eq 1 ]
  [[ "$output" == *"test file must be under tests/ and end with .bats"* ]]
}
