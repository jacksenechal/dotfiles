---
name: feedback-no-dash-rule-scope
description: "The no-em-dash rule covers human communication only, not repo prose"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 3b5e1612-9b9a-4c84-b2e4-63548026ec5f
---

The global "no em dashes or en dashes" rule in `~/.claude/CLAUDE.md` applies to **human communication only**: chat replies to Jack, emails, LinkedIn messages, cover letters, posts. It does **not** apply to **repo prose**: code comments, docs under `doc/`, config file comments, commit messages, and PR/issue bodies. Confirmed by Jack 2026-07-15 when I flagged that I had been breaking the rule in chat while an agent's new repo doc also used dashes.

**Why:** the rule's stated rationale is that dashes read as "AI wrote this" to a *recipient*. That concern is about correspondence, not project artifacts. It also matches reality in jfwh-v2: CLAUDE.md and the existing `doc/` files are full of em dashes, so they are the established house style there, and stripping them from one new doc would make it inconsistent with everything around it.

**How to apply:** In anything addressed to a person, use commas, periods, parentheses, or colons instead. In repo prose, match the surrounding house style and do not restyle existing files. Do not instruct subagents that CLAUDE.md forbids dashes in repo files; it does not, and I wrongly told one that it did.
