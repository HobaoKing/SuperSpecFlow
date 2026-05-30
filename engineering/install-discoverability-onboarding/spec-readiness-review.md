# Spec Readiness Review: install-discoverability-onboarding

## Review Status

Ready — implemented and locally verified.

## Notes

- Proposal、design、tasks、specs（SSF-ONBOARD-001..006）已写实，覆盖三层根因（入口认知颠倒、安装/opt-in 后需重启会话、终端备用路径被埋没）与 Codex 评审补充的两个边界（Codex-only 段事实修正、同名 skip 提示）。
- Cross-agent verification：Codex（gpt-5.5，只读模式）独立读取仓库文件核验三层诊断，结论为"需调整后采纳"；其建议已采纳——补 opt-in 后新会话提示、修正 `_ssf_init_apply.sh` 第 40 行误导、改为 standalone change 而非塞入已完成 parent。
- 验证证据：`tests/install/test_install_global.bats`、`tests/init/test_ssf_init_apply_onboarding.bats`、`tests/docs/test_install_onboarding.bats` 先红后绿；`scripts/test.sh` 全量 186 ok；`scripts/validate-pack.sh` EXIT=0。
- 残余：待提交与最终 review/archive；本地无 shellcheck（CI 已配置）。
