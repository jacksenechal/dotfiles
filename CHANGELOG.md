# Changelog

Notable changes to this repo. Newest first.

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
