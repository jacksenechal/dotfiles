# overlays role

Wires this repo's *overlay files* into config files owned by the distro.

## The problem

The `files` role symlinks tracked configs into `$HOME`, so editing the live file
edits the repo and `git diff` always shows the truth. That breaks down for any
config the distro also writes to. Omarchy is the sharp case: of its 78 update
migrations, 26 write into `~/.config`, and of those that rewrite a file in place,
ten use `mv "$tmp" "$file"`. `mv` replaces the inode, so the symlink is gone and
the repo silently stops tracking the live file. Only three of its `sed` calls
pass `--follow-symlinks`.

## The shape of the fix

Split ownership instead of fighting over it.

- **The distro keeps its own file.** `~/.config/tmux/tmux.conf`,
  `~/.config/kitty/kitty.conf`, `~/.config/hypr/*.lua` stay as ordinary,
  untracked files. Migrations rewrite them freely, and you keep receiving
  upstream improvements. Omarchy's migrations even checksum these files and skip
  ones you have modified, so leaving them pristine is what keeps them current.
- **Your configuration lives in a file the distro has never heard of**, tracked
  in this repo and symlinked in by the `files` role. It is loaded *last*, so it
  wins.
- **This role adds the one line that connects them**, using whatever include
  mechanism the app already has.

Overlay *content* is identical on every distro, so it lives in the normal
`files/home` and `files/desktop` trees. Only the wiring is distro-specific, and
that is what `vars/<profile>.yaml` describes.

| App | Include mechanism | Overlay file |
|---|---|---|
| tmux | `source-file -q` | `~/.config/tmux/local.conf` |
| kitty | `include` | `~/.config/kitty/local.conf` |
| Hyprland | `require()` | `~/.config/hypr/jack.lua` -> `hypr/jack/*.lua` |

## When NOT to use an overlay

The pattern costs something: a second layer to reason about, and a base file that
no longer holds your settings even though the distro's own tooling points at it.
Pay that only when it buys something.

**The test: does the distro's file carry settings it will keep updating?**

- **Yes → overlay.** `~/.config/tmux/tmux.conf` and `~/.config/kitty/kitty.conf`
  ship real configuration that Omarchy improves through migrations. Owning them
  freezes you on the baseline you copied, which is exactly the drift that had to
  be cleaned up after the Omarchy 4 upgrade.
- **No → just symlink it.** Omarchy's `hypr/input.lua`, `bindings.lua` and
  `looknfeel.lua` contain **zero** settings; they are all-comment templates, and
  the real defaults live in `$OMARCHY_PATH/default/hypr/` and load first
  regardless. Owning them cannot cause drift, so an overlay buys nothing and
  costs the `omarchy menu` entry for "input configuration", which opens the base
  file and would show none of your settings.

Migration exposure confirms it rather than driving it. `looknfeel.lua`,
`monitors.lua` and `autostart.lua` have never been touched by a migration;
`input.lua` and `bindings.lua` by exactly one, which is checksum-guarded (it skips
modified files) and uses `cp`, which writes *through* a symlink instead of
replacing it. Only `hyprland.lua` is `mv`-rewritten, and it stays Omarchy's,
fully stock, because it already requires the override files by name.

## Residual risk, and the guard

The include line itself is the only thing exposed - one line per app. If a
migration rewrites a base file wholesale, the line goes with it and the overlay
silently stops loading.

On Omarchy the role installs `~/.config/omarchy/hooks/post-update.d/`, generated
from the same manifest, which re-asserts any missing line straight after
migrations run. It only ever appends, so it cannot destroy anything, and it warns
if a tracked overlay symlink has been replaced by a regular file.

## Profiles

`overlay_profile` selects the manifest. It defaults to `omarchy` when
`/usr/share/omarchy` exists and `generic` otherwise; set it in `host_vars` to
override.

`generic` is intentionally empty: on a plain server this repo owns
`~/.tmux.conf` outright, so the `source-file` line is simply part of the tracked
file and no assertion is needed.
