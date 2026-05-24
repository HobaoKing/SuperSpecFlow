#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FAILED=0

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  FAILED=1
}

tmp_file() {
  mktemp "${TMPDIR:-/tmp}/ssf-validate.XXXXXX"
}

# 选择递归搜索工具。优先 ripgrep；缺失时退化到 grep -REn。
# 之前直接 `if rg ... ; then` 把 "rg 不存在 (exit 127)" 当作 "未发现残留"，造成假阳性。
if command -v rg >/dev/null 2>&1; then
  SEARCH_TOOL="rg"
else
  SEARCH_TOOL="grep"
  printf 'WARN: 未检测到 ripgrep (rg)，使用 grep -REn 退化模式。\n' >&2
fi

# 在当前目录递归搜索正则。命中 -> 输出并返回 0；未命中 -> 返回 1。
# 第 1 参数：正则
# 第 2 参数：以空格分隔的相对路径白名单（除 .git 之外要额外排除的文件）
# 第 3 参数：以空格分隔的搜索根路径列表，默认 "."
search_repo() {
  local pattern="$1"
  local exclude_str="${2:-}"
  local roots_str="${3:-.}"

  local -a exclude_paths roots
  # shellcheck disable=SC2206
  exclude_paths=( ${exclude_str} )
  # shellcheck disable=SC2206
  roots=( ${roots_str} )

  local status
  if [ "$SEARCH_TOOL" = "rg" ]; then
    local -a args
    args=(--hidden -n "$pattern" --glob '!.git/**')
    local e
    for e in "${exclude_paths[@]}"; do
      [ -n "$e" ] && args+=(--glob "!$e")
    done
    rg "${args[@]}" "${roots[@]}" && status=0 || status=$?
    return "$status"
  fi

  # grep --exclude 只匹配 basename，本仓库豁免文件名唯一，够用。
  local -a args
  args=(-REn "$pattern" --exclude-dir=.git)
  local e base
  for e in "${exclude_paths[@]}"; do
    [ -z "$e" ] && continue
    base="$(basename "$e")"
    args+=(--exclude="$base")
  done
  grep "${args[@]}" "${roots[@]}" && status=0 || status=$?
  return "$status"
}

check_no_legacy_command_prefix() {
  local out_file
  out_file="$(tmp_file)"

  if search_repo 'ssf:' \
       'scripts/validate-pack.sh templates/git-hooks/commit-msg' \
       '.' \
       >"$out_file" 2>/dev/null; then
    cat "$out_file" >&2
    fail "发现旧命令前缀残留，请统一使用 /ssf-xxx 和 commands/ssf-xxx.md"
  else
    pass "未发现旧命令前缀残留"
  fi
  rm -f "$out_file"
}

check_no_hw_prefix() {
  local out_file
  out_file="$(tmp_file)"

  if search_repo '(^|[^A-Za-z0-9_/-])/?hw[-:]|commands/hw[-:]|skills/hw-' \
       'scripts/validate-pack.sh' \
       '.' \
       >"$out_file" 2>/dev/null; then
    cat "$out_file" >&2
    fail "发现 hw 旧前缀残留"
  else
    pass "未发现 hw 旧前缀残留"
  fi
  rm -f "$out_file"
}

check_no_colon_filenames() {
  local colon_files
  colon_files="$(find . -path './.git' -prune -o -name '*:*' -print)"

  if [ -n "$colon_files" ]; then
    printf '%s\n' "$colon_files" >&2
    fail "发现包含冒号的文件名"
  else
    pass "未发现包含冒号的文件名"
  fi
}

check_no_tracked_runtime_artifacts() {
  local out_file
  out_file="$(tmp_file)"

  if git ls-files | grep -E '^(superpowers|\.superspecflow|\.claude|\.codex)/|(^|/)\.DS_Store$' >"$out_file"; then
    cat "$out_file" >&2
    fail "发现已被 Git 跟踪的 workflow 运行时或安装产物"
  else
    pass "Git 跟踪列表不包含 workflow 运行时或安装产物"
  fi
  rm -f "$out_file"
}

