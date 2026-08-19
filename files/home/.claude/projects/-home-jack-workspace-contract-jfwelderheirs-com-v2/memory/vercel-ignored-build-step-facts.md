---
name: vercel-ignored-build-step-facts
description: "Vercel Ignored Build Step: no fetch creds for other branches, and a skip emits no deployment_status"
metadata:
  node_type: memory
  type: reference
  originSessionId: d27092e5-440d-4db5-abde-165d649b2d05
---

Two Vercel platform facts confirmed (jfwh-v2, 2026-07-17) while trying to skip preview builds on
docs-only PRs. Both are landmines; they gate the deferred design in GitHub issue **#123**.

1. **The `ignoreCommand` environment cannot `git fetch origin/main`.** Vercel's clone at
   ignore-command time has no credentials/refs for other branches, so any script that diffs the
   PR head against the base branch via `git fetch` + `git diff` takes its fail-safe path every
   time (observed: `BUILD (fail-safe): could not fetch origin/main`). To classify "docs-only vs
   base" you need an **authenticated compare** — a fine-grained GitHub token (contents:read) as a
   Vercel env var, calling the GitHub *compare* API — not local git. Do NOT fall back to
   `git diff HEAD^ HEAD` (fails open on multi-commit PRs whose last commit is docs-only).

2. **A skipped build (ignoreCommand exit 0) emits NO GitHub `deployment_status` event.** So a
   workflow triggered on `deployment_status` (here the required `smoke` gate in
   `deploy-smoke.yml`) simply never runs for a skipped deploy — which means a required `smoke`
   context would never report and the PR would block on "Expected". That's why the skip design
   needs a `pull_request`-triggered companion to satisfy the required check for docs-only PRs.

Also learned (repo-captured, not here): a docs-only classifier using `... | grep -q ...` under
`bash -o pipefail` SIGPIPE-fails-OPEN on large diffs — drain stdin instead. See `doc/ci.md` and
the `changes` job in `.github/workflows/ci.yml`. Related: [[jfwh-v2-shared-blob-store-gotcha]].
