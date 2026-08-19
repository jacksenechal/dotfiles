---
name: dependabot-wait-posture
description: "Pre-launch, don't proactively open security bump PRs; wait for Dependabot"
metadata:
  node_type: memory
  type: project
  originSessionId: 08e986d2-86c0-4aae-b992-378685f4a29a
  modified: 2026-08-03T18:04:08.556Z
---

Decided 2026-08-03: while there is no production surface (login-gated, no real family
data yet), do not proactively open manual dependency-bump PRs for open Dependabot
alerts, even high-severity runtime ones (next, sharp). Wait for Dependabot to open
its PRs, then handle per [[feedback-auto-merge-dependabot]].

Context from the 2026-08-03 triage: 45 open alerts (14 high), zero Dependabot PRs
open at the time. A sharp bump, whenever it comes, needs preview-deployment upload
verification per doc/native-dependency-verification.md, not just green CI.

Revisit this posture at beta launch / first real data.
