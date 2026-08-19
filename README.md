# Usage

## Setup and periodic maintenance
```sh
ansible-playbook -l localhost[,otherhost,...] -K dotfiles-base.yaml
```

### Just nvim
```sh
ansible-playbook -l localhost -t nvim -K dotfiles-base.yaml
```

## Config overlays for distro-owned files

Most tracked files are symlinked straight into `$HOME` by the `files` role, so
editing the live file edits the repo. That does not work for configs the distro
also rewrites - Omarchy's update migrations mostly use `mv`, which replaces the
file and destroys the symlink without saying so.

For those, ownership is split: the distro keeps its own base config untracked,
personal settings live in a separate **overlay** file that is tracked and
symlinked, and the `overlays` role asserts the single line that connects them.
See `roles/overlays/README.md` for the mechanics and `CHANGELOG.md` for why.

**Most tracked files do not need this.** Direct symlinking is the default and
covers the large majority of `files/` - nvim, zsh, gh, yamllint, systemd units,
gvim, alsa, pipewire and the rest. A file only becomes an overlay when something
other than this repo also writes to it.

Four do today:

| Where | Base config (not tracked) | Overlay (tracked here) | Wired by |
|---|---|---|---|
| everywhere | `~/.bashrc` | `~/.bashrc_jack` | `group_vars/all.yaml` |
| Omarchy | `~/.config/tmux/tmux.conf` | `~/.config/tmux/local.conf` | `roles/omarchy` |
| Omarchy | `~/.config/kitty/kitty.conf` | `~/.config/kitty/local.conf` | `roles/omarchy` |
| Omarchy | `~/.config/hypr/*.lua` | `~/.config/hypr/jack.lua` | `roles/omarchy` |

Bash is the oldest of these and predates the pattern having a name: `~/.bashrc`
is seeded from `/etc/skel` and carries distro-specific setup, so the repo tracks
`.bashrc_jack` and asserts one `source` line instead of owning the file.
`.bash_aliases_jack` rides along, sourced by `.bashrc_jack`.

Only Omarchy needs distro-specific entries. On vanilla Arch, Debian and Ubuntu
neither pacman nor apt writes into `$HOME` - base configs are seeded once from
`/etc/skel` or by the app itself and never upgraded behind your back - so
`roles/arch` and `roles/debian` carry empty manifests and exist as the extension
point plus a symlink health check.

Day to day nothing changes: edit the overlay file at either path, `git diff`
shows it, commit.

### Adopting this on another machine

The playbook deliberately does **not** reset distro base configs to stock - that
is destructive and only you can tell a real customization from stale drift. Do it
by hand, in this order.

**On a non-Arch host (oracle, homebox) there is nothing to migrate.** The `arch`
and `omarchy` roles end immediately off their own distro. `~/.tmux.conf` is still
the base config there and now sources the shared overlay, so just run the
playbook and confirm tmux still behaves:

```sh
ansible-playbook -l oracle dotfiles-base.yaml
tmux kill-server; tmux new -d \; show-options -g | grep history-limit   # expect 100000
```

**On another Omarchy or Arch desktop:**

1. **Snapshot first.** These are one-way steps.
   ```sh
   omarchy snapshot create                     # Omarchy only; needs sudo
   cp -a ~/.config/{hypr,tmux,kitty} /tmp/preoverlay-backup/
   ```

2. **Diff your base configs against stock** and copy anything you actually want
   into the overlay files. Anything not in an overlay is about to be lost.
   ```sh
   for f in tmux/tmux.conf kitty/kitty.conf hypr/bindings.lua hypr/input.lua hypr/looknfeel.lua; do
     echo "=== $f ==="
     diff -u "/usr/share/omarchy/config/$f" "$HOME/.config/$f"
   done
   ```
   Split what you find three ways: real customizations (move to the overlay),
   drift where you never refreshed against a newer default (drop), and settings
   the current default already matches (drop - a phantom override silently fights
   future upstream changes).

3. **Hand the base configs back to the distro.** Each writes a `.bak.<epoch>`
   beside the original.
   ```sh
   for f in tmux/tmux.conf kitty/kitty.conf \
            hypr/bindings.lua hypr/input.lua hypr/looknfeel.lua hypr/hyprland.lua; do
     omarchy refresh config "$f"
   done
   ```

4. **Run the playbook.** This symlinks the overlay files in and asserts the
   include lines. It is idempotent - a second run reports `changed=0`.
   ```sh
   ansible-playbook -l localhost dotfiles-base.yaml
   ```

5. **Verify.**
   ```sh
   hyprctl reload && hyprctl configerrors        # expect no output
   omarchy menu keybindings --print | grep -i qute
   tmux kill-server; tmux new -d \; show-options -g | grep history-limit
   ~/.config/omarchy/hooks/post-update.d/10-dotfiles-overlay   # expect silence
   ```
   The hook printing `re-asserted ...` means an include line was missing; that is
   it doing its job, not an error.

6. **Delete the backups** once you are satisfied, along with any orphaned
   pre-Quattro `~/.config/hypr/*.conf`, which Hyprland no longer reads.

## Bitwarden Secrets Manager sync

This repo now has a `secrets` role that restores these home-directory secrets from Bitwarden Secrets Manager:

- `~/.ssh/id*`
- `~/.ssh/config*`
- `~/.config/keys/*` except `BWS_ACCESS_TOKEN`

### Recommended bootstrap token location

Recommended:
```sh
mkdir -p ~/.config/bitwarden-sm
chmod 700 ~/.config/bitwarden-sm
printf '%s\n' 'YOUR_BWS_ACCESS_TOKEN' > ~/.config/bitwarden-sm/access-token
chmod 600 ~/.config/bitwarden-sm/access-token
```

Backward-compatible fallback still supported:

- `~/.config/keys/BWS_ACCESS_TOKEN`

Recommendation: use **one Bitwarden Machine Account per machine** and grant each machine account access to the shared `dotfiles` project. That gives you per-machine revocation without changing the repo.

### Push local secrets into Bitwarden

From the machine that already has the correct files:
```sh
script/sync_secrets_to_bws
```

That script will:

- create the Bitwarden project `dotfiles` if needed
- upsert matching files from `~/.ssh` and `~/.config/keys`
- store each file as a Bitwarden secret keyed by its home-relative path

### Pull secrets onto a new machine

1. Clone this repo.
2. Put a Bitwarden Secrets Manager access token at `~/.config/bitwarden-sm/access-token`.
3. Run the playbook:

```sh
ansible-playbook -l localhost[,otherhost,...] -K dotfiles-base.yaml
```

If you update secrets in the Bitwarden UI, just run the playbook again and the local files will be refreshed.

If you update secrets locally on a machine and want Bitwarden to become the source of truth again, run:

```sh
script/sync_secrets_to_bws
```

Recommendation: prefer editing in the Bitwarden UI for occasional changes, and use `script/sync_secrets_to_bws` when you intentionally want to publish the current machine state back into Bitwarden.

## Start SSH agent and add key
```sh
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa
```
