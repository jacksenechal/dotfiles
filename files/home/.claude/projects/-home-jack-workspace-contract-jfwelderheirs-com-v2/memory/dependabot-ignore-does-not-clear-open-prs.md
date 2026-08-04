---
name: dependabot-ignore-does-not-clear-open-prs
description: A merged Dependabot config change (ignore/groups) does nothing to already-open PRs — force @dependabot recreate
metadata:
  node_type: memory
  type: project
  originSessionId: 3b5e1612-9b9a-4c84-b2e4-63548026ec5f
---

Merging a change to `.github/dependabot.yml` (an `ignore` rule, a `groups` change, etc.) has **no retroactive effect on PRs Dependabot has already opened**. The new config only applies the next time Dependabot *evaluates* that dependency, which on jfwh-v2's `interval: "weekly"` schedule can be days away. An existing PR keeps whatever it was built with, and (if nothing else is red) can become merge-eligible the moment the config was supposed to prevent.

To apply new config to an open PR now, comment **`@dependabot recreate`** on it. `@dependabot rebase` is not enough — rebase replays the existing changeset onto new main; recreate rebuilds the group against current config. On this repo a recreate took ~18 min to produce a new commit.

**Concrete instance (2026-07-15/16):** #100 merged an `ignore` for `sharp >=0.35.0` at 23:59Z. #93 (the npm-minor-patch group) had its last commit at 23:54Z — five minutes earlier — so it had *never* been evaluated against the ignore and still carried the dangerous `sharp 0.34.2 -> 0.35.3` bump (the exact bump that caused the #71 prod outage). #100 was never going to clear #93 on its own. `@dependabot recreate` rebuilt it to `sharp 0.34.2 -> 0.34.5` (a patch *within* the running line, 0.35.x correctly excluded), which then verified green and merged.

**Why the scoped ignore mattered:** the ignore is `versions: [">=0.35.0"]`, not a bare `dependency-name: "sharp"`. The recreate proving it still proposes 0.34.5 confirmed the scoping works — it blocks the broken 0.35 line while still allowing patches (incl. future security patches) on 0.34.x. A bare `dependency-name` would have silently suppressed ALL future sharp updates including CVE fixes, because `ignore` filters security-update PRs too (see the dependabot.yml header comment on main, and [[jfwh-v2-shared-blob-store-gotcha]]-adjacent #92 writeup).

**How to apply:** whenever you land a Dependabot config change intended to affect a currently-open PR, immediately `@dependabot recreate` that PR — don't assume the merge cleaned it up, and verify the rebuilt diff actually reflects the new rule. The staleness is only harmless if some *other* required check independently catches what the config was meant to prevent (here `smoke` would have caught the sharp bump anyway). If the config guards something CI/gates can't detect, a stale open PR is a real hole. Relates to [[feedback-auto-merge-dependabot]].
