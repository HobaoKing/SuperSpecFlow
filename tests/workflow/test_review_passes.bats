#!/usr/bin/env bats
load '../lib/test_helper'

# 两轮使用替身 CLI，仅检查会话、原文保留和不完整运行，不调用模型。
setup() {
  BIN="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$BIN"
  export PATH="$BIN:$PATH"
  SCRIPT="$REPO_ROOT/scripts/review-passes.py"
  TARGET="$BATS_TEST_TMPDIR/report"
  export CALL_LOG="$BATS_TEST_TMPDIR/calls"
  : > "$CALL_LOG"
  cat >"$BIN/codex" <<'STUB'
#!/usr/bin/env python3
from pathlib import Path
import json, os, sys
args = sys.argv[1:]
with open(os.environ["CALL_LOG"], "a") as log:
    print(json.dumps(args), file=log)
second = args[1] == "resume"
prompt = sys.stdin.read()
prior = "--output-schema" in args
assert prior or ("历史问题甲" not in prompt and "历史问题乙" not in prompt)
assert ("P1" in prompt) if prior else (("继续原任务" in prompt) if second else ("TICKET-1" in prompt))
assert not second or args[-2:] == ["session-A", "-"]
assert 'sandbox_mode="read-only"' in args
assert args[args.index("--model") + 1] == "test-model"
file = Path(args[args.index("-o") + 1])
print(json.dumps({"type": "thread.started", "thread_id": "session-A"}))
if second and os.environ.get("FAIL_SECOND"):
    sys.exit(1)
if prior:
    schema = json.loads(Path(args[args.index("--output-schema") + 1]).read_text())
    assert schema["required"] == ["P1", "P2"]
    receipt = '{"P1":{"status":"refuted","evidence":"文件甲第十行已检查"}}'
    if not os.environ.get("MISSING_ID"):
        receipt = receipt[:-1] + ',"P2":{"status":"unverified","evidence":"调用方未提供"}}'
    if os.environ.get("DUPLICATE_ID"):
        receipt = receipt[:-1] + ',"P1":{"status":"confirmed","evidence":"重复"}}'
    file.write_text(receipt)
else:
    file.write_bytes(("补查发现乙。\n" if second else "普通路径甲。\n\n相邻路径甲，影响不同。\n").encode())
print(json.dumps({"type": "turn.completed"}))
STUB
  chmod +x "$BIN/codex"
}

@test "最终报告逐字保留两遍输出，补查续接同一会话且保留独立问题" {
  run bash -c 'echo TICKET-1 | python3 -B "$1" --output "$2" --model test-model' _ "$SCRIPT" "$TARGET"
  [ "$status" -eq 0 ]
  run python3 - "$TARGET" <<'PY'
import json, sys
from pathlib import Path
d = Path(sys.argv[1])
first, second = (d / 'first.md').read_bytes(), (d / 'supplement.md').read_bytes()
assert first and second
assert (d / 'review.md').read_bytes() == '# 审查结果\n\n'.encode() + first + '\n\n## 补查与更正\n\n'.encode() + second
assert json.loads((d / 'run.json').read_text())['thread'] == 'session-A'
PY
  [ "$status" -eq 0 ]
}

@test "补查失败时保留第一份，重跑不会覆盖现有证据" {
  export FAIL_SECOND=1
  run bash -c 'echo TICKET-1 | python3 -B "$1" --output "$2" --model test-model' _ "$SCRIPT" "$TARGET"
  [ "$status" -ne 0 ]
  [ -s "$TARGET/first.md" ]
  [ ! -f "$TARGET/review.md" ]
  unset FAIL_SECOND
  run bash -c 'echo TICKET-1 | python3 -B "$1" --output "$2" --model test-model' _ "$SCRIPT" "$TARGET"
  [ "$status" -ne 0 ]
  [ ! -f "$TARGET/supplement.md" ]
}

