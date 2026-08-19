---
name: feedback-planning-tasks-need-strong-models
description: "Delegate planning/judgment work to Fable- or Opus-class agents, not Sonnet"
metadata:
  node_type: memory
  type: feedback
  originSessionId: d27092e5-440d-4db5-abde-165d649b2d05
---

Planning tasks get **Fable- or Opus-class** agents. Sonnet/Haiku are for execution: mechanical
edits, well-specified code changes, doc sweeps, bookkeeping PRs, fan-out search. Planning means
scoping, decomposition, keep/drop/defer recommendations, architecture trade-offs, PRD/epic
drafting, or anything whose deliverable is a judgment Jack will act on.

**Why:** the standing "orchestrator, not executor — delegate to cheap subagents" rule
(global CLAUDE.md) explicitly carves out tasks genuinely too hard for cheap models, and
planning is the main such case. A weak planning agent's failure mode is quiet: it returns a
plausible, well-formatted document with shallow reasoning, and the cost lands later on Jack,
who acts on it. Cheap execution failures surface fast (red CI); cheap planning failures don't.

**How to apply:** when spawning an agent, ask what the deliverable is. A judgment → pass
`model: "opus"` or `"fable"`. An artifact whose correctness is externally checkable → Sonnet
is fine. Cost saving is not a reason to under-model a planning task.

Precedent: the `reviewer` agent (`.claude/agents/reviewer.md`) is already Fable-class for the
same reason — independent judgment, no builder context. See [[jfwh-project-board]].
