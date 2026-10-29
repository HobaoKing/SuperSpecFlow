#!/usr/bin/env bats
load '../lib/test_helper'

# 只生成本地离线输入，不调用模型；用同一 Python 与隔离临时目录检验对照可比性。
setup() {
  PYTHON="$(ssf_python_cmd)"
  CREATOR="$REPO_ROOT/tests/behavior/create-fixtures.py"
}

# 直接运行评估器与证据记录的故障变异，不把模型执行纳入每次 CI。
@test "评估设施拒绝空跑残缺篡改和丢失证据" {
  run "$PYTHON" -B -m unittest discover -s "$REPO_ROOT/tests/behavior" -p test_evaluation.py -v
  [ "$status" -eq 0 ]
}

# 中文含糊表达覆盖七入口、组合和负例；答案只留给评估者，输入对照仍相同。
@test "中文触发变体保留原任务约束而不泄漏预期入口" {
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/chinese" --case zh-fix --case zh-git --case zh-release-assess --case zh-wording >/dev/null
  run "$PYTHON" -B - "$BATS_TEST_TMPDIR/chinese" <<'PY'
import json
import sys
from pathlib import Path
root = Path(sys.argv[1])
requests = json.loads((root / 'requests.json').read_text())
assert all('ssf-' not in request for request in requests.values())
assert not (root / 'chinese-triggers.json').exists()
assert '>= 0' in (root / 'zh-fix/quota.py').read_text()
assert '> 0' in (root / 'zh-git/quota.py').read_text()
assert (root / 'zh-git/notes.txt').read_text() == 'another task staged change\n'
assert json.loads((root / 'zh-release-assess/runtime/status.json').read_text())['version'] == 'release-41'
assert not (root / 'zh-release-assess/runtime/calls.log').exists()
PY
  [ "$status" -eq 0 ]
}

# 专项资料和未提交候选在有无技能组保持相同，避免评分说明或其他组产物泄漏。
@test "专项对照包含相同契约故障候选且不包含评估者核验器" {
  local case_args=(--case wire-api --case payment-retry --case review-gates --case review-state-kinds --case queue-worker --case backfill-ledger --case observability --case overload-recovery --case flaky-refresh)
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/with" "${case_args[@]}" >/dev/null
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/without" --without-skills "${case_args[@]}" >/dev/null
  run env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 "$PYTHON" -B - "$BATS_TEST_TMPDIR/with" "$BATS_TEST_TMPDIR/without" <<'PY'
import json
import subprocess
import sys
from pathlib import Path
left, right = map(Path, sys.argv[1:])
assert (left / 'requests.json').read_bytes() == (right / 'requests.json').read_bytes()
for case in json.loads((left / 'requests.json').read_text()):
    projects = [root / case for root in (left, right)]
    snapshots = [{str(p.relative_to(project)): p.read_bytes() for p in project.rglob('*')
                  if p.is_file() and '.git' not in p.relative_to(project).parts} for project in projects]
    assert snapshots[0] == snapshots[1], case
    assert not any('check-specialist' in name or name.startswith('changes/') for name in snapshots[0])
    assert all((project / 'notes.txt').read_text() == 'another task: keep this draft\n' for project in projects)
    assert subprocess.check_output(['git', '-C', str(projects[0]), 'diff']) == subprocess.check_output(['git', '-C', str(projects[1]), 'diff'])
assert '|| true' in (left / 'review-gates/ci.sh').read_text()
assert '@unittest.skip' in (left / 'review-gates/test_recovery.py').read_text()
assert '"deactivate": _drop_target' in (left / 'review-state-kinds/approvals.py').read_text()
assert subprocess.run([sys.executable, '-B', '-m', 'unittest', '-v'], cwd=left / 'review-state-kinds', capture_output=True).returncode == 0
PY
  [ "$status" -eq 0 ]
}

