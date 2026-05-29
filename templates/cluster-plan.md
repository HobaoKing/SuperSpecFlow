# Cluster Plan: [parent-change]

Path: `.superspecflow/clusters/[parent-change]/cluster-plan.md`

## Parent Change
- Goal:
- Non-goals:
- Cross-cluster dependencies:
- Integration owner:

## Clusters
| Cluster ID | Goal | Spec IDs | Dependencies | Worktree Path | Branch | Owner | QA Expectations | Integration Order |
|---|---|---|---|---|---|---|---|---|

## Split Decision
- Trigger: >8 tasks | >6 Spec IDs | >2 independent subsystems | user requested
- If not split, record reason:

## Boundaries
- Worktree is execution isolation only, not a release boundary.
- Each cluster keeps its own OpenSpec tasks, spec-to-code map, review, QA, and Git evidence.
