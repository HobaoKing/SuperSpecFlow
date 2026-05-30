# Consultation Notes: clarify-superspecflow-layer-boundary

## Participants

- Codex: implementation owner and synthesis.
- Sub-agent `McClintock`: independent repository review.
- Claude: requested as external consultation, but the local CLI stalled without output and had to be stopped.
- opencode: used as the Claude replacement after user approval.

## Sub-agent Result

Sub-agent recommended a new corrective change instead of patching the old one in place:

- Change ID: `clarify-superspecflow-layer-boundary`.
- OpenSpec is the contract layer.
- Superpowers is the execution discipline layer.
- SuperSpecFlow is the routing/glue/adapter layer, not a replacement role-gate framework.
- Tests and pack validation should reject `SuperSpecFlow 角色门禁` and require the new layer labels.
- `own-role-gates-remove-gstack-style` should remain historical but be superseded where it required SuperSpecFlow-owned role-gate wording.

## Claude Result

Claude consultation was attempted first with a read-only review prompt. It did not return output after several minutes. The process could not be interrupted through normal session stdin, so the hung local `claude` processes were identified and stopped.

No Claude design recommendation was used.

## opencode Result

Sandboxed opencode with repository access stalled. A safer second run was approved and used only an abstract summary, without repository file access.

Result: `Approve（有条件通过）`.

opencode agreed that the three-layer split is the right direction:

- OpenSpec manages what is contracted.
- Superpowers manages how execution is disciplined.
- SuperSpecFlow chooses and connects the right combination.

opencode required three follow-ups:

1. Define routing input and routing output.
2. Define where Superpowers discipline selection is recorded for traceability.
3. Strengthen validation beyond negative phrase checks.

## Decision

Accepted opencode's conditions. The implementation now adds:

- `路由输入`
- `路由输出`
- `执行纪律选择记录`
- `SSF-LAYER-007`
- `SSF-LAYER-008`
- positive routing tests and pack validation checks for those markers

The final architecture remains:

```text
OpenSpec 合同层
  + Superpowers 执行纪律层
  + SuperSpecFlow 路由与适配层
```

SuperSpecFlow does not define a proprietary role-gate framework.
