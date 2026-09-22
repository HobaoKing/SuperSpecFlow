#!/usr/bin/env bats
load '../lib/test_helper'

@test "轻量会员提醒示例可直接运行公开行为测试" {
  cd "$REPO_ROOT/examples/add-membership-renewal-reminder"
  run python3 -B -m unittest discover -s tests -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"Ran 5 tests"* ]]
}
