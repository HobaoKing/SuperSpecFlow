#!/usr/bin/env bats

load '../lib/test_helper'

@test "scripts/test.sh lists nested bats files recursively" {
  run "$REPO_ROOT/scripts/test.sh" --list
  [ "$status" -eq 0 ]
  [[ "$output" == *"tests/install/test_install_global.bats"* ]]
  [[ "$output" == *"tests/verification/test_cross_agent_verification_contract.bats"* ]]
}
