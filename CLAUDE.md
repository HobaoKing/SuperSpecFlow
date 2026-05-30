@./routing/CLAUDE.routing.md

# SuperSpecFlow Repository Entry

This root file is intentionally thin. The complete SuperSpecFlow Intake Gate,
stage routing, Git rules, QA/Ship gates, and completion criteria live in
`routing/CLAUDE.routing.md`.

Layer boundary summary:

- OpenSpec 合同层 owns change-id, Spec ID, requirements, tasks, archive, and traceability.
- Superpowers 执行纪律层 owns thinking, planning, TDD, review handling, and verification-before-completion discipline.
- SuperSpecFlow 路由与适配层 owns routing natural language requests to the correct OpenSpec contract and Superpowers discipline.

Local source-repository constraints:

- `openspec/` is a committable contract directory for SuperSpecFlow package
  changes.
- `engineering/<change-id>/` is a committable package-source delivery directory.
- `.superspecflow/`, `.claude/`, `.codex/`, `superpowers/`,
  `docs/superpowers/`, and `.DS_Store` are local runtime, install, or cache
  artifacts and must not be tracked in this repository.
- Commit scopes may use root modules such as `openspec`, `routing`, `skills`,
  `commands`, `agents`, `templates`, `scripts`, `docs`, `tests`, `examples`,
  and `meta`.
