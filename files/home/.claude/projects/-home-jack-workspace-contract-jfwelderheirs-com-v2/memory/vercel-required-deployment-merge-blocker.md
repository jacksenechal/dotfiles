---
name: vercel-required-deployment-merge-blocker
description: "jfwh-v2 main once required an \"active\" Preview deployment to merge; removed 2026-07-15 after it blocked green PRs. GraphQL-only field to see/change."
metadata: 
  node_type: memory
  type: project
  originSessionId: 76c3446b-7a73-4a08-a4a3-b3229fc89dc9
---

jfwh-v2's `main` branch protection rule (GraphQL `BPR_kwDOSpOeas4EwoS9`) used to have `requiresDeployments: ["Preview"]`. Vercel marks preview deployments Inactive when superseded, so under busy PR traffic merges failed with "Missing successful active Preview deployment" even when every check was green, and `gh pr merge --admin` cannot bypass a required-deployments rule. It was redundant with the required `ci` check (same commit, same build, plus tests), so Jack had it **permanently removed on 2026-07-15** (after it stalled PR #83). Current gates: `ci` + Socket checks, strict up-to-date.

**Why:** If it ever reappears (or on another repo), the failure signature is a green PR refusing to merge with that error.

**How to apply:** The field is invisible in REST `branches/main/protection` (`required_deployments: none`); only the GraphQL `branchProtectionRules` query shows it. Fix via `updateBranchProtectionRule(input:{branchProtectionRuleId:..., requiresDeployments:false, requiredDeploymentEnvironments:[]})`.