@test "历史发现同会话逐项复验，保留反证、未核实和独立首轮原文" {
  run bash -c 'echo TICKET-1 | python3 -B "$1" --output "$2" --model test-model' _ "$SCRIPT" "$TARGET"
  [ "$status" -eq 0 ]
  previous="$BATS_TEST_TMPDIR/findings.json"
  echo '["历史问题甲", "历史问题乙"]' > "$previous"
  run python3 -B "$SCRIPT" --resume "$TARGET" --model test-model --check-previous "$previous"
  [ "$status" -eq 0 ]
  report="$output"
  run python3 - "$TARGET/review.md" "$report" <<'PY'
from pathlib import Path
import sys
first, verified = [Path(v).read_bytes() for v in sys.argv[1:]]
assert verified.startswith(first)
assert "已反证" in verified[len(first):].decode() and "未核实" in verified[len(first):].decode()
PY
  [ "$status" -eq 0 ]
  for invalid in MISSING_ID DUPLICATE_ID; do
    run env "$invalid=1" python3 -B "$SCRIPT" --resume "$TARGET" --model test-model --check-previous "$previous"
    [ "$status" -ne 0 ]
  done
  reports=("$TARGET"/previous-*/review.md)
  [ "${#reports[@]}" -eq 1 ]
}

@test "原生和上版原件一次交入，独立结果先保存，逐字归档两份同名文件" {
  mkdir -p "$BATS_TEST_TMPDIR/native" "$BATS_TEST_TMPDIR/upper"
  native="$BATS_TEST_TMPDIR/native/review.md"
  upper="$BATS_TEST_TMPDIR/upper/review.md"
  printf '%s\n' '1. 甲入口的请求丢失' > "$native"
  printf '%s\n' '| 乙入口 | 用户看不到结果 |' > "$upper"
  run bash -c 'echo TICKET-1 | python3 -B "$1" --output "$2" --model test-model --check-previous "$3" --check-previous "$4"' _ "$SCRIPT" "$TARGET" "$native" "$upper"
  [ "$status" -eq 0 ]
  folder="${output%/review.md}"
  cmp "$native" "$folder/sources/1-review.md"
  cmp "$upper" "$folder/sources/2-review.md"
  ! grep -q '甲入口\|乙入口' "$TARGET/review.md"
  grep -q '甲入口' "$folder/review.md"
  grep -q '乙入口' "$folder/review.md"
}

@test "新题不可复用输出目录，历史复核只在原项目且无新题时续接" {
  local previous="$BATS_TEST_TMPDIR/history.json"
  echo '["历史问题甲", "历史问题乙"]' > "$previous"
  mkdir "$BATS_TEST_TMPDIR/A" "$BATS_TEST_TMPDIR/B"
  cd "$BATS_TEST_TMPDIR/A"
  run bash -c 'echo TICKET-1 | python3 -B "$1" --output "$2" --model test-model' _ "$SCRIPT" "$TARGET"
  [ "$status" -eq 0 ]
  cd "$BATS_TEST_TMPDIR/B"
  run bash -c 'echo TICKET-2 | python3 -B "$1" --output "$2" --check-previous "$3" --model test-model' _ "$SCRIPT" "$TARGET" "$previous"
  [ "$status" -ne 0 ]
  run python3 -B "$SCRIPT" --resume "$TARGET" --check-previous "$previous" --model test-model < /dev/null
  [ "$status" -ne 0 ]
  [[ "$output" == *"原项目目录"* ]]
  cd "$BATS_TEST_TMPDIR/A"
  run bash -c 'echo TICKET-2 | python3 -B "$1" --resume "$2" --check-previous "$3" --model test-model' _ "$SCRIPT" "$TARGET" "$previous"
  [ "$status" -ne 0 ]
  [[ "$output" == *"新任务"* ]]
  [ "$(wc -l < "$CALL_LOG" | tr -d ' ')" -eq 2 ]
  run python3 -B "$SCRIPT" --resume "$TARGET" --check-previous "$previous" --model test-model < /dev/null
  [ "$status" -eq 0 ]
  [ -s "$output" ]
}

@test "任意一份历史输入无效时不创建报告也不调用模型" {
  local previous="$BATS_TEST_TMPDIR/valid.json" bad
  echo '["历史问题甲"]' > "$previous"
  echo '[]' > "$BATS_TEST_TMPDIR/empty.json"
  echo '{"broken":' > "$BATS_TEST_TMPDIR/bad.json"
  : > "$BATS_TEST_TMPDIR/empty.md"
  for bad in missing.md empty.json bad.json empty.md; do
    run bash -c 'echo TICKET-1 | python3 -B "$1" --output "$2" --model test-model --check-previous "$3" --check-previous "$4"' _ "$SCRIPT" "$TARGET" "$previous" "$BATS_TEST_TMPDIR/$bad"
    [ "$status" -ne 0 ]
    [ ! -s "$CALL_LOG" ]
    [ ! -e "$TARGET" ]
  done
}
