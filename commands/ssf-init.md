Initialize SuperSpecFlow routing for the current project.

Argument: $ARGUMENTS

This command is a project initialization action. It may create or update `.superspecflow/` symlinks in the current project, but it must not overwrite `AGENTS.md` or `CLAUDE.md`.

Steps:
1. Confirm the current working directory is the project to initialize.
2. Locate the SuperSpecFlow pack root. Prefer the directory that contains `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `templates/`, `skills/`, `commands/`, and `agents/`.
3. Create `.superspecflow/` in the current project.
4. Symlink:
   - `.superspecflow/AGENTS.routing.md` -> `<pack>/routing/AGENTS.routing.md`
   - `.superspecflow/CLAUDE.routing.md` -> `<pack>/routing/CLAUDE.routing.md`
   - `.superspecflow/templates` -> `<pack>/templates`
5. If `.claude/` exists or the user wants Claude Code project-level commands, symlink `agents/`, `commands/ssf-*.md`, and `skills/ssf-*` into `.claude/`.
6. Do not edit host `AGENTS.md` or `CLAUDE.md` automatically. Print the opt-in lines for the user to add:

```markdown
@./.superspecflow/AGENTS.routing.md
```

```markdown
@./.superspecflow/CLAUDE.routing.md
```

7. Explain that explicit `/ssf-*` commands are one-off actions and do not create `.superspecflow/`; only `/ssf-init` or an explicit install action opts the project into natural-language routing.
