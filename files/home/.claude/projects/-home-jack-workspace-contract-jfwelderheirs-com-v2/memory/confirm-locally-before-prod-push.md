---
name: confirm-locally-before-prod-push
description: Workflow rule for jfwh-v2 — verify changes locally before pushing to prod (Vercel auto-deploys main)
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e699e33e-1c20-4c50-a5d0-c27a9943907c
---

For the JFWH (jfwh-v2) project, always confirm a change works **locally** before pushing — and don't push to prod without that verification (check with Jack when unsure).

**Why:** `git push` to `main` auto-deploys to production on Vercel (`jfwh-v2.vercel.app`). There is no PR flow right now, so a push goes straight to prod. Jack explicitly asked to confirm good local state first.

**How to apply:** Make the change, run it locally (dev server / build / targeted test) and verify the actual behavior, then push. For risky or user-facing changes, confirm with Jack before the push. Hold doc-only commits locally too unless cleared. See [[jfwh-v2-shared-blob-store-gotcha]].