# 检查实际错误可复现，原程序的正常路径也须保留；这些结果不代表模型效果。
@test "专项原始项目存在传输重试排队对账缺陷" {
  run "$PYTHON" -B - "$REPO_ROOT" <<'PY'
import json
import subprocess
import sys
from pathlib import Path
root = Path(sys.argv[1])
expected = {
    'wire-api': ('error/v2', 'v1/42/ready'),
    'payment-retry': ('six-day-replay', 'tenant-isolation'),
    'queue-worker': ('steady/tail', 'steady/identity'),
    'backfill-ledger': ('historical-reconcile', 'history-isolation'),
    'observability': ('failure-counters', 'success-results'),
    'overload-recovery': ('drained', 'tick-budget'),
    'flaky-refresh': ('atomic-first-publish', 'initial-snapshot'),
}
for case, (failure, control) in expected.items():
    outcome = subprocess.run([sys.executable, '-B', str(root / 'tests/behavior/check-specialist.py'), case,
                              str(root / 'tests/behavior/specialist-fixtures' / case)], capture_output=True, text=True)
    result = json.loads(outcome.stdout)
    assert outcome.returncode == 1 and result['passed'] is False, case
    assert 'checker-error' not in result['checks'], result
    assert result['checks'][failure]['passed'] is False, result
    assert result['checks'][control]['passed'] is True, result
PY
  [ "$status" -eq 0 ]
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

# 比较原始内容和工作区差异，防止对照只保留相同文件名却丢失用户已有工作。
@test "缺口场景在有无技能组保留相同输入及未提交状态" {
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/with" --case search-contract --case resume-work --case qa-evidence >/dev/null
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/without" --without-skills --case search-contract --case resume-work --case qa-evidence >/dev/null
  run env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 "$PYTHON" -B - "$BATS_TEST_TMPDIR/with" "$BATS_TEST_TMPDIR/without" <<'PY'
import json
import subprocess
import sys
from pathlib import Path

left, right = map(Path, sys.argv[1:])
assert (left / 'requests.json').read_bytes() == (right / 'requests.json').read_bytes()
for case in json.loads((left / 'requests.json').read_text()):
    # 比较所有项目文件，不把 Git 内部的随机时间戳当输入差异。
    projects = [root / case for root in (left, right)]
    contents = [{str(p.relative_to(root)): p.read_bytes() for p in root.rglob('*')
                 if p.is_file() and '.git' not in p.relative_to(root).parts}
                for root in projects]
    assert contents[0] == contents[1], case
    diffs = [subprocess.check_output(['git', '-C', str(root), 'diff']) for root in projects]
    assert diffs[0] == diffs[1], case
assert '保存到设备' in (left / 'resume-work/quota.py').read_text()
assert 'another task' in (left / 'resume-work/notes.txt').read_text()
PY
  [ "$status" -eq 0 ]
}

# 验证场景包含真正的漏改和过期证据；这些断言只验证夹具，不代替模型演练。
@test "缺口场景可观察晚出现的消费者恢复故障和证据冲突" {
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/cases" --case search-contract --case resume-work --case qa-evidence >/dev/null
  [ ! -e "$BATS_TEST_TMPDIR/cases/qa-evidence/quota.py" ]
  [ ! -e "$BATS_TEST_TMPDIR/cases/qa-evidence/test_quota.py" ]
  [ ! -e "$BATS_TEST_TMPDIR/cases/search-contract/quota.py" ]
  run env PYTHONPATH="$BATS_TEST_TMPDIR/cases/search-contract" "$PYTHON" -B -c '
import readers
assert readers.notification("ready") is True
assert readers.notification("ready_cached") is False
assert readers.legacy_payload("ready_cached") == {"status": "pending"}
'
  [ "$status" -eq 0 ]
  run env PYTHONPATH="$BATS_TEST_TMPDIR/cases/resume-work" "$PYTHON" -B -c '
from quota import Account, retry_download
# 首次和重试共用的实现仍然泄漏额度，与旧计划中的完成记录不一致。
def fail_save():
    raise OSError("disk full")
account = Account(1)
try:
    retry_download(account, fail_save)
except OSError:
    pass
else:
    raise AssertionError("expected save failure")
assert account.remaining == 0
'
  [ "$status" -eq 0 ]
  run "$PYTHON" -B -c '
import json,sys
from pathlib import Path
record=json.loads(Path(sys.argv[1]).read_text())
assert record["save_response"]["http_status"] == 200
assert record["save_response"]["body"]["ok"] is False
assert record["readback"]["body"]["download_enabled"] is False
assert record["screenshot_index"]["revision"] != record["revision"]
assert record["screenshot_index"]["available"] is False
' "$BATS_TEST_TMPDIR/cases/qa-evidence/evidence/records.json"
  [ "$status" -eq 0 ]
}

# 复杂场景仍必须保持原始输入相同，并通过公开入口确认压力数据没有吞掉待修行为。
@test "复杂场景输入可比且包含分散渠道与真实交接起点" {
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/with" --case search-large --case resume-handoff --case qa-browser >/dev/null
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/without" --without-skills --case search-large --case resume-handoff --case qa-browser >/dev/null
  run "$PYTHON" -B - "$BATS_TEST_TMPDIR/with" "$BATS_TEST_TMPDIR/without" <<'PY'
import json
import sys
from pathlib import Path
left, right = map(Path, sys.argv[1:])
assert (left / 'requests.json').read_bytes() == (right / 'requests.json').read_bytes()
for case in json.loads((left / 'requests.json').read_text()):
    projects = [root / case for root in (left, right)]
    contents = [{str(p.relative_to(root)): p.read_bytes() for p in root.rglob('*')
                 if p.is_file() and '.git' not in p.relative_to(root).parts}
                for root in projects]
    assert contents[0] == contents[1], case
project = left / 'search-large'
sys.path.insert(0, str(project))
import api
import audit
channels = json.loads((project / 'channels.json').read_text())
assert len(channels) == 24
assert len(list((project / 'archive').glob('*.txt'))) == 600
for channel in channels:
    assert api.download(channel, 'ready') is True
    assert api.download(channel, 'ready_cached') is False
assert api.export_v1('ready_cached') == {'status': 'pending'}
assert audit.complete('ready_cached') is False
assert not (left / 'resume-handoff/notes/download-plan.md').exists()
assert not (left / 'qa-browser/quota.py').exists()
PY
  [ "$status" -eq 0 ]
}

# 真正启动本测试拥有的随机回环服务，验证权限拒绝无副作用和成员持久化；不冒充浏览器测试。
@test "浏览器夹具服务保留业务拒绝和独立账号状态" {
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/browser" --case qa-browser >/dev/null
  run "$PYTHON" -B - "$BATS_TEST_TMPDIR/browser/qa-browser" <<'PY'
import json
import subprocess
import sys
import urllib.request
from pathlib import Path
project = Path(sys.argv[1])
process = subprocess.Popen([sys.executable, '-B', 'server.py'], cwd=project, stdout=subprocess.PIPE, text=True)
try:
    url = process.stdout.readline().strip()
    assert url.startswith('http://127.0.0.1:')
    for account, ok in [('restricted', False), ('member', True)]:
        request = urllib.request.Request(url + 'api/settings',
            data=json.dumps({'account': account, 'enabled': True}).encode(),
            headers={'Content-Type': 'application/json'})
        with urllib.request.urlopen(request, timeout=5) as response:
            assert response.status == 200
            assert json.load(response)['ok'] is ok
        with urllib.request.urlopen(url + 'api/settings?account=' + account, timeout=5) as response:
            assert json.load(response)['enabled'] is ok
    assert json.loads((project / 'runtime/state.json').read_text()) == {'restricted': False, 'member': True}
finally:
    process.terminate()
    process.wait(timeout=5)
PY
  [ "$status" -eq 0 ]
}

# 新方法只改变技能输入；确认实际运行成本、业务错误及只讨论场景原本就存在，不运行模型。
@test "性能与语义场景保持对照输入且公开行为可观测" {
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/with" --case performance-list --case business-cancel --case business-discuss >/dev/null
  "$PYTHON" -B "$CREATOR" "$BATS_TEST_TMPDIR/without" --without-skills --case performance-list --case business-cancel --case business-discuss >/dev/null
  run "$PYTHON" -B - "$BATS_TEST_TMPDIR/with" "$BATS_TEST_TMPDIR/without" <<'PY'
import json
import sys
from pathlib import Path
left, right = map(Path, sys.argv[1:])
assert (left / 'requests.json').read_bytes() == (right / 'requests.json').read_bytes()
for case in json.loads((left / 'requests.json').read_text()):
    projects = [root / case for root in (left, right)]
    contents = [{str(p.relative_to(root)): p.read_bytes() for p in root.rglob('*')
                 if p.is_file() and '.git' not in p.relative_to(root).parts}
                for root in projects]
    assert contents[0] == contents[1], case
sys.path.insert(0, str(left / 'performance-list'))
from listing import list_documents
from store import Store
store = Store()
try:
    assert list_documents(store, 'alpha', [2, 1, 2, 7, 999]) == [
        {'id': 2, 'title': 'alpha-2'}, {'id': 1, 'title': 'alpha-1'}, {'id': 2, 'title': 'alpha-2'}]
    assert store.query_count == 5
    store.set_visible('alpha', 1, False)
    assert list_documents(store, 'alpha', [1]) == []
finally:
    store.close()
sys.path.insert(0, str(left / 'business-cancel'))
from orders import cancel_from_list, can_dispatch, payload_v1
order = {'status': 'open', 'payment': 'paid', 'refund_calls': 0}
assert cancel_from_list(order) is True
assert order['payment'] == 'refunded' and order['refund_calls'] == 1
assert can_dispatch(order) is True
assert payload_v1(order)['status'] == 'cancelled'
sys.path.insert(0, str(left / 'business-discuss'))
from access import was_opened, can_access
account = {'opened_at': 1, 'active': True, 'expires_at': 10}
assert was_opened(account) is True
assert can_access(account, 10) is False
assert not (left / 'business-discuss/quota.py').exists()
PY
  [ "$status" -eq 0 ]
}
