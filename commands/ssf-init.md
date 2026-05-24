Initialize SuperSpecFlow opt-in for the current project (zero-touch host integration).

Argument: $ARGUMENTS

This command is a project opt-in action. It creates `.superspecflow/` in the current project and **must not** modify the host project's `AGENTS.md` or `CLAUDE.md`.

Steps:

1. Confirm the current working directory is the project to opt in.
2. Locate the SuperSpecFlow pack root. Prefer the directory that contains `routing/CLAUDE.global.md`, `routing/AGENTS.global.md`, `commands/`, `skills/`, and `agents/`.
3. Run the contract script:

   ```bash
   bash <pack>/scripts/_ssf_init_apply.sh
   ```

   This creates:
   - `.superspecflow/enabled` (sentinel, empty file)
   - `.superspecflow/{engineering,qa,release,archive,retro,decisions,maps,reviews,karpathy}/` (标准运行产物子目录)
   - `.superspecflow/progress/` (占位，保持空，由 progress-tracking change 定义)
   - `.superspecflow/verification/` (占位，保持空，由 cross-agent-verification change 定义)

4. **Do not** create `.superspecflow/CLAUDE.routing.md`, `.superspecflow/AGENTS.routing.md`, or `.superspecflow/templates`. These are reserved for **optional** project-level overrides; users add them only when they want to override the global default routing.
5. **Do not** edit the host `CLAUDE.md` or `AGENTS.md`. If the user wants global activation, point them at `scripts/install-global.sh`. If they want project-only activation without global install, they may manually add `@<pack>/routing/CLAUDE.global.md` to their project's `CLAUDE.md` themselves.
6. Print the next-step guidance produced by the contract script.

Notes:

- Explicit `/ssf-*` commands work regardless of whether `.superspecflow/` exists; they are one-off actions and do not implicitly create the sentinel.
- Re-running `/ssf-init` is idempotent: existing subdirectory contents are preserved.
- For legacy compatibility, `scripts/install-project-symlinks.sh` still works and creates the older symlink-based layout. New users should prefer `/ssf-init` + `scripts/install-global.sh`.
