#!/usr/bin/env bats
load '../lib/test_helper'

# 只生成本地离线输入，不调用模型；用同一 Python 与隔离临时目录检验对照可比性。
setup() {
  PYTHON="$(ssf_python_cmd)"
  CREATOR="$REPO_ROOT/tests/behavior/create-fixtures.py"
}

@test "有无 skills 的对照保留相同请求与项目文件" {
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/with" --case build --case recovery-build >/dev/null
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/without" --without-skills --case build --case recovery-build >/dev/null
  cmp "$BATS_TEST_TMPDIR/with/requests.json" "$BATS_TEST_TMPDIR/without/requests.json"
  for scenario in build recovery-build; do
    for file in AGENTS.md quota.py test_quota.py notes.txt; do
      cmp "$BATS_TEST_TMPDIR/with/$scenario/$file" "$BATS_TEST_TMPDIR/without/$scenario/$file"
    done
  done
  [ ! -e "$BATS_TEST_TMPDIR/without/skills" ]
  [ -s "$BATS_TEST_TMPDIR/with/skills/ssf-build/SKILL.md" ]
  run "$PYTHON" -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d["model_execution"] == "not_run"; assert d["skills_sha256"] is None' "$BATS_TEST_TMPDIR/without/fixture.json"
  [ "$status" -eq 0 ]
}

@test "旧版 skills 对照摘要随内容变化且不改变项目输入" {
  cp -R "$REPO_ROOT/skills" "$BATS_TEST_TMPDIR/old-skills"
  printf '\nprevious instructions\n' >> "$BATS_TEST_TMPDIR/old-skills/ssf-build/SKILL.md"
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/old" --skills-from "$BATS_TEST_TMPDIR/old-skills" --case review >/dev/null
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/current" --case review >/dev/null
  cmp "$BATS_TEST_TMPDIR/old/review/quota.py" "$BATS_TEST_TMPDIR/current/review/quota.py"
  cmp "$BATS_TEST_TMPDIR/old-skills/ssf-build/SKILL.md" "$BATS_TEST_TMPDIR/old/skills/ssf-build/SKILL.md"
  run "$PYTHON" -c 'import json,sys; a,b=[json.load(open(p)) for p in sys.argv[1:]]; assert a["skills_sha256"] != b["skills_sha256"]' "$BATS_TEST_TMPDIR/old/fixture.json" "$BATS_TEST_TMPDIR/current/fixture.json"
  [ "$status" -eq 0 ]
}

@test "fixture 生成器拒绝已有目录无效场景与递归输出" {
  mkdir "$BATS_TEST_TMPDIR/existing"
  printf 'keep\n' > "$BATS_TEST_TMPDIR/existing/user.txt"
  run "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/existing"
  [ "$status" -ne 0 ]
  [ "$(cat "$BATS_TEST_TMPDIR/existing/user.txt")" = keep ]
  run "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/invalid" --case unknown
  [ "$status" -ne 0 ]
  [ ! -e "$BATS_TEST_TMPDIR/invalid" ]
  run "$PYTHON" -B "$CREATOR" "$REPO_ROOT/skills/recursive-fixture"
  [ "$status" -ne 0 ]
  [ ! -e "$REPO_ROOT/skills/recursive-fixture" ]
}

@test "默认场景包含普通问答简短交付与真实的恢复缺陷" {
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/default" >/dev/null
  [ -d "$BATS_TEST_TMPDIR/default/plain-question" ]
  [ -d "$BATS_TEST_TMPDIR/default/terse-build" ]
  run env PYTHONPATH="$BATS_TEST_TMPDIR/default/recovery-build" "$PYTHON" -B -c '
from quota import Account, retry_download
# 故障发生在保存操作，确认原异常仍存在但额度泄漏，给模型留下真实待修复行为。
def fail_save():
    raise OSError("disk full")
account = Account(1)
try:
    account.download(fail_save)
except OSError:
    pass
else:
    raise AssertionError("fixture should reproduce failure")
assert account.remaining == 0
assert retry_download(account, lambda: None) is False
'
  [ "$status" -eq 0 ]
}
