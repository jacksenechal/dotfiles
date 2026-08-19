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

## Why voxtype lives here

`files/desktop` links onto every workstation, so the desktop's voxtype config
(`device = "echocancel"`, pairing with the desktop's PipeWire echo-cancel sink)
was being applied to the laptop too, which has no such sink and uses
`device = "default"`. The two copies are also on different voxtype schema
generations. They are genuinely different files, not drift.
