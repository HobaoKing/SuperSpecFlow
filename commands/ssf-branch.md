Use the `ssf-git` skill.

Change id and topic: $ARGUMENTS

Create or recommend a branch:
1. Check current branch and worktree.
2. Confirm base branch.
3. Generate branch name using `ssf/<change-id>-<short-slug>`.
4. For Spec cluster work, generate `ssf/<parent-change>-<cluster-id>-<short-slug>` and record the worktree path in `cluster-plan.md`.
5. Warn if existing changes do not belong to the change-id.
