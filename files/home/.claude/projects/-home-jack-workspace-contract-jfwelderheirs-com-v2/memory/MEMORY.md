# Memory Index

- [The Architect role (living)](architect-role.md) — READ FIRST in architect sessions: self-evolving archetype, Jack-distillation, priorities, rhythm

- [Confirm locally before prod push](confirm-locally-before-prod-push.md) — main auto-deploys to Vercel; verify locally first
- [jfwh-v2 storage/deploy gotchas](jfwh-v2-shared-blob-store-gotcha.md) — shared public Blob store, env-change-needs-redeploy, pnpm/migrate deploy setup
- [Visualize DAGs as ASCII](feedback-visualize-dags-as-ascii.md) — draw PR/task dependency graphs as plain-text diagrams, not just prose
- [Clean up background agents](feedback-clean-up-background-agents.md) — stop idle subagents once their work is merged/superseded, don't leave them for user to close
- [Auto-merge Dependabot PRs](feedback-auto-merge-dependabot.md) — auto-merge green Dependabot PRs without per-PR LGTM; flag only risky runtime-dep bumps
- [Dependabot wait posture](dependabot-wait-posture.md) — pre-launch: no manual security-bump PRs, wait for Dependabot; revisit at beta
- [Dependabot ignore doesn't clear open PRs](dependabot-ignore-does-not-clear-open-prs.md) — a merged config change needs @dependabot recreate to affect existing PRs
- [Flag PR concerns as PR comments](feedback-flag-concerns-as-pr-comments.md) — post flags on the PR itself, not only in the session, or they get missed
- [No-dash rule scope](feedback-no-dash-rule-scope.md) — no em dashes in human communication only; repo prose (comments, docs, PRs) is exempt
- [Neon preview branch pruning](neon-preview-branch-pruning.md) — standing approval to delete stale preview branches; quota failure mode diagnosis
- [Vercel required-deployment merge blocker](vercel-required-deployment-merge-blocker.md) — removed 2026-07-15; failure signature + GraphQL-only fix if it reappears
- [JFWH project board](jfwh-project-board.md) — board field/option IDs, default-field API immutability gotcha, blocked→Backlog + everything-through-In-review policies
- [Planning tasks need strong models](feedback-planning-tasks-need-strong-models.md) — delegate planning/judgment to Fable/Opus-class agents; Sonnet is for execution
- [Lead with the decision, not context](feedback-lead-with-decision-not-context.md) — ask the crisp question first; don't front-load paragraphs Jack re-derives anyway
- [Compression = pack to principle](feedback-compression-pack-to-principle.md) — reductive editing means packing emanated detail back to its backing principle, not just trim/dedup
- [Vercel Ignored Build Step facts](vercel-ignored-build-step-facts.md) — no fetch creds for other branches; a skip emits no deployment_status (gates issue #123)
- [v1 uploads: sensitive docs](v1-uploads-sensitive-docs.md) — never Read/upload v1 PDF/DOC files to the API; photos OK, local-only text extraction with filters
