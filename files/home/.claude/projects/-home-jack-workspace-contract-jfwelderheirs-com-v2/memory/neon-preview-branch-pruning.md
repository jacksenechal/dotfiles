---
name: neon-preview-branch-pruning
description: Standing approval to proactively delete stale Neon preview branches in jfwh-v2-preview; how to diagnose the quota failure mode
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9fb810d2-7324-4a4e-b9af-f1c712f57b38
---

Jack gave standing approval (2026-07-15) to proactively delete stale Neon preview branches in the `jfwh-v2-preview` project (id `odd-pond-48886625`) via the Neon MCP server, without asking each time.

**Why:** The Vercel-managed Neon integration cleans up preview branches on Vercel deployment deletion (retention-based, can lag months), so branches from closed/merged PRs pile up against the free plan's 10-branch limit. When the limit is hit, every preview deployment fails instantly (~1s, no build logs) with `BUILD_FAILED` / "Resource provisioning failed", which blocks PR merges (a successful preview deployment is required by branch protection).

**How to apply:** A branch is stale when its `preview/<git-branch>` name maps to a PR that is closed/merged. Never delete `main` (default) or branches for open PRs. Diagnose with `describe_project` on the preview project; delete with `delete_branch`; then redeploy the blocked PR's preview (`vercel redeploy <url>`). A PR-close GitHub Action (`neondatabase/delete-branch-action`) should make this rare. Only the preview project holds synthetic data; never touch the prod project's branches (`jfwh-v2-neon`, id `twilight-leaf-05852094`) without asking.
