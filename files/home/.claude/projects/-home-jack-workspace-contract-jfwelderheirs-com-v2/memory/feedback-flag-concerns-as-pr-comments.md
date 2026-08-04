---
name: feedback-flag-concerns-as-pr-comments
description: "When flagging a concern about a PR, post it as a PR comment — not only in the session"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3b5e1612-9b9a-4c84-b2e4-63548026ec5f
---

When flagging a concern/risk about a specific PR for Jack's decision, **post the finding as a comment on the PR itself** (`gh pr comment <N> --body ...`), in addition to raising it in the session. Requested 2026-07-15 after he enabled auto-merge on PR #71 (sharp 0.34→0.35) without seeing a flag that existed only in the session transcript.

**Why:** Jack acts on PRs in the GitHub UI, not by reading session transcripts. A flag that lives only in a session message is easy to miss, and for an auto-merge-armed PR a missed flag means it lands unreviewed. The PR comment is where the decision actually gets made, and it durably records the reasoning for anyone later.

**How to apply:** Comment on the PR with the concern, what was checked and cleared, and the specific open question. Keep it short and decision-oriented. Applies to any PR, not just Dependabot ones. Post the resolution as a follow-up comment too, so the thread closes itself.

Note this is about **recording** the flag, not about **waiting** on it: per [[feedback-auto-merge-dependabot]], resolve the flag autonomously (run the verification via a subagent) rather than parking the PR pending Jack's reply. Comment, verify, resolve — escalate only if verification finds a real problem.
