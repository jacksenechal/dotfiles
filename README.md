# Usage

## Setup and periodic maintenance
```sh
ansible-playbook -l localhost[,otherhost,...] -K dotfiles-base.yaml
```

### Just nvim
```sh
ansible-playbook -l localhost -t nvim -K dotfiles-base.yaml
```

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

