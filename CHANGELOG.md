# Changelog

Notable changes to this repo. Newest first.

## 2026-08-20 - Hyprland leaves the overlay pattern

Jack noticed that `omarchy menu` -> "input configuration" opens
`~/.config/hypr/input.lua`, whose own header says personal overrides go there, and
asked whether the overlay was duplicating a mechanism Omarchy already provides.
It was.

The overlay pattern earns its keep when the distro's file **carries settings it
will keep updating**, because owning such a file freezes you on a stale baseline.
That is true of `tmux.conf` and `kitty.conf`. It is not true of Hyprland:

| File | Migrations ever touching it | Real settings in the template |
|---|---|---|
| `input.lua` | 1, checksum-guarded, uses `cp` | 0 |
| `bindings.lua` | 1, checksum-guarded, uses `cp` | 0 |
| `looknfeel.lua` | none | 0 |
| `monitors.lua` | none | 4 |
| `autostart.lua` | none | 0 |

Those files are all-comment templates. The actual defaults live in
`$OMARCHY_PATH/default/hypr/` and load first regardless, so owning the override
files cannot cause drift and an overlay buys nothing. It did cost something: the
menu entry opened a base file showing none of Jack's settings.

So `hypr/jack.lua` and `hypr/jack/` are gone, and
`files/desktop/.config/hypr/{input,bindings,looknfeel}.lua` are symlinked directly
like any other tracked file. `hyprland.lua` returns to byte-identical stock, which
also removes the only `mv`-rewritten file from our exposure, and the
`require("hypr.jack")` include line is retired. Two overlay entries remain
(tmux, kitty) rather than three, and Hyprland drops from two layers to one.

The `cp`-versus-`mv` distinction matters and was missed the first time: `cp src dest`
writes *through* a symlink, preserving the inode, while `mv` replaces it. The one
migration that touches these files uses `cp` and skips modified files anyway.

Settings verified unchanged after the move: `compose:ralt`, `repeat_delay 600`,
touchpad `scroll_factor 0.2`, `border_size 0`, `rounding 8`,
`focus_on_activate false`, all three restored keybindings, and the DeathAdder rule
still bound.

## 2026-08-19 - Claude skills reconciled; two roles stopped fighting

Reconciled `~/.claude/skills` before running `claude-base.yaml` on the laptop for
the first time. It was on the pre-split layout: `~/workspace/skills/local` was a
symlink into `agent-tools/skills` from before that repo was split into public and
private halves, so the role's clone of `agent-tools-private` could never have
succeeded. Of the 15 skills the role expects, 5 were linked and only 1 matched.

Nothing local needed rescuing: every source repo was clean with no unpushed
commits. `agent-tools` was 15 commits behind and is now pulled.

Three role fixes, each a defect the reconciliation surfaced:

| Defect | Fix |
|---|---|
| Clone fails against the pre-split symlink | Remove it first; a real directory is left alone |
| `playwright-docker` excluded outright for servers, so workstations lost it | Workstation-only link, gated on the `local` group |
| `update: no` leaves dangling links silently when a skill is added upstream | Report dangling links rather than fixing them silently |

Also resolved a genuine conflict between two roles over the same path. The `files`
role per-file-symlinks everything under `files/home`, producing a real directory
full of symlinks exactly where `claude_skills` wants a whole-directory symlink;
its no-clobber guard then aborted the play before the hook registration ran.

The directory link is right for memory specifically: Claude writes **new** memory
files there, and per-file links leave those as untracked real files, whereas a
directory link captures them in the repo automatically. That inverts the usual
reason for per-file linking, which exists to keep app-written sidecar files *out*
of git. `link_tree` gained a `link_tree_excludes` list and the `files` role now
skips `.claude/projects`.

With the play completing, the shai-hulud PreToolUse hook is registered and
`teammateMode: auto` is enforced. Both were unset before, so the agent-config
protection CLAUDE.md documents is now actually in force.

`~/.claude/skills` holds 18 skills, all resolving. Both playbooks report
`changed=0` on a second run.

The CLAUDE.md em dash rule was also rescoped: it applies to content authored on
Jack's behalf (articles, resumes, emails, posts), not to conversation.

## 2026-08-19 - voxtype rendered per machine

Triaged both voxtype configs against the packaged default at
`/etc/voxtype/config.toml` rather than against each other. The desktop's is a
strict superset - 28 keys against the laptop's 16 and the stock default's 19 -
carrying the whole `[meeting]` tree the laptop omits. So the desktop is now the
baseline, contrary to first assumption.

Only three settings are genuinely machine-dependent:

| Setting | laptop | desktop |
|---|---|---|
| `audio.device` | `default` | `echocancel` (PipeWire sink) |
| `hotkey.enabled` | `false` - Hyprland binds it | `true` |
| `hotkey.key` | n/a | `RIGHTALT` |

Duplicating a 343-line file per host for three keys was the wrong trade, so
`roles/voxtype` renders it from a template with values in `voxtype_machines`
(`group_vars/all.yaml`), keyed on the real hostname. `files/hosts/` keeps the
per-host tree construct for configs that vary throughout rather than in a few
keys; it currently has no inhabitants.

Templating is also the more robust choice here: `voxtype configure` rewrites the
file in place, which a symlink would not survive.

Verified by rendering both variants and comparing parsed key/value pairs: the
desktop render is identical to its previous config, and the laptop render changes
no existing value. The laptop does pick up two things from the baseline - the
explicit `[meeting]` block, whose rendered values match what it was already
inheriting implicitly, and `output.shift_enter_newlines = true`, which it was not
setting before. That one is a real behaviour change.

