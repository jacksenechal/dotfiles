# archive/

Ansible roles and playbooks that are no longer applied, kept for reference rather than
deleted. Nothing in here is on the default role search path (`ansible.cfg` sets no
`roles_path`, so roles resolve from `./roles` relative to the playbook), which means these
cannot be invoked by accident. To revive one, move it back under `roles/` and re-add it to a
playbook.

## pi (retired 2026-08-06)

`pi-base.yaml` + `roles/pi` provisioned the pi agentic tooling: node 25.2.1 via nvm, the
`@earendil-works/pi-coding-agent` global packages and pinned extensions, the `~/.local/bin/pi`
wrapper, a clone of `agent-sandbox` (`git@github.com:jacksenechal/pi-docker-sandbox.git`), and
the `agent-sandbox:latest` docker image that ran sandboxed pi workers.

Retired because Jack stopped using pi. Related retirements: the `pi-swarm` skill moved to
`archive/pi-swarm` in the `agent-tools` repo, and the pi tier plus the pin-bump step were
removed from the `sync-claude-config` skill.

**Host state was deliberately left in place.** `~/.pi`, `~/.local/bin/pi`, nvm node 25.2.1,
the `agent-sandbox:latest` docker image, and `~/.config/keys/opencode.key` still exist on the
desktop and oracle. Ansible no longer manages them; remove them by hand if you want the disk
back (roughly 579M for `~/.pi`, 2.35G for the docker image, 1.2G for node 25.2.1).

### Two roles were extracted, not archived

`pi-base.yaml` also carried two roles that have nothing to do with pi. Both were moved to
their own playbooks so they keep working:

| Role | Now lives in | Why it matters |
|------|--------------|----------------|
| `secrets` | `secrets.yaml` | Delivers **all** SSH keys (`~/.ssh/id*`, `~/.ssh/config*`) and API keys (`~/.config/keys/*.key`) from Bitwarden Secrets Manager. Only `opencode.key` was pi-related; the rest are load-bearing for SSH access to oracle/hostinger and for every provider API key. |
| `playwright_mcp` | `playwright-mcp.yaml` | Registers the bare-metal `playwright` stdio MCP server — **Claude's** browser on servers. `localhost` disables it via `host_vars` in favour of the docker-based playwright-docker skill. |

If you ever restore `pi-base.yaml`, drop those two role entries from it rather than running
both copies.
