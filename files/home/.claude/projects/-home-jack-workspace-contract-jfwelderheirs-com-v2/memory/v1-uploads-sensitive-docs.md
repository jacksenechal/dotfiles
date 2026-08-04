---
name: v1-uploads-sensitive-docs
description: Never Read/upload v1 WP document files (PDF/DOC/XLS) to the API — sensitive family financial/legal content; photos are OK
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 08e986d2-86c0-4aae-b992-378685f4a29a
  modified: 2026-07-29T05:25:33.400Z
---

The WordPress archive at `../v1/local/app/public/wp-content/uploads/` (and the DB dump in `../v1/`) contains sensitive family documents: board packets, partnership agreements, sharing ratios, royalty reports, meeting minutes.

**Why:** Reading a file with the Read tool (or having a subagent view it) uploads its content to the API. Jack flagged this as off-limits for the document files (2026-07-28). It's the same class of concern as the "member PII never lands in repo/fixtures/logs" rule in the migration plan ([[jfwh-v2-shared-blob-store-gotcha]] covers the storage side).

**How to apply:** Photographic images (jpg/png) may be viewed for design/triage work. PDF/DOC/XLS/etc. must NOT be Read or given to subagents — process locally in bash (`pdftotext | grep` with tight filters) only when necessary, surface filenames for Jack to review himself, or ask. This applies to the Phase 1 migration task (007/#137) dry runs and any design/asset work.
