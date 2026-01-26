# Task: Add nvim-java plugin to dotfiles

**Status:** Reverted — ready to re-attempt. All blockers are now understood.

## What was attempted

Added [nvim-java/nvim-java](https://github.com/nvim-java/nvim-java) with dependencies (nui.nvim, nvim-dap, spring-boot.nvim) to the Neovim plugin list and configured it in `initialize.lua`.

## Issues encountered (all solved)

### 1. SOLVED: plasticboy/vim-markdown syntax conflict
- Neovim 0.11's `syntax/java.vim` includes `syntax/markdown.vim` for Javadoc markdown support
- `plasticboy/vim-markdown` provides its own `syntax/markdown.vim` with different group names (`mkd*` vs `markdown*`)
- **Fix (committed):** `vim.g.java_ignore_markdown = 1` at the top of `initialize.lua`

### 2. SOLVED: JDK version issues
- nvim-java auto-downloads JDK 25 by default, but JDK 25's strict ZIP validation rejects older Maven JARs (`Invalid CEN header (invalid zip64 extra data field size)`)
- nvim-java's pkgm only has download specs for JDK 17 and 25 — no 21
- JDTLS 1.54.0 requires Java 21-25, so JDK 17 is too old
- **Fix:** `auto_install = false` + `cmd_env` pointing to system JDK 21 at `/usr/lib/jvm/java-21-openjdk`
- JDK 21 is already installed on the system (`archlinux-java status` shows `java-21-openjdk`)

### 3. SOLVED: "Error: Unable to access jarfile" from `/usr/bin/bash`
- This was a **pre-existing issue**, not caused by nvim-java at all
- **Root cause:** ALE's built-in `eclipselsp` linter auto-enables for Java files and runs `java -jar <path>` looking for an Eclipse JDT.LS launcher jar at `~/eclipse.jdt.ls/plugins/` or `/usr/share/java/jdtls/plugins/` — neither exists, so the jar path is empty
- ALE runs commands through bash, hence the `/usr/bin/bash` RPC process
- **Fix (committed):** Added `let g:ale_linters_ignore = {'java': ['eclipselsp']}` to ALE settings in `init.vim`
- When nvim-java is re-added, ALE's eclipselsp should stay disabled since nvim-java provides its own JDTLS

### 4. EXPECTED: Harmless log noise
These errors/warnings appear in `lsp.log` and can be ignored:
- `"Command _java.reloadBundles.command not supported on client"` — JDTLS debug plugin asking for unsupported client feature
- `"The language server jdtls triggers a registerCapability handler..."` — harmless Neovim warning
- `"The language server spring-boot triggers a registerCapability handler..."` — same
- `"WARNING: Using incubator modules: jdk.incubator.vector"` — JDK 21 stderr noise (Vector API still incubating)

## Cleanup already done
Plugins were removed from disk. The auto-downloaded packages may still exist:
```bash
rm -rf ~/.local/share/nvim/nvim-java/          # auto-downloaded packages (jdtls, lombok, spring-boot-tools)
rm -rf ~/.cache/nvim/jdtls/                    # jdtls workspace cache
```

## Files to modify when resuming
- `roles/nvim/tasks/main.yaml` — add plugin repos to the `Clone VIM plugins` loop (start/ section)
- `files/home/.config/nvim/initialize.lua` — add setup + enable calls before the colorscheme section

## Plugins to add (roles/nvim/tasks/main.yaml)
```yaml
- repo: https://github.com/nvim-java/nvim-java
  dest: start/nvim-java
- repo: https://github.com/MunifTanjim/nui.nvim
  dest: start/nui.nvim
- repo: https://github.com/mfussenegger/nvim-dap
  dest: start/nvim-dap
- repo: https://github.com/JavaHello/spring-boot.nvim
  dest: start/spring-boot.nvim
```

## Lua config to add (initialize.lua, before colorscheme toggle section)
```lua
-- nvim-java setup (Java IDE via JDTLS)
require('java').setup({
  jdk = {
    auto_install = false,
  },
})
vim.lsp.config('jdtls', {
  cmd_env = {
    JAVA_HOME = '/usr/lib/jvm/java-21-openjdk',
    PATH = '/usr/lib/jvm/java-21-openjdk/bin:' .. vim.fn.getenv('PATH'),
  },
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = 'JavaSE-21',
            path = '/usr/lib/jvm/java-21-openjdk',
            default = true,
          },
        },
      },
    },
  },
})
vim.lsp.enable('jdtls')
```

## System info
- Neovim 0.11.5, Arch Linux
- System Java: JDK 17 (default), JDK 21 installed at `/usr/lib/jvm/java-21-openjdk`
- nvim-java pkgm only has JDK download specs for versions 17 and 25 (hence `auto_install = false`)
- nvim-java README: https://github.com/nvim-java/nvim-java

## What to verify on next attempt
1. Run `ansible-playbook dotfiles-base.yaml --tags nvim` to clone plugins
2. Open a `.java` file — JDTLS should auto-download on first run via nvim-java's pkgm
3. Check `~/.local/state/nvim/lsp.log` — should see jdtls and spring-boot starting without errors
4. Confirm completion, go-to-definition, and diagnostics work
5. The only log noise should be the harmless warnings listed in issue #4 above