Two laptop-only preferences are preserved as machine overrides rather than folded
into the baseline: `notification.on_transcription = false` and `type_delay_ms = 1`.
If they turn out to be stale rather than deliberate, deleting those two lines from
`voxtype_machines` adopts the baseline.

## 2026-08-19 - Overlays generalised across distros

- **`~/.bashrc` is now a first-class overlay.** The `source ~/.bashrc_jack` line
  had been a one-off `lineinfile` in the `files` role since long before the
  overlay pattern was named. It moved to `group_vars/all.yaml` as a universal
  entry, so it runs through the same engine, with the same marker and the same
  health check, on every host. The `files` role now only symlinks; wiring is the
  overlays role's job.
- **New `debian` role** covering Debian and Ubuntu (oracle, homebox). Its
  manifest is empty on purpose: apt does not write into `$HOME`, so the universal
  bash entry is all those hosts need. It exists as the extension point and runs
  the symlink health check. Same conclusion as `arch`; Omarchy remains the outlier.
- **Removed `archive/omarchy-3.8.5/`.** Its tweaks were carried into the overlay
  files, its drift was dropped, and the monitor layout was declined. Recover with
  `git checkout b6d6680 -- archive/omarchy-3.8.5` - the package lists are the part
  with residual value. The now-pointless `exclude:` guarding it was dropped from
  `.pre-commit-config.yaml`.

### Known state, not yet fixed

The symlink model is not actually in force on the Omarchy laptop: **6 of 47
tracked files are symlinks**, and those six are the overlay files. The rest are
detached copies or absent, so `files/` and `$HOME` have been drifting apart
silently. Running the `files` role would fix that, but it symlinks with
`force: true`, and two files are newer on disk than in the repo:

| File | Newer side | Action before linking |
|---|---|---|
| `.gitconfig` | live | live has `gh auth git-credential` helpers added 2026-05-02; copy into repo first |
| `.config/voxtype/config.toml` | live | 266 differing lines; needs a real read-through |

Safe to link as-is (repo is ahead): `.bash_aliases_jack`, `.gitignore`,
`.claude/CLAUDE.md`, `.tmux.conf`.

## 2026-08-18 - Config overlays for distro-owned files

### Why

The `files` role symlinks tracked configs into `$HOME`, which is what makes
"edit the live file, `git diff` shows it, commit" work. That model breaks for any
config the distro also writes to.

Upgrading this machine to Omarchy 4 ("Quattro") made the failure concrete.
Omarchy ships 78 update migrations; 26 write into `~/.config`. Of the ones that
rewrite a file in place, **ten use `mv "$tmp" "$file"`** and only three of its
`sed` calls pass `--follow-symlinks`. `mv` replaces the inode, so a symlink into
this repo is destroyed and the live file silently stops being tracked. Quattro
also converted Hyprland's config from `.conf` to Lua, orphaning
`~/.config/hypr/*.conf` - the files were never deleted, just no longer read,
which is why the loss was silent.

### What changed

Ownership is now split rather than contested.

- **The distro keeps its own files.** `~/.config/tmux/tmux.conf`,
  `~/.config/kitty/kitty.conf` and `~/.config/hypr/*.lua` are untracked again and
  restored to stock. Migrations rewrite them freely and upstream improvements
  keep arriving. Omarchy's migrations checksum these files and skip modified
  ones, so keeping them pristine is what keeps them current.
- **Personal config moved into overlay files the distro has never heard of**,
  tracked here and symlinked in by the `files` role, loaded last so they win:
  - `files/home/.config/tmux/local.conf`
  - `files/desktop/.config/kitty/local.conf`
  - `files/desktop/.config/hypr/jack.lua` + `hypr/jack/{bindings,input,looknfeel}.lua`
- **New `overlays` role** - a small engine that asserts the one include line
  connecting a base config to its overlay, via each app's own mechanism
  (`source-file`, `include`, `require`).
- **New `arch` and `omarchy` roles.** `arch` is the baseline: pacman never writes
  into `$HOME`, so nothing needs patching and the repo owns base configs outright.
  `omarchy` depends on `arch` and adds the three include assertions plus a
  `post-update.d` hook, generated from the same manifest, that re-adds any
  include line a migration drops. The hook only appends, so it cannot destroy
  configuration. Both roles are no-ops off their own distro.

### Also in this change

- `files/desktop/.config/kitty/kitty.conf` removed - superseded by `local.conf`.
  Its dead `include ./theme.conf` (the file never existed) is gone, so kitty now
  picks up Omarchy's theme. Its `listen_on unix:/tmp/kitty.sock` was dropped in
  favour of Omarchy's per-pid socket, which `omarchy-launch-tui` requires;
  nothing referenced the old socket.
- `files/home/.tmux.conf` no longer duplicates the customizations. It keeps the
  base settings for non-Omarchy hosts and sources the same shared
  `~/.config/tmux/local.conf`, so customizations live in exactly one file.
- Fixed a long-dead tmux binding: the vim-split-aware `C-\` pane switch was
  guarded by an `if-shell` test that shelled out to `bc`, which is not installed,
  so the guard failed closed and the binding was never set. tmux is 3.7 here; the
  version guard is gone.
- `bind k` (clear history) shadows Omarchy's `prefix+k` "Kill window". Kill a
  window with `prefix+&`.

### Not carried forward

Hyprland monitor layout. Omarchy 4's generic `preferred/auto` at scale 1.25
handles the eDP-1/DP-1 pair without explicit `monitorv2` blocks.
