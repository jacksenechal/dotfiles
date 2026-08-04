---
name: jfwh-project-board
description: JFWH GitHub Project
metadata: 
  node_type: memory
  type: project
  originSessionId: 685bb146-45e9-4095-89da-04e2c14fcb6f
---

JFWH org GitHub Project #1 ("JFWH", `PVT_kwDOEfIX884BdhU3`) is the delivery board for jfwh-v2, wired via `.github/project-config.json` (set 2026-07-16). Orchestrator duties live in `pm-workflow` §4–5; collaborator-facing conventions in `doc/agent-operating-model.md`.

**Field/option IDs** (for `gh project item-edit --single-select-option-id`):
- Status `PVTSSF_lADOEfIX884BdhU3zhYCSyE`: Backlog `f75ad846`, Ready `61e4505c`, In progress `47fc9ee4`, In review `df73e18b`, Done `98236657`
- Priority `PVTSSF_lADOEfIX884BdhU3zhYCYYY`: High `3a69e0c2`, Medium `ded06c1c`, Low `9e8d59e3`

**Org issue fields ≠ project fields.** The org also has GitHub's org-level custom *issue* fields (`gh api /orgs/jfwelderheirs/issue-fields`; REST, needs `admin:org` scope to modify) — shown under "Fields" in the issue pane, above the "Projects" section. The default "Priority" one duplicated the board's and was deleted 2026-07-17; Start date / Target date / Effort remain unused. The board's project fields below are the real ones.

**API gotchas** (learned 2026-07-15/16):
- GitHub's default-template project fields reject ALL API edits ("Only custom fields can be updated") — never delete+recreate one: deleting a field silently clears any board view grouped by it, and views have NO public API (no updateProjectV2View mutation) so only Jack can re-group manually. This happened once with the Priority field.
- Project built-in workflows: API exposes only name+enabled, not trigger→action config. 7 enabled on this board.
- `gh project list`/`item-list` need `--format json` (not `--json`); the GPS plugin docs show the wrong flag.

**Board policies (Jack, 2026-07-16)**:
- Blocked indefinitely / long-horizon → move In progress back to **Backlog** (+`blocked` label + "Blocked on: …" comment). Minimize WIP; short waits don't demote.
- Ready is Jack-curated (Claude proposes, never promotes); pull top-down.
- **Everything goes through In review** for Jack's eyes-on by default — the column is his visibility mechanism. Autonomous merge lane is opt-in per explicit request for a task/phase only. Dependabot [[feedback-auto-merge-dependabot]] stays the standing exception.
- PRs get an independent fresh-eyes review from the `reviewer` agent (`.claude/agents/reviewer.md`, Fable-class, no builder context) and loop with the coding agent until PASS, before promotion to In review.
