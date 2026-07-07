# NPM / supply-chain security requirements

Mandatory for all package-manager work. Self-propagating npm worms (e.g. mini-shai-hulud,
active as of 2026-05) spread via dependency install/lifecycle scripts and freshly-published
malicious versions, so the defenses below are about (a) not auto-running untrusted scripts,
(b) not installing brand-new versions, and (c) scanning before trusting.

## 1. Match the project's package manager
- Check the `packageManager` field in `package.json` first and use that exact tool. Do NOT
  substitute `npm` into a pnpm/yarn project.
- WHY: protective `.npmrc` keys are dialect-specific. pnpm keys (`minimum-release-age`,
  `only-built-dependencies`/`onlyBuiltDependencies`) are SILENTLY IGNORED by npm — npm prints
  "Unknown project config" and proceeds with zero protection. Verify the key is honored, e.g.
  `pnpm config get minimum-release-age` should echo your value.

## 2. Required hardening settings
Always, every ecosystem (`~/.npmrc`):
- `strict-ssl=true`  — NEVER set `strict-ssl=false`; it disables registry TLS verification.
- `ignore-scripts=true` — npm honors this globally; blocks dependency lifecycle scripts.
- Keep registry auth tokens out of shared output. Rotate any token that gets exposed.

pnpm projects (`.npmrc`):
- `minimum-release-age=20160`  — 14 days, in MINUTES (7 days = 10080). Default to 14; only drop
  to 7 if a needed package is too new, and prefer `minimum-release-age-exclude[]=<pkg>` for a
  single exception rather than lowering the global floor.

Dependency build/install scripts (the actual worm vector) — use an ALLOWLIST, don't blanket-allow:
- pnpm: set `pnpm.onlyBuiltDependencies` in `package.json` (or `pnpm-workspace.yaml`) to ONLY the
  packages that genuinely need native builds (e.g. `sharp`, `esbuild`, `unrs-resolver`). Everything
  else is blocked. Empty array blocks all (but breaks native pkgs). This is the real control.
- npm: `ignore-scripts=true` (above).
- NOTE: pnpm's `enable-pre-post-scripts` is NOT a supply-chain control — it only governs whether
  pnpm runs YOUR OWN `pre`/`post` script hooks (e.g. `postbuild: next-sitemap`). Do not disable it
  for "security"; doing so silently breaks legitimate project build steps.

## 3. Validate before you trust (Socket)
- Socket CLI scanning (incl. `socket package score`) requires an API token as of v1.1.x — run
  `socket login` first (interactive token paste; there is no anonymous scanning).
- Install Socket itself with bootstrap trust: a scanner can't scan itself before it exists, so
  pin to a version already older than your min-age window and disable scripts:
  `npm install -g @socketsecurity/cli@<version-aged-past-14d> --ignore-scripts`
- npm/npx: use the wrappers — `socket npm install`, `socket npx <pkg>`.
- pnpm: there is NO `socket pnpm` wrapper. Either scan the manifest before installing
  (`socket scan create` against `package.json`), or `pnpm install` (protected by §2) then scan the
  resolved tree with `socket scan create` / `socket ci` (CI alias: fails on an unhealthy report).

## 4. NEVER use `npx`
- No minimum-age check on npx packages. Install locally as a devDependency first
  (`pnpm add -D <pkg>` / `npm install -D <pkg>`), then run via a package script or
  `pnpm exec` / `npm exec --no-install`. Never `npx`.

## 5. NEVER pipe remote scripts to a shell
- No `curl | bash` (and no `wget|sh`, `iex(...)`, etc.).
- Use `vet <URL>`: the installed `vet` (v1.x, system/AUR) is "a safer way to run remote scripts" —
  it downloads the script and lets you review before executing. IMPORTANT: `vet` is a remote-script
  runner, NOT a dependency scanner; use Socket for dependency vetting.
- Workflow: download -> review with `vet` -> run static checks (socket.dev / snyk) -> read it to
  confirm intent -> ONLY THEN run it.
