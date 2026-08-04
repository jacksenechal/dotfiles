---
name: feedback-clean-up-background-agents
description: "Stop background subagents/teammates once their work is merged/superseded or fully handed off — don't leave idle agents for the user to notice and close manually."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 52a5b591-0903-4c16-9c09-486d406d8de5
---

When a background agent (spawned via the Agent tool, run_in_background) finishes its work and that work has been merged, folded into other work, or superseded, stop it with `TaskStop` (pass its name as `task_id`) rather than leaving it idle indefinitely.

**Why:** during the jfwh-v2 CCPM trial run, two background agents finished their tasks but were left idle after their work was reorganized (redone as separate per-task PRs). The user had to ask "why are these still sitting there" — cleanup should have happened automatically as part of finishing the task, without the user needing to track or close spawned agents themselves.

**How to apply:** Treat "stop the agent" as part of the completion checklist for any background subagent, the same way you'd close a finished tool call — do it as soon as you've confirmed the agent's output is captured (merged, reported, or explicitly obsoleted), not just when the user asks. If an agent's output might still be needed (e.g. waiting on user review before deciding to reuse it), it's fine to leave it idle a bit longer, but don't let idle agents accumulate silently across many turns.
