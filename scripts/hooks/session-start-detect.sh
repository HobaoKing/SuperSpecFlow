#!/usr/bin/env bash
# SuperSpecFlow Claude Code SessionStart hook (C3 加成路径)
# 优先从 stdin JSON 的 cwd 字段解析项目根；回落 $CLAUDE_PROJECT_DIR；最后回落 $PWD。
# 输出符合官方 SessionStart hook 协议的 JSON，additionalContext 字段携带 <ssf-status> 标签。
# 任何错误一律退化为 disabled 版本的合法 JSON，绝不向上抛异常。

set +e

emit() {
  # 单行 JSON，标签作为 additionalContext 字符串内容。
  local status="$1"   # enabled | disabled
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"<ssf-status>%s</ssf-status>"}}\n' "$status"
  exit 0
}

trap 'emit disabled' ERR

# 优先级 1：stdin JSON 的 cwd（Claude Code 注入；最权威）
# 用 python3 解析顶层 cwd，避免 sed 贪婪匹配误取嵌套 cwd 字段或 JSON 转义截断。
# 若 python3 不存在则跳过 stdin 解析，进入 env/PWD fallback。
stdin_cwd=""
if [ ! -t 0 ] && command -v python3 >/dev/null 2>&1; then
  stdin_cwd="$(python3 -c 'import json,sys
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

if [ -f "$project_dir/.superspecflow/enabled" ]; then
  emit enabled
fi

emit disabled
