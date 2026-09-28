#!/usr/bin/env bash
# 安装与卸载共用的归属校验；由调用方提供 REPO_ROOT，不直接执行安装操作。

# 返回普通文件的 SHA-256 值；读取错误通过管道失败状态交给调用方，不能当成匹配。
file_checksum() {
  shasum -a 256 "$1" | awk '{print $1}'
}

# 计算目录中普通文件的旧版兼容校验值；出现软链或特殊文件时返回 1，调用方必须保留目录。
# 不跟随软链、不读取 FIFO，避免把未覆盖的目录项误判为未修改并整目录删除。
dir_checksum() {
  local dir="$1" special file rel
  [ ! -L "$dir" ] || return 1
  special="$(find "$dir" ! -type d ! -type f -print -quit)" || return 1
  [ -z "$special" ] || return 1
  (
    cd "$dir" || exit 1
    find . -type f ! -name '.superspecflow-installed' -print | LC_ALL=C sort | while IFS= read -r file; do
      rel="${file#./}"
      printf '%s\n' "$rel"
      shasum -a 256 "$rel" || exit 1
    done
  ) | shasum -a 256 | awk '{print $1}'
}

# 兼容旧版追加式清单，每个目标仅输出最后一次安装记录，并保持最后记录的先后顺序。
# $1 不存在时输出为空；历史 checksum 不能用于当前文件的修改保护判定。
manifest_latest() {
  [ -f "$1" ] || return 0
  awk -F '\t' '
    NF == 3 { rows[$3] = $0; last[$3] = NR; paths[NR] = $3 }
    END { for (i = 1; i <= NR; i++) if (last[paths[i]] == i) print rows[paths[i]] }
  ' "$1"
}

# 判断目标是否在清单中有归属记录；存在返回 0，不存在返回 1。
manifest_has_path() {
  local manifest="$1" target="$2"
  [ -f "$manifest" ] || return 1
  awk -F '\t' -v p="$target" '$3 == p { found = 1 } END { exit found ? 0 : 1 }' "$manifest"
}

# 仅将当前类型与 checksum 对比目标最后一条安装记录，不能命中更旧版本的值。
manifest_checksum_matches() {
  local manifest="$1" kind="$2" checksum="$3" target="$4"
  [ -f "$manifest" ] || return 1
  awk -F '\t' -v k="$kind" -v c="$checksum" -v p="$target" '
    $3 == p { matches = ($1 == k && $2 == c) }
    END { exit matches ? 0 : 1 }
  ' "$manifest"
}

# 原子更新目标的唯一有效记录，同时折叠旧清单历史；kind 为空表示忘记已清理的目标。
# $1 清单路径，$2 类型 F/D 或空，$3 checksum，$4 目标绝对路径；临时文件位于清单同目录。
record_manifest() {
  local manifest="$1" kind="$2" checksum="$3" target="$4" tmp
  mkdir -p "$(dirname "$manifest")"
  tmp="$(mktemp "$manifest.XXXXXX")"
  manifest_latest "$manifest" | awk -F '\t' -v p="$target" '$3 != p' > "$tmp"
  if [ -n "$kind" ]; then
    printf '%s\t%s\t%s\n' "$kind" "$checksum" "$target" >> "$tmp"
  fi
  mv "$tmp" "$manifest"
}

# 校验已记录目标可否安全移除：拒绝软链，目录还必须带当前包的归属标记且可完整校验。
# $1 类型 F/D，$2 最新安装 checksum，$3 目标；返回 0 才允许删除，否则保留用户内容。
owned_target_matches() {
  local kind="$1" checksum="$2" target="$3" current
  [ ! -L "$target" ] || return 1
  if [ "$kind" = F ] && [ -f "$target" ]; then
    current="$(file_checksum "$target")" || return 1
  elif [ "$kind" = D ] && [ -d "$target" ]; then
    [ -f "$target/.superspecflow-installed" ] || return 1
    [ ! -L "$target/.superspecflow-installed" ] || return 1
    grep -Fxq "$REPO_ROOT" "$target/.superspecflow-installed" || return 1
    current="$(dir_checksum "$target")" || return 1
  else
    return 1
  fi
  [ "$current" = "$checksum" ]
}

# 清理当前包已退役的能力，只处理指定宿主目录内、清单记录过的直接子项 ssf-*。
# $1 清单，$2 已安装目录，$3 类型 F/D，$4 包内源目录；用户改过的内容与记录保留并告警。
# 只删除最近清单与当前归属校验一致的项；删除后读回再移除记录，计数用于安装汇总。
prune_retired_capabilities() {
  local manifest="$1" target_root="$2" expected_kind="$3" source_root="$4"
  local kind checksum target name
  if [ -L "$target_root" ]; then
    echo "⚠ retired cleanup root is a symlink; skipped: $target_root"
    SSF_PRUNE_PRESERVED=$((${SSF_PRUNE_PRESERVED:-0} + 1))
    return 0
  fi
  while IFS=$'\t' read -r kind checksum target; do
    [ "$kind" = "$expected_kind" ] || continue
    [ "$(dirname "$target")" = "$target_root" ] || continue
    name="$(basename "$target")"
    case "$name" in ssf-*) ;; *) continue ;; esac
    if [ -e "$source_root/$name" ] || [ -L "$source_root/$name" ]; then continue; fi
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
      record_manifest "$manifest" '' '' "$target"
    elif owned_target_matches "$kind" "$checksum" "$target"; then
      if [ "$kind" = D ]; then rm -rf "$target"; else rm -f "$target"; fi
      if [ -e "$target" ] || [ -L "$target" ]; then
        echo "error: retired target remains: $target" >&2
        return 1
      fi
      record_manifest "$manifest" '' '' "$target"
      SSF_PRUNED=$((${SSF_PRUNED:-0} + 1))
      echo "✓ removed retired capability: $target"
    else
      SSF_PRUNE_PRESERVED=$((${SSF_PRUNE_PRESERVED:-0} + 1))
      echo "⚠ retired capability was modified or cannot be verified; skipped: $target"
    fi
  done < <(manifest_latest "$manifest")
}
