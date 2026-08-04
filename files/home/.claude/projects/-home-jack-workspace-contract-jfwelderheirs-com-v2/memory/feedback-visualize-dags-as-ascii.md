---
name: feedback-visualize-dags-as-ascii
description: "When discussing a DAG of PRs, tasks, or dependencies, draw a simple ASCII graph rather than describing it in prose/lists only."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 52a5b591-0903-4c16-9c09-486d406d8de5
---

When explaining a DAG-shaped structure (PR dependency chains, task dependency graphs, branch/merge topology), include a simple ASCII diagram, not just prose or a bulleted list.

**Why:** requested during the jfwh-v2 CCPM trial run when explaining a multi-PR branching/merge-order situation (PRs #2/#7/#8 with blocked/clean states) — prose-only explanation of DAG shape was harder to follow than a visual would be.

**How to apply:** Nothing fancy — a plain-text box/arrow diagram showing nodes and edges (e.g. branches off `main`, merge order, blocked/ready states) is enough. Applies broadly, not just to this project: any time the structure being discussed is a graph/dependency chain rather than a flat list.
