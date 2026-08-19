---
name: jfwh-v2-shared-blob-store-gotcha
description: jfwh-v2 storage/deploy gotchas — shared public Blob store across local+prod; env changes need redeploy
metadata:
  node_type: memory
  type: project
  originSessionId: e699e33e-1c20-4c50-a5d0-c27a9943907c
---

jfwh-v2 (Payload + Vercel + Neon + Vercel Blob) operational gotchas observed during Phase 0:

- **Blob storage is now split into THREE stores (as of 2026-07, task #13) — the old "shared local+prod store" is fixed.** `BLOB_READ_WRITE_TOKEN` is scoped: **Production** → prod public assets store; **Preview + Development** → the `jfwh-v2-preview` public store (so previews AND local dev write there, never prod media). A separate **private backup store** → `BACKUP_BLOB_READ_WRITE_TOKEN` scoped **Production** only, reserved for the deferred offsite-backup design (no code consumes it yet). Payload's adapter only reads `BLOB_READ_WRITE_TOKEN` (`src/payload.config.ts`). See `doc/preview-environments.md`.
- **Preview DB = a SEPARATE Neon project (`jfwh-v2-preview`), not prod.** The Vercel-managed Neon integration (scoped Preview-only, per-preview branching on) creates a COW branch `preview/<git-branch>` per PR from that project's synthetic-seeded default and injects `POSTGRES_URL` at deploy time; no CI credentials. Production stays on the prod Neon project (its production branch is the DR root). Local dev still uses **docker Postgres** (`docker-compose.yml`, db `jfwh`, port 54320) — the preview DB integration is Preview-scoped so `vercel env pull` does not override local `POSTGRES_URL`. Reseed the preview default with `payload migrate` + `pnpm run seed:fixtures`.
- **The Blob store must be PUBLIC** — the `@payloadcms/storage-vercel-blob@3.82` adapter only supports `access:'public'`. Do **not** set `addRandomSuffix: true` (it 404s every image size by desyncing URLs from blob object names).
- **Env-var changes don't reach an already-built deployment** — after changing storage/env, you must redeploy or the running app keeps the old (possibly deleted) token.
- **Vercel uses pnpm only because `pnpm-lock.yaml` is committed**; `vercel.json` `buildCommand` is `pnpm run ci` (`payload migrate && build`) so Neon migrations run at deploy.
- A long-lived stale `next dev` process can hold port 3000 and serve old config — kill the PID via `fuser 3000/tcp` when restarts seem to have no effect.

See [[confirm-locally-before-prod-push]].
