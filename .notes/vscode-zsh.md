# VSCode zsh terminals hang on macOS Tahoe (darwin25)

## Symptom

Opening a new integrated terminal in VSCode hangs forever before the
prompt ever appears, when the terminal profile uses the nix-built zsh
(`~/.nix-profile/bin/zsh`). Same machine, same `.zshrc`:

- Terminal type **bash** in VSCode → works.
- Terminal type **tmux** in VSCode → works.
- Terminal type **zsh** in VSCode → hangs forever.
- Same nix zsh in **iTerm2** or **Ghostty** → works.

Started after upgrading to macOS Tahoe (26.x); the setup had been
unchanged for ~4 months prior.

## Root cause (verified by stack trace)

This is the **same lost-SIGCHLD bug** documented in
[`direnv.md`](./direnv.md), just hitting at runtime instead of build
time. The zsh test suite hangs in nixpkgs builds for the same reason
the interactive shell hangs in VSCode: `signal_suspend` →
`sigsuspend(2)` never wakes for SIGCHLD on darwin25 in certain pty /
process-group setups.

Reproduced with `sudo sample <hung-zsh-pid> 2 -mayDie` against a fresh
hung VSCode zsh:

```
zsh_main → run_init_scripts → source        # /etc/zprofile
       → execif → … → prefork → getoutput   # `…` command substitution
       → waitforpid → signal_suspend → pause → __sigsuspend
```

The `eval \`/usr/libexec/path_helper -s\`` in `/etc/zprofile` is the
first victim — `path_helper` exits in milliseconds (verified
out-of-band: 3 ms wall time), but zsh never sees the SIGCHLD and
deadlocks in `pause()`. `pgrep -P <zsh>` shows zero children, no
zombie. Sending `kill -CHLD <zsh-pid>` manually unblocks it — at which
point it advances to the **next** `$(...)` (in p10k / atuin / direnv
hook / gpg-connect-agent) and hangs again. Every command substitution
in init is a deadlock.

iTerm/Ghostty don't expose the race because of how their pty driver
sets up the controlling terminal, process group, and signal mask.
VSCode's terminal uses its own pty host (node-pty) which sets things
up just differently enough to expose the bug. Apple's `/bin/zsh`
(stock 5.9, built by Apple) does **not** hang under VSCode's pty.
The bug is specifically in the nixpkgs build of zsh on darwin25.

### What it is *not*

- **Not** anything in `.zshrc` / `.zshenv` / `.p10k.zsh`. The hang
  starts in `/etc/zprofile`'s `path_helper` call, before any user
  rc file is read.
- **Not** VSCode shell-integration. Disabling
  `terminal.integrated.shellIntegration.enabled` doesn't change
  anything — the stack is in `run_init_scripts`, before integration
  has a chance to inject.
- **Not** a zsh-version mismatch with the running gpg-agent
  (homebrew 2.5.19 daemon vs nix 2.4.9 client called from .zshrc).
  That's a real cosmetic inconsistency to clean up someday, but the
  hang happens long before line 113 of `.zshrc`.

## Fix applied

Pin VSCode's terminal to Apple's stock zsh in
`~/Library/Application Support/Code/User/settings.json`:

```json
"terminal.integrated.profiles.osx": {
  "zsh (system)": { "path": "/bin/zsh", "args": ["-l"] }
},
"terminal.integrated.defaultProfile.osx": "zsh (system)"
```

The login shell remains `/Users/thomas/.nix-profile/bin/zsh`; iTerm
and Ghostty keep using the nix one (no change there). Only VSCode
gets routed to `/bin/zsh`. `.zshrc` / `.zshenv` are unchanged — both
zsh binaries source the same home-manager-managed config.

The minor cost is a slightly different shell environment in VSCode
vs. other terminals (different completion paths, different built-in
modules). For day-to-day editing-with-terminal usage it is invisible.

## Alternatives considered

- **Patch `pkgs.zsh`** the way `pkgs.direnv` was patched. Not pursued
  because there's no known-good upstream fix for the SIGCHLD bug yet,
  and `doCheck = false` style patches don't help here — the bug is at
  runtime, not in tests. A real fix needs either an upstream zsh
  signal-handling patch or a newer zsh release that addresses
  darwin25.
- **Drop nix zsh entirely**, use `/bin/zsh` everywhere as login shell
  and let home-manager only manage `.zshrc` content (`programs.zsh`
  module supports this; `programs.zsh.enable = false` is already set
  in `darwin/configuration.nix`). Cleanest long-term answer if Apple
  ships fixes faster than nixpkgs does. Skipped for now — the
  per-VSCode override is enough.
- **`zsh --no-globalrcs`** to skip `/etc/zprofile`. Would dodge the
  `path_helper` hang specifically, but the **next** `$(...)` in
  `.zshrc` would hang the same way. Not a real fix.

## When to remove this override

Any of these makes it unnecessary:

1. **nixpkgs ships a zsh build that handles SIGCHLD correctly on
   darwin25.** Most likely vehicle: a zsh point release with a
   Darwin-specific signal patch, or a nixpkgs-side patch that
   backports it. Test by deleting the
   `terminal.integrated.profiles.osx` block from settings.json,
   reopening VSCode, and opening a new terminal — if it gets to a
   prompt within a few seconds, you're done.
2. **Apple fixes the regression in a Tahoe point release.** Same
   verification as above. The
   [`direnv.md`](./direnv.md) override should also become unnecessary
   at the same time, so the two notes can be retired together.

## Sources

- Reproduction stack: `sudo sample <zsh-pid> 2 -mayDie` against the
  hung VSCode zsh while it was waiting for the path_helper
  substitution to return.
- `kill -CHLD <pid>` confirmation: a single manual SIGCHLD advances
  the shell exactly one `$(...)` further before it hangs again.
  Pure diagnosis tool, not a workaround.
- [`direnv.md`](./direnv.md) — same bug, build-time manifestation.