check_no_host_instruction_overwrite() {
  local out_file
  out_file="$(tmp_file)"

  set +e
  if [ "$SEARCH_TOOL" = "rg" ]; then
    rg -n 'cp[[:space:]]+AGENTS\.md|cp[[:space:]]+CLAUDE\.md' README.md docs templates \
      >"$out_file" 2>/dev/null
  else
    grep -REn 'cp[[:space:]]+AGENTS\.md|cp[[:space:]]+CLAUDE\.md' README.md docs templates \
      >"$out_file" 2>/dev/null
  fi
  local status=$?
  set -e

  if [ "$status" -eq 0 ]; then
    cat "$out_file" >&2
    fail "发现覆盖宿主项目 AGENTS.md / CLAUDE.md 的安装说明"
  elif [ "$status" -eq 1 ]; then
    pass "未发现覆盖宿主项目指令文件的安装说明"
  else
    cat "$out_file" >&2
    fail "检查宿主项目指令覆盖说明时搜索失败"
  fi
  rm -f "$out_file"
}

check_skill_frontmatter() {
  local skill header

  for skill in skills/*/SKILL.md; do
    if [ ! -f "$skill" ]; then
      continue
    fi

    if [ "$(sed -n '1p' "$skill")" != "---" ]; then
      fail "$skill 缺少 frontmatter 起始分隔符"
      continue
    fi

    header="$(awk '
      NR == 1 && $0 == "---" { inside = 1; next }
      NR > 1 && inside && $0 == "---" { exit }
      inside { print }
    ' "$skill")"

    if ! printf '%s\n' "$header" | grep -Eq '^name:[[:space:]]*ssf-[A-Za-z0-9_-]+'; then
      fail "$skill 缺少 ssf-* 格式的 name frontmatter"
    elif ! printf '%s\n' "$header" | grep -Eq '^description:[[:space:]]*.+'; then
      fail "$skill 缺少 description frontmatter"
    else
      pass "$skill frontmatter 合法"
    fi
  done
}

check_command_docs_consistency() {
  local doc expected_file actual_file
  expected_file="$(tmp_file)"
  actual_file="$(tmp_file)"

  find commands -maxdepth 1 -type f -name 'ssf-*.md' \
    -exec basename {} .md \; \
    | sed 's#^#/#' \
    | sort -u >"$expected_file"

  for doc in README.md routing/AGENTS.routing.md routing/CLAUDE.routing.md; do
    grep -Eo '/ssf-[a-z]+' "$doc" | sort -u >"$actual_file" || true

    if diff -u "$expected_file" "$actual_file" >/tmp/ssf-command-diff.txt; then
      pass "$doc 命令集合与 commands/ 一致"
    else
      printf '%s\n' "命令集合不一致：$doc" >&2
      cat /tmp/ssf-command-diff.txt >&2
      fail "$doc 命令集合与 commands/ 不一致"
    fi
  done

  rm -f "$expected_file" "$actual_file"
}

check_zero_touch_artifacts() {
  # ---- 方案 C 零侵入接入结构契约 ----

  # 全局 routing 薄壳存在且采用指令式条件读取，禁止 @ 自动 include 写法
  for pair in "routing/CLAUDE.global.md:CLAUDE.routing.md" "routing/AGENTS.global.md:AGENTS.routing.md"; do
    global="${pair%%:*}"
    main="${pair##*:}"
    if [ ! -f "$global" ]; then
      fail "missing $global"
      continue
    fi
    # 必不含 @ 自动 include 写法（行首 @<repo>/routing/*.routing.md）
    if grep -E "^@<repo>/routing/${main}" "$global" >/dev/null; then
      fail "$global must not use @ auto-include for $main (breaks disabled-state opt-out)"
    else
      pass "$global free of @ auto-include for $main"
    fi
    # 必含指令式条件读取关键字
    if grep -q "主动用 Read 工具读取\|主动读取" "$global"; then
      pass "$global uses instruction-style conditional read"
    else
      fail "$global missing instruction-style conditional read for $main"
    fi
  done

  # 三个脚本存在并可执行
  for f in scripts/hooks/session-start-detect.sh scripts/install-global.sh scripts/_ssf_init_apply.sh; do
    if [ ! -x "$f" ]; then
      fail "$f missing or not executable"
    else
      pass "$f executable"
    fi
  done

  # ssf-init.md 不能退回到老软链语义
  if grep -Fq "ln -s" commands/ssf-init.md; then
    fail "commands/ssf-init.md still uses ln -s (zero-touch must not symlink routing)"
  else
    pass "commands/ssf-init.md zero-touch semantics OK"
  fi
}

check_command_file_names() {
  local bad_files
  bad_files="$(find commands -maxdepth 1 -type f ! -name 'ssf-*.md' -print)"

  if [ -n "$bad_files" ]; then
    printf '%s\n' "$bad_files" >&2
    fail "commands/ 下存在非 ssf-*.md 文件"
  else
    pass "commands/ 文件名均为 ssf-*.md"
  fi
}

check_routing_files() {
  local routing_file

  for routing_file in routing/AGENTS.routing.md routing/CLAUDE.routing.md; do
    if [ ! -f "$routing_file" ]; then
      fail "$routing_file 不存在"
      continue
    fi

    if ! grep -q 'Intake Gate' "$routing_file"; then
      fail "$routing_file 缺少 Intake Gate"
    elif ! grep -q '轻量任务' "$routing_file"; then
      fail "$routing_file 缺少轻量任务边界"
    elif ! grep -q 'Karpathy 编码纪律' "$routing_file"; then
      fail "$routing_file 缺少 Karpathy 编码纪律"
    elif ! grep -q '外科手术式修改' "$routing_file"; then
      fail "$routing_file 缺少外科手术式修改规则"
    elif ! grep -q '目标驱动验证' "$routing_file"; then
      fail "$routing_file 缺少目标驱动验证规则"
    else
      pass "$routing_file 包含 Intake Gate、轻量任务边界和 Karpathy 编码纪律"
    fi
  done

  if ! grep -q '| 类别 | 判定标准 | 处理方式 |' routing/AGENTS.routing.md; then
    fail "routing/AGENTS.routing.md 缺少完整 Intake Gate 判定表"
  elif ! grep -q 'Product Change Brief' routing/AGENTS.routing.md; then
    fail "routing/AGENTS.routing.md 缺少 Product / Think 输出契约"
  elif ! grep -q 'Spec-to-Code Rule' routing/AGENTS.routing.md; then
    fail "routing/AGENTS.routing.md 缺少 Spec-to-Code Rule"
  elif ! grep -q 'Completion Criteria' routing/AGENTS.routing.md; then
    fail "routing/AGENTS.routing.md 缺少 Completion Criteria"
  else
    pass "routing/AGENTS.routing.md 保留完整路由契约"
  fi

  if ! grep -q 'Git 提交规范' routing/CLAUDE.routing.md; then
    fail "routing/CLAUDE.routing.md 缺少 Git 提交规范"
  elif ! grep -q '允许的英文类型' routing/CLAUDE.routing.md; then
    fail "routing/CLAUDE.routing.md 缺少提交类型说明"
  elif ! grep -q '高风险关键词' routing/CLAUDE.routing.md; then
    fail "routing/CLAUDE.routing.md 缺少高风险关键词"
  elif ! grep -q '完成定义' routing/CLAUDE.routing.md; then
    fail "routing/CLAUDE.routing.md 缺少完成定义"
  else
    pass "routing/CLAUDE.routing.md 保留完整路由契约"
  fi

  if cmp -s routing/AGENTS.routing.md routing/CLAUDE.routing.md; then
    pass "AGENTS 与 CLAUDE routing 内容一致"
  else
    fail "AGENTS 与 CLAUDE routing 内容不一致"
  fi
}

check_integration_snippets_thin() {
  local snippet

  for snippet in templates/integration/AGENTS.snippet.md templates/integration/CLAUDE.snippet.md; do
    if [ ! -f "$snippet" ]; then
      fail "$snippet 不存在"
      continue
    fi

    if ! grep -q '.superspecflow/.*routing.md' "$snippet"; then
      fail "$snippet 缺少 .superspecflow routing 引用"
    elif grep -q '^| 纯问答' "$snippet"; then
      fail "$snippet 包含完整路由表，应保持极薄入口"
    else
      pass "$snippet 是极薄入口"
    fi
  done
}

check_progress_contract() {
  local template routing_file

  for template in \
    templates/progress-state.json \
    templates/progress-timeline.md \
    templates/progress-verification.md \
    templates/progress-handoff.md; do
    if [ ! -f "$template" ]; then
      fail "$template 不存在"
    fi
  done

  if ! grep -q '"change_id"' templates/progress-state.json; then
    fail "templates/progress-state.json 缺少 change_id 字段"
  elif ! grep -q '"last_verification"' templates/progress-state.json; then
    fail "templates/progress-state.json 缺少 last_verification 字段"
  else
    pass "progress state template 包含核心字段"
  fi

  if ! grep -q 'task-started' templates/progress-timeline.md; then
    fail "templates/progress-timeline.md 缺少 task-started 事件示例"
  elif ! grep -q '按时间顺序追加事件' templates/progress-timeline.md; then
    fail "templates/progress-timeline.md 缺少中文说明"
  elif ! grep -q 'Freshness' templates/progress-verification.md; then
    fail "templates/progress-verification.md 缺少 Freshness 字段"
  elif ! grep -q 'Read Next' templates/progress-handoff.md; then
    fail "templates/progress-handoff.md 缺少 Read Next 段落"
  else
    pass "progress markdown templates 包含恢复与验证字段"
  fi

  if ! grep -q '.superspecflow/progress/<change-id>/' skills/ssf-build/SKILL.md; then
    fail "skills/ssf-build/SKILL.md 缺少 progress 路径规则"
  elif ! grep -q 'fresh verification' skills/ssf-build/SKILL.md; then
    fail "skills/ssf-build/SKILL.md 缺少 fresh verification 规则"
  else
    pass "ssf-build 包含 progress tracking 规则"
  fi

  for routing_file in routing/AGENTS.routing.md routing/CLAUDE.routing.md; do
    if ! grep -q '.superspecflow/progress/<change-id>/' "$routing_file"; then
      fail "$routing_file 缺少 progress 路径规则"
    elif ! grep -q 'state.json' "$routing_file"; then
      fail "$routing_file 缺少 state.json 恢复规则"
    elif ! grep -q 'handoff.md' "$routing_file"; then
      fail "$routing_file 缺少 handoff.md 恢复规则"
    elif ! grep -q 'OpenSpec' "$routing_file"; then
      fail "$routing_file 缺少 OpenSpec 恢复来源"
    else
      pass "$routing_file 包含 progress 恢复规则"
    fi
  done

  if ! grep -q 'templates/progress-' openspec/changes/progress-tracking/proposal.md; then
    fail "progress-tracking proposal 缺少 progress 模板目标"
  elif ! grep -q 'skills/ssf-build/SKILL.md' openspec/changes/progress-tracking/proposal.md; then
    fail "progress-tracking proposal 缺少 ssf-build 影响范围"
  elif ! grep -q 'SSF-PROGRESS-N7' openspec/changes/progress-tracking/specs/progress.md; then
    fail "progress-tracking spec 缺少 N7 removed 记录"
  else
    pass "progress OpenSpec 与实现阶段范围同步"
  fi
}

check_cross_agent_verification_contract() {
  local template routing_file signoff_file review_section routing_section

  for template in \
    templates/verification-request.md \
    templates/verification-evidence.md \
    templates/verification-reviewer-notes.md \
    templates/verification-signoff.md; do
    if [ ! -f "$template" ]; then
      fail "$template 不存在"
    fi
  done

  if ! grep -q '.superspecflow/verification/\[change-id\]/request.md' templates/verification-request.md; then
    fail "templates/verification-request.md 缺少 request.md 路径"
  elif ! grep -q '本文件用于说明跨 agent 核验请求' templates/verification-request.md; then
    fail "templates/verification-request.md 缺少使用说明"
  elif ! grep -q '不得只写结论' templates/verification-evidence.md; then
    fail "templates/verification-evidence.md 缺少可复查 evidence 说明"
  elif ! grep -q 'Evidence Reviewed' templates/verification-signoff.md; then
    fail "templates/verification-signoff.md 缺少 Evidence Reviewed 段落"
  elif ! grep -q 'approve | changes-requested | blocked' templates/verification-signoff.md; then
    fail "templates/verification-signoff.md 缺少 signoff 枚举"
  elif ! grep -q 'progress 不可用' templates/verification-reviewer-notes.md; then
    fail "templates/verification-reviewer-notes.md 缺少 progress 不可用风险记录"
  else
    pass "cross-agent verification templates 包含核心字段"
  fi

  review_section="$(awk '
    /^## Step 6 .*Cross-Agent Verification Handoff/ { inside = 1 }
    inside && /^## Step 7 / { exit }
    inside { print }
  ' skills/ssf-review/SKILL.md)"

  if ! printf '%s\n' "$review_section" | grep -q '.superspecflow/verification/<change-id>/'; then
    fail "skills/ssf-review/SKILL.md 缺少 verification 路径规则"
  elif ! printf '%s\n' "$review_section" | grep -q 'OpenSpec'; then
    fail "skills/ssf-review/SKILL.md 缺少 OpenSpec 核验输入"
  elif ! printf '%s\n' "$review_section" | grep -q 'diff'; then
    fail "skills/ssf-review/SKILL.md 缺少 diff 核验输入"
  elif ! printf '%s\n' "$review_section" | grep -q 'evidence'; then
    fail "skills/ssf-review/SKILL.md 缺少 evidence 核验输入"
  elif ! printf '%s\n' "$review_section" | grep -q 'approve / changes-requested / blocked'; then
    fail "skills/ssf-review/SKILL.md 缺少 signoff 枚举"
  else
    pass "ssf-review 包含 cross-agent verification 规则"
  fi

  for routing_file in routing/AGENTS.routing.md routing/CLAUDE.routing.md; do
    routing_section="$(awk '
      /^Cross-agent verification:$/ { inside = 1 }
      inside && /^### / { exit }
      inside { print }
    ' "$routing_file")"

    if ! printf '%s\n' "$routing_section" | grep -q 'Cross-agent verification'; then
      fail "$routing_file 缺少 Cross-agent verification 章节"
    elif ! printf '%s\n' "$routing_section" | grep -q '.superspecflow/verification/<change-id>/'; then
      fail "$routing_file 缺少 verification 路径规则"
    elif ! printf '%s\n' "$routing_section" | grep -q 'OpenSpec'; then
      fail "$routing_file 缺少 OpenSpec 核验输入"
    elif ! printf '%s\n' "$routing_section" | grep -q 'evidence'; then
      fail "$routing_file 缺少 evidence 核验输入"
    elif ! printf '%s\n' "$routing_section" | grep -q 'approve / changes-requested / blocked'; then
      fail "$routing_file 缺少 signoff 枚举"
    else
      pass "$routing_file 包含 cross-agent verification 规则"
    fi
  done

  if [ -d .superspecflow/verification ]; then
    while IFS= read -r signoff_file; do
      [ -n "$signoff_file" ] || continue
      if ! grep -Eq '^Result:[[:space:]]*(approve|changes-requested|blocked)[[:space:]]*$' "$signoff_file"; then
        fail "非法 signoff result: $signoff_file"
      fi
    done < <(find .superspecflow/verification -type f -name signoff.md -print)
  fi

  if ! grep -q 'templates/verification-' openspec/changes/cross-agent-verification/proposal.md; then
    fail "cross-agent-verification proposal 缺少 verification 模板目标"
  elif ! grep -q 'skills/ssf-review/SKILL.md' openspec/changes/cross-agent-verification/proposal.md; then
    fail "cross-agent-verification proposal 缺少 ssf-review 影响范围"
  elif ! grep -q 'SSF-XAV-011' openspec/changes/cross-agent-verification/specs/verification.md; then
    fail "cross-agent-verification spec 缺少模板 requirement"
  elif ! grep -q 'SSF-XAV-012' openspec/changes/cross-agent-verification/specs/verification.md; then
    fail "cross-agent-verification spec 缺少运行时实例边界 requirement"
  else
    pass "Cross-agent verification OpenSpec 与实现范围同步"
  fi
}

artifact_namespaces() {
  cat <<'EOF'
.superspecflow/engineering/<change-id>/
.superspecflow/qa/<change-id>/
.superspecflow/release/<change-id>/
.superspecflow/archive/<change-id>/
.superspecflow/retro/<change-id>/
.superspecflow/decisions/
.superspecflow/maps/<change-id>/
.superspecflow/reviews/<change-id>/
.superspecflow/karpathy/<change-id>/
EOF
}

extract_artifact_paths_section() {
  local file="$1"

  awk '
    /^## Artifact Paths$/ { inside = 1 }
    inside && /^## / && $0 != "## Artifact Paths" { exit }
    inside { print }
  ' "$file"
}

section_contains_artifact_contract() {
  local section="$1"
  local namespace

  if ! printf '%s\n' "$section" | grep -qE '(new path first|新路径优先|new-path-first)'; then
    return 1
  fi
  if ! printf '%s\n' "$section" | grep -qE '(fallback|兼容期|回退)'; then
    return 1
  fi
  if ! printf '%s\n' "$section" | grep -q 'openspec/'; then
    return 1
  fi
  if ! printf '%s\n' "$section" | grep -q 'engineering/<change-id>/'; then
    return 1
  fi
  if ! printf '%s\n' "$section" | grep -q 'progress-tracking'; then
    return 1
  fi
  if ! printf '%s\n' "$section" | grep -q 'cross-agent-verification'; then
    return 1
  fi

  while IFS= read -r namespace; do
    [ -n "$namespace" ] || continue
    if ! printf '%s\n' "$section" | grep -Fq "$namespace"; then
      return 1
    fi
  done < <(artifact_namespaces)
}

check_required_path() {
  local file="$1"
  local path="$2"
  local description="$3"

  if grep -Fq "$path" "$file"; then
    pass "$description"
  else
    fail "$description 缺少 $path"
  fi
}

check_no_root_runtime_dirs() {
  local out_file
  out_file="$(tmp_file)"

  find qa release archive retro decisions maps reviews karpathy progress verification \
    -mindepth 1 -print >"$out_file" 2>/dev/null || true

  if [ -s "$out_file" ]; then
    cat "$out_file" >&2
    fail "发现根目录旧运行时产物；新写入必须使用 .superspecflow/<stage>/<change-id>/"
  else
    pass "未发现根目录旧运行时产物新写入"
  fi
  rm -f "$out_file"
}

check_artifact_path_contract() {
  local routing_file section tpl path_lines

  for routing_file in routing/AGENTS.routing.md routing/CLAUDE.routing.md; do
    section="$(extract_artifact_paths_section "$routing_file")"
    if [ -z "$section" ]; then
      fail "$routing_file 缺少 Artifact Paths 章节"
    elif section_contains_artifact_contract "$section"; then
      pass "$routing_file Artifact Paths 章节包含运行时路径契约"
    else
      fail "$routing_file Artifact Paths 章节缺少命名空间、openspec 或 fallback 契约"
    fi
  done

  check_required_path skills/ssf-build/SKILL.md '.superspecflow/engineering/<change-id>/' "ssf-build 包含 engineering runtime 路径"
  check_required_path skills/ssf-build/SKILL.md '.superspecflow/maps/<change-id>/' "ssf-build 包含 maps runtime 路径"
  check_required_path skills/ssf-build/SKILL.md 'engineering/<change-id>/spec-to-code-map.md' "ssf-build 保留本仓库工程交付路径"
  check_required_path skills/ssf-qa/SKILL.md '.superspecflow/qa/<change-id>/' "ssf-qa 包含 QA runtime 路径"
  check_required_path skills/ssf-ship/SKILL.md '.superspecflow/release/<change-id>/' "ssf-ship 包含 release runtime 路径"
  check_required_path skills/ssf-archive/SKILL.md '.superspecflow/archive/<change-id>/' "ssf-archive 包含 archive runtime 路径"
  check_required_path skills/ssf-archive/SKILL.md '.superspecflow/decisions/' "ssf-archive 包含 decisions runtime 路径"
  check_required_path skills/ssf-retro/SKILL.md '.superspecflow/retro/<change-id>/' "ssf-retro 包含 retro runtime 路径"
  check_required_path skills/ssf-review/SKILL.md '.superspecflow/reviews/<change-id>/' "ssf-review 包含 reviews runtime 路径"
  check_required_path skills/ssf-karpathy/SKILL.md '.superspecflow/karpathy/<change-id>/' "ssf-karpathy 包含 karpathy runtime 路径"

  check_required_path commands/ssf-build.md '.superspecflow/engineering/<change-id>/' "ssf-build command 包含 engineering runtime 路径"
  check_required_path commands/ssf-map.md '.superspecflow/maps/<change-id>/spec-to-code-map.md' "ssf-map command 包含 maps runtime 路径"
  check_required_path commands/ssf-qa.md '.superspecflow/qa/<change-id>/' "ssf-qa command 包含 QA runtime 路径"
  check_required_path commands/ssf-review.md '.superspecflow/reviews/<change-id>/' "ssf-review command 包含 reviews runtime 路径"
  check_required_path commands/ssf-ship.md '.superspecflow/release/<change-id>/' "ssf-ship command 包含 release runtime 路径"
  check_required_path commands/ssf-archive.md '.superspecflow/archive/<change-id>/' "ssf-archive command 包含 archive runtime 路径"
  check_required_path commands/ssf-retro.md '.superspecflow/retro/<change-id>/' "ssf-retro command 包含 retro runtime 路径"
  check_required_path commands/ssf-decision.md '.superspecflow/decisions/' "ssf-decision command 包含 decisions runtime 路径"
  check_required_path commands/ssf-karpathy.md '.superspecflow/karpathy/<change-id>/' "ssf-karpathy command 包含 karpathy runtime 路径"

  check_required_path templates/implementation-plan.md 'Path: `.superspecflow/engineering/[change-id]/implementation-plan.md`' "implementation-plan template 包含 runtime 路径"
  check_required_path templates/spec-to-code-map.md 'Path: `.superspecflow/maps/[change-id]/spec-to-code-map.md`' "spec-to-code-map template 包含 runtime 路径"
  check_required_path templates/acceptance-matrix.md 'Path: `.superspecflow/qa/[change-id]/acceptance-matrix.md`' "acceptance-matrix template 包含 runtime 路径"
  check_required_path templates/review-report.md 'Path: `.superspecflow/reviews/[change-id]/review-report.md`' "review-report template 包含 runtime 路径"
  check_required_path templates/karpathy-diff-audit.md 'Path: `.superspecflow/karpathy/[change-id]/karpathy-diff-audit.md`' "karpathy-diff-audit template 包含 runtime 路径"

  for tpl in templates/*.md; do
    path_lines="$(grep -E '^Path: `' "$tpl" || true)"
    [ -n "$path_lines" ] || continue

    if printf '%s\n' "$path_lines" | grep -Eqv '^Path: `\.superspecflow/([a-z]+/\[change-id\]/[a-z-]+\.md|decisions/\[title\]\.md)`$'; then
      printf '%s\n' "$path_lines" >&2
      fail "$tpl runtime 路径声明格式不符合 .superspecflow 命名空间"
    else
      pass "$tpl 包含 runtime 路径声明"
    fi
  done

  if git check-ignore -q .superspecflow/test-ignore; then
    pass ".superspecflow/ 已被 gitignore 忽略"
  else
    fail ".superspecflow/ 未被 gitignore 忽略"
  fi

  if git check-ignore -q openspec; then
    fail "openspec/ 被 gitignore 忽略，违反可提交契约"
  else
    pass "openspec/ 未被 gitignore 忽略"
  fi

  check_no_root_runtime_dirs
}

check_no_legacy_command_prefix
check_no_hw_prefix
check_no_colon_filenames
check_no_tracked_runtime_artifacts
check_no_host_instruction_overwrite
check_skill_frontmatter
check_command_file_names
check_routing_files
check_integration_snippets_thin
check_command_docs_consistency
check_zero_touch_artifacts
check_progress_contract
check_cross_agent_verification_contract
check_artifact_path_contract

if [ "$FAILED" -ne 0 ]; then
  exit 1
fi

printf 'SuperSpecFlow pack validation passed.\n'
