# QA Execution Plan: [change-id]

Path: `.superspecflow/qa/[change-id]/qa-execution-plan.md`

## Source
- Acceptance Matrix: `.superspecflow/qa/[change-id]/acceptance-matrix.md`

## Runnable Target
- URL:
- Start Command:
- Environment:
- Blocked Reason:

## Browser / MCP Journeys
| Spec ID | Scenario | Target | Preconditions | Steps | Expected Result | Evidence Type | Status |
|---|---|---|---|---|---|---|---|

## Derivation Rules
- Derive only E2E, user journey, or explicitly browser-required acceptance matrix rows.
- preserve Spec ID mapping from `acceptance-matrix.md`.
- Do not replace or delete the source acceptance matrix.

## Safety Constraints
- Do not execute production payments, releases, email sends, webhooks, or other real-world actions.
- Do not write secrets, tokens, credentials, production customer data, or sensitive logs into `qa-evidence/`.
