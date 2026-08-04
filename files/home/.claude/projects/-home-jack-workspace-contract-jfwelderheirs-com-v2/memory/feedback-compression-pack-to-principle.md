---
name: feedback-compression-pack-to-principle
description: "Reductive editing = pack emanated detail back to its backing principle, not just trim/dedup"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: d27092e5-440d-4db5-abde-165d649b2d05
---

When compressing docs (or prose generally), the strongest move is **PACK**: find the upstream
principle a passage emanates from, state it once crisply, and delete the elaboration a competent
reader re-derives. This is distinct from and more reductive than the three moves used in the
jfwh-v2 doc pass:
- DELETE (remove repeated facts), LINK (point to canonical home), TIGHTEN (same content, fewer
  words) — all preserve structure and just squeeze water out of each sentence.
- **PACK** removes *derivable* content: text stated only once but reconstructable from a higher
  principle. Much more aggressive, higher judgment.

**The test that decides PACK vs KEEP:** delete the elaboration, leave only the principle — would
the target reader reconstruct the RIGHT action, or a plausibly WRONG one? Right → pack it away.
Wrong/silent-failure → keep it. This is the exact dual of the rule already in CLAUDE.md's
doc-discipline section ("rationale is load-bearing where the wrong action is plausible, cheap,
and silent"). Load-bearing rationale is just the un-packable residue.

**Where PACK pays / where it's dangerous:** thick emanation in knowledge-base prose, PRDs,
findings docs → pack hard (reader re-derives fine). Agent-instruction files (CLAUDE.md, skills)
→ pack conservatively, because an agent re-deriving a foot-gun wrongly is a silent regression;
that's why those got the trigger-inventory scaffold.

**Why:** Jack (2026-07-17) noted the pass was non-lossy but far less reductive than he'd be by
hand. Root cause: we fought verbosity sentence-by-sentence instead of reversing the emanation —
asking what packs back up to the principle and re-derives. Communication dual:
[[feedback-lead-with-decision-not-context]].
