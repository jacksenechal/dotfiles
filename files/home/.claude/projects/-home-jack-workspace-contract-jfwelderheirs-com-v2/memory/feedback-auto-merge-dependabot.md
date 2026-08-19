---
name: feedback-auto-merge-dependabot
description: jfwh-v2 standing policy — auto-merge green Dependabot PRs without per-PR LGTM
metadata:
  node_type: memory
  type: feedback
  originSessionId: 52a5b591-0903-4c16-9c09-486d406d8de5
---

In jfwh-v2, Jack authorized (2026-07-10) a standing policy: **auto-merge any Dependabot PR once CI + Socket checks pass** (`gh pr merge <N> --auto --squash --delete-branch`). Do not ping him for per-PR LGTM on routine Dependabot bumps.

**Extended 2026-07-15 — don't block on Jack for the risky ones either.** When a bump is risky because CI structurally can't vouch for the runtime behavior it touches, **run the verification yourself autonomously** (spawn a QA/verify subagent to exercise the real code path) and resolve the flag on your own. Post both the flag and the verification result as PR comments. Only escalate to Jack if the verification actually finds a problem, or the call is genuinely his (cost, product direction, hard-to-reverse). Origin: PR #71 (sharp 0.34→0.35) — flagged because nothing tested image processing, then a verify subagent did a real Payload upload + CMYK check and cleared it. Jack: "you could handle that all autonomously in the future."

**Why:** Jack's posture is "keep us safe, stay up to date, whatever keeps us safe" and he considers routine Dependabot PRs simple; the CI (build + migrate + tests) + Socket required checks are a sufficient gate. Reduces notification churn. Holding a PR for a human decision that a subagent could settle with evidence just stalls the work — the flag is worth recording, but the resolution is agent work.

**How to apply:** When a Dependabot PR opens, enable auto-merge (squash). It lands itself on green. Only interrupt Jack for the genuinely risky ones — and when you do, **flag it as a comment on the PR itself**, not only in the session: see [[feedback-flag-concerns-as-pr-comments]]. Note merge-to-main auto-deploys to prod, so the CI gate is what protects prod — this is why the policy is conditioned on green CI, not blind. See [[confirm-locally-before-prod-push]].
