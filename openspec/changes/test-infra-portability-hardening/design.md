# Design: test-infra-portability-hardening

## Architecture Summary

测试 helper 继续集中管理 temp root。Cleanup 使用 `ssf__tmpdir()` 得到 normalized temp root，再检查目标路径必须是该 root 下的 `ssf-home.*` 或 `ssf-proj.*`。旧 `/tmp/ssf-*` 与 macOS temp 模式不再作为独立白名单来源，而是自然由当前 `TMPDIR` 覆盖。

## Isolated Repo Fixtures

新增 helper 创建临时 repo copy，root-mutating tests 在 copy 中运行 `scripts/validate-pack.sh` 和 git checks。Copy 必须保留 `.git` 元数据或创建等价 git repo，使 `git check-ignore` 和 `git ls-files` 仍有真实语义。

## Failure Modes

- `TMPDIR` 为空、`/`、或非目录：cleanup 拒绝。
- 目标 basename 不是 `ssf-home.*` 或 `ssf-proj.*`：cleanup 拒绝。
- 目标不在 normalized temp root 下：cleanup 拒绝。
- 临时 repo copy 不能运行 git checks：测试失败，不回退到真实 repo mutation。

## Review Gate

本 child 的实现前必须写入 `engineering/test-infra-portability-hardening/review-consensus.md`。
