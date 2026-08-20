# Per-host file trees

Same layout as `files/home` and `files/desktop`, but only linked on the machine
whose hostname matches the directory name. Symlinked like everything else, so
editing the live file still edits the repo.

Keyed on `ansible_facts['hostname']`, **not** the inventory name: every
workstation runs as `localhost` in `hosts`, so `host_vars/localhost.yml` applies
to all of them and cannot tell one from another.

Use this only for genuinely machine-dependent configuration - audio devices,
input hotkeys, display wiring. Anything shared belongs in `files/home` (all
hosts) or `files/desktop` (all workstations). A host with no directory here is
normal.

| Host | Machine |
|---|---|
| `omarchy7320` | laptop |
| `archlinux` | desktop - **name unverified**, see below |

The desktop's hostname has not been confirmed from the desktop itself. If it is
wrong the tree simply never matches and nothing is linked; rename the directory
to whatever `hostname` reports there.

## Currently empty

voxtype was the first candidate and then moved on: only three of its settings are
actually machine-dependent, so duplicating a 343-line file per host was the wrong
trade. It is rendered by `roles/voxtype` instead. See "Rendered, not symlinked" in
the top-level README for when to pick which.

This tree is still the right home for a config that is machine-dependent
*throughout* rather than in a few keys - display wiring, or a config whose format
has no way to express a variable.
