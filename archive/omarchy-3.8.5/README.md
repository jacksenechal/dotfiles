# Omarchy 3.8.5 config snapshot

Captured 2026-08-18, immediately before upgrading to Omarchy 4 ("Quattro").

This is an **inert archive**, not a deployed config tree. Nothing here is
symlinked into `~`. The Ansible `files` role only walks `files/home` and
`files/desktop`, so it never touches `archive/`. That is deliberate — see
[Why this is not in the symlinked tree](#why-this-is-not-in-the-symlinked-tree).

## Contents

| Path | What it is |
|---|---|
| `files/` | Verbatim copies of every `~/.config` file that differed from the Omarchy 3.8.5 default |
| `diffs/` | Unified diff of each file against its Omarchy default (`~/.local/share/omarchy/config/…`) |
| `MANIFEST.txt` | Flat list of the 19 captured files |
| `system.txt` | Omarchy version, git tag, active theme, kernel |
| `pkglist-explicit.txt` | `yay -Qqe` — 216 explicitly-installed packages |
| `pkglist-foreign.txt` | `pacman -Qqm` — 10 AUR / foreign packages |

The **diffs matter more than the files**. Omarchy 4 rewrites the defaults, so a
verbatim `waybar/style.css` from 3.8.5 is a fossil. The patch tells you what you
actually changed and why.

## What survives the Quattro upgrade

Omarchy 4 rebuilds the desktop shell in Quickshell and drops Waybar, Walker,
Mako, SwayOSD, hyprlock, and hypridle as separate components. Omarchy's own
internals also move from a git checkout in `~/.local/share/omarchy/` to pacman
packages. So the tweaks split three ways.

### 1. Real tweaks, still relevant

Re-apply these by hand against the new defaults.

| File | What you changed |
|---|---|
| `hypr/monitors.conf` | `monitorv2` blocks: eDP-1 at 1.33333 scale positioned `880x1800`, DP-1 (4K) at 1.2 scale at `0x0`. Lid-switch binds present but commented out. |
| `hypr/input.conf` | `kb_layout = us`, compose key on right Alt, `repeat_delay = 600`, natural scroll on touchpad *and* mouse, touchpad `scroll_factor = 0.2`, a per-device block for the Razer DeathAdder (`sensitivity = -0.5`), and three 3-finger gestures (workspace / fullscreen / SUPER-resize). |
| `hypr/bindings.conf` | `$terminal` and `$browser` variables; SUPER+SHIFT+Q → qutebrowser; SUPER+SHIFT+T → btop; CTRL+ALT+Left/Right → workspace prev/next; F9 press/release → `voxtype record start`/`stop`. |
| `hypr/looknfeel.conf` | `border_size = 0`, `rounding = 8`, `misc { focus_on_activate = false }`. |
| `hypr/hyprland.conf` | Sources an extra `~/.config/hypr/envs.conf`; commented-out hyprexpo plugin block. |
| `kitty/kitty.conf` | A full override, not a tweak — Fira Code 11pt, own `./theme.conf` include, `background_opacity 0.9` with `background_blur 5`, powerline tab bar. Independent of Omarchy. |
| `git/config` | User identity (name + email). |
| `btop/btop.conf` | `update_ms = 1000`, `proc_sorting = "cpu direct"`. Everything else in that diff is upstream drift (see below). |
| `tmux/tmux.conf` | Simplified reload bind and a status-right without the zoom flag. |


### 2. Dead on arrival in Quattro

Kept for reference only. The software these configure is gone.

- `waybar/config.jsonc`, `waybar/style.css` — replaced by the Quickshell bar.
  Nothing here is worth carrying: the diff is font drift, a margin value, and
  modules the newer default added.
- `swayosd/config.toml`, `swayosd/style.css` — font drift, plus a relative
  `style.css` path.
- `hypr/hyprlock.conf` — font drift and a stray whitespace character.

### 3. Drift, not intent

These differ because the file was never refreshed against a newer Omarchy
default, so the diff shows Omarchy's *newer* lines as removals. Do not re-apply.

**The font is drift.** `CaskaydiaMono Nerd Font` was Omarchy's own earlier
default; Omarchy later moved to `JetBrainsMono Nerd Font`. It was never a
deliberate choice, so it needs no carrying forward — and on Omarchy 4 the font
is one setting (`omarchy font set`) rather than five hand-edited files. This
accounts for the *entire* difference in `ghostty/config` and
`swayosd/style.css`, and all but a reordered `[terminal]` block in
`alacritty/alacritty.toml`.

- `btop/btop.conf` — local file is the btop v1.4.6 template, default is v1.4.7.
  Only `update_ms` and `proc_sorting` are yours.
- `fastfetch/config.jsonc` — Omarchy tightened an uptime shell one-liner; local
  copy has the older verbose form.
- `hypr/xdph.conf` — trailing-whitespace difference only. No real change.
- `hypr/hyprlock.conf` — font plus one whitespace character. Nothing to keep.
- `alacritty/alacritty.toml`, `ghostty/config`, `swayosd/*` — font, as above.
- `waybar/*` — font, a margin value, and a `custom/weather` module the newer
  default added. Dead on arrival regardless.
- `uwsm/env` — local `PATH` lacks the `:$HOME/.local/bin` suffix the current
  default adds. Drift: the suffix was added upstream after this file was last
  refreshed. Take the new default.

## Why this is not in the symlinked tree

The `files` role symlinks each tracked file into `$HOME`, so editing the live
file edits the repo file. That works when only you write the file. Omarchy also
writes these files, in two different ways:

- `omarchy-refresh-config` uses `cp -f`, which writes *through* a symlink. The
  link survives and `git diff` shows the change. Harmless.
- Migrations use `sed -i`, which replaces the file's inode:

  ```sh
  sed -i 's/fingerprint:enabled = .*/fingerprint:enabled = false/' ~/.config/hypr/hyprlock.conf
  sed -i '/^exec-once = uwsm-app -- swayosd-server$/d' ~/.config/hypr/autostart.conf
  ```

  Each of these silently converts the symlink back into a regular file and
  orphans the repo copy. Nothing errors; the repo just quietly stops tracking
  reality.

The Quattro upgrade runs a large batch of migrations, which makes it the worst
possible moment to have Omarchy-managed configs under symlink management.

If you later want live tracking, do it after Quattro settles, restrict it to
files Omarchy does not own (`kitty/kitty.conf` is the clean case), and re-run
the role after any `omarchy update`.

## Upgrade path (verified 2026-08-18)

- `/etc/pacman.conf` and `/etc/pacman.d/mirrorlist` already match Omarchy's
  **stable** channel byte-for-byte. No channel change is needed.
- `master` is the 3.x line; it sits at `f4378f0d` ("Omarchy 3.8.5"), which is
  untagged. The `v4.0.0` tag is **not** an ancestor of `master` — Quattro lives
  on the `quattro` branch, because 4.0 stops being a git checkout at all and
  becomes pacman packages.
- The upgrade is therefore not a `git pull`. Omarchy 3.8.5 ships
  `omarchy-upgrade-to-quattro` (`omarchy upgrade to quattro`), which is
  self-contained, defaults to the stable channel, and detects the installed
  channel from the mirrorlist.
- `omarchy update available` reporting **v4.0.0-beta3** is a version-sort bug,
  not a channel problem. `omarchy-update-available` ranks remote tags with
  `sort -V | tail -1`, and `sort -V` orders `v4.0.0` *before* `v4.0.0-beta3`, so
  the prerelease always wins. Ignore it.

## Restoring

There is no restore script, on purpose — the Omarchy 4 defaults these patch
against no longer exist. Read `diffs/<file>.patch`, decide whether the change is
still wanted, and apply it to the new default by hand.

For the package list:

```sh
# what's missing on a rebuilt machine
comm -13 <(yay -Qqe | sort) <(sort pkglist-explicit.txt)
```
