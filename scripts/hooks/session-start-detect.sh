#!/usr/bin/env bash
# SuperSpecFlow Claude Code SessionStart hook (C3 加成路径)
# 优先从 stdin JSON 的 cwd 字段解析项目根；回落 $CLAUDE_PROJECT_DIR；最后回落 $PWD。
# 输出符合官方 SessionStart hook 协议的 JSON，additionalContext 字段携带 <ssf-status> 标签。
# 任何错误一律退化为 disabled 版本的合法 JSON，绝不向上抛异常。

set +e

# 输出符合官方 SessionStart hook 协议的 JSON，并在 additionalContext 中携带 <ssf-status> 标签，最后以退出码 0 终止脚本。
# 输入：$1 状态字符串，取值为 "enabled" 或 "disabled"；输出：单行 JSON 写入 stdout。
emit() {
  # 单行 JSON，标签作为 additionalContext 字符串内容。
  local status="$1"   # enabled | disabled
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"<ssf-status>%s</ssf-status>"}}\n' "$status"
  exit 0
}

# 探测系统中能够正常执行代码的 python3 可执行文件，规避损坏的 pyenv shim 或架构不兼容问题。
# 输入：无；输出：输出可用的 python3 路径或命令名（stdout）；若未找到可用解释器则返回 1。
find_python3() {
  local candidate
  for candidate in /usr/bin/python3 python3; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'exit(0)' >/dev/null 2>&1; then
      printf '%s' "$candidate"
      return 0
    fi
  done
  return 1
}

trap 'emit disabled' ERR

# 优先级 1：stdin JSON 的 cwd（Claude Code 注入；最权威）
# 用 python3 解析顶层 cwd，避免 sed 贪婪匹配误取嵌套 cwd 字段或 JSON 转义截断。
# 若 python3 不存在则跳过 stdin 解析，进入 env/PWD fallback。
stdin_cwd=""
py_bin="$(find_python3 2>/dev/null || true)"
if [ ! -t 0 ] && [ -n "$py_bin" ]; then
  stdin_cwd="$("$py_bin" -c 'import json,sys
try:
    data = json.load(sys.stdin)
    if isinstance(data, dict):
        v = data.get("cwd")
        if isinstance(v, str):
            print(v)
except Exception:
    pass' 2>/dev/null)"
elif [ ! -t 0 ]; then
  # python3 缺失时丢弃 stdin，避免阻塞
  cat >/dev/null 2>&1
fi

# 优先级 2/3：环境变量 / PWD
project_dir="${stdin_cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}"

if [ ! -d "$project_dir" ]; then
  emit disabled
fi

# 默认全局开启；若项目根目录存在 .superspecflow/disabled 文件，则显式禁用。
if [ -f "$project_dir/.superspecflow/disabled" ]; then
  emit disabled
fi

emit enabled
