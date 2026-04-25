# direnv build hangs on macOS Tahoe (darwin25)

## Symptom

`darwin-rebuild switch` hangs forever with the last log line stuck on:

```
[1/0/12 built] building direnv-2.37.1 (checkPhase): direnv: loading /nix/var/nix/builds/nix-XXXX-XXXX/source/test/.envrc
```

`ps` shows a `zsh ./test/direnv-test.zsh` process spawned by `make test-zsh`
that never exits. The hang appeared after upgrading to macOS Tahoe (26.x);
the same direnv built fine on Sequoia. Bash and fish phases of the test
suite complete successfully — only the zsh phase hangs.

## Root cause (verified by stack trace)

Captured a `sample` of the hung zsh while reproducing under
`nix build .#darwinConfigurations."thomas@mac-personal".pkgs.direnv` (the
unpatched derivation). Stack:

```
zsh_main → loop → … → bin_dot          # the `source` builtin
       → loop → … → doshfunc → runshfunc → execlist
       → … → prefork → … → getoutput   # `$(...)` command substitution
       → waitforpid → signal_suspend → pause → __sigsuspend
```

What it means:

- `direnv-test.zsh` `source`s `direnv-test-common.sh`, which defines
  `direnv_eval(){ eval "$(direnv export $TARGET_SHELL)"; }`.
- The first `$(...)` triggers zsh's `getoutput`, which forks a child to
  run the substitution and parent-waits via
  `signal_suspend` → `sigsuspend(2)` for SIGCHLD.
- `pgrep -P <zsh-pid>` shows the child is **gone** — no live child, no
  zombie, no descendants of the build tree at all.
- SIGCHLD never woke the sigsuspend, so zsh deadlocks forever.

This is a **lost-SIGCHLD / orphaned-wait deadlock** in zsh's
command-substitution path, almost certainly caused by a Tahoe-side
regression in xnu / `libsystem_kernel`'s signal-delivery path for forked
children of sandboxed builder processes. Bash and fish use different
fork/wait patterns and are unaffected; only zsh's `signal_suspend`-based
loop is exposed.

### What it is *not*

- **Not a sandbox-rule denial.** During the reproducer, a backgrounded
  `sudo log stream --predicate '(subsystem == "com.apple.sandbox.reporting")'`
  recorded **zero** events for the entire build. Nothing in the Nix
  sandbox profile is being denied; there is no `(allow …)` rule to add.
- **Not the `hw.*` sysctl issue from
  [anthropics/claude-code#49820](https://github.com/anthropics/claude-code/issues/49820).**
  That's a different sandbox profile (Claude Code's seatbelt). Nix's
  build sandbox already has `(allow sysctl-read)` unrestricted; zsh
  starts cleanly inside it.
- **Not a zsh-startup hang.** The stack proves zsh ran user code,
  sourced files, and got into command substitution before deadlocking.

## Fix applied

Override `pkgs.direnv` on Darwin to drop the zsh test from `checkPhase`,
in `modules/packages/shell/default.nix`:

```nix
direnv-patched = pkgs.direnv.overrideAttrs (
  old: lib.optionalAttrs isDarwin {
    checkPhase = ''
      runHook preCheck
      make test-go test-bash test-fish
      runHook postCheck
    '';
  }
);

# ...

programs.direnv = {
  enable = true;
  package = direnv-patched;
  enableZshIntegration = true;
  nix-direnv.enable = true;
};
```

The remaining tests (`test-go`, `test-bash`, `test-fish`) still run, so
upstream coverage is mostly preserved. The override changes only
`checkPhase`, which doesn't affect the output binary — but it *does*
change the drv hash, so you'll keep building locally instead of
substituting from Hydra until you remove it.

## Alternatives considered

- `--option sandbox relaxed` / `--option sandbox false` on
  `darwin-rebuild`: weakens the sandbox for *every* build, not just
  direnv. Doesn't actually fix anything either, since the bug isn't a
  sandbox denial — but a relaxed sandbox can change scheduling/signal
  timing enough to hide it in some cases. Use only as an emergency
  hatch.
- Hand-patching `direnv-test-common.sh` to avoid `$(...)` early on:
  not worth it; the override is cleaner.

## When to remove this override

Any of these makes it unnecessary, in rough order of likelihood:

1. **Hydra catches up.** Once cache.nixos.org publishes the
   aarch64-darwin direnv binary for the current nixpkgs rev, the build
   is substituted and the bug never triggers. The override is still
   safe to keep, but it forces a local build — drop it once you trust
   the cache to have it.
2. **nixpkgs's direnv stops running `test-zsh` on Darwin.** Easy
   upstream fix — one-line `doCheck` / `checkPhase` tweak in
   `pkgs/by-name/di/direnv/package.nix`. Worth filing a PR with the
   stack trace from this note as evidence.
3. **Apple fixes the SIGCHLD/sigsuspend regression.** Tahoe point
   release. Not actionable from our side; you'll find out when the
   override is no longer needed (test-zsh reaches end-of-suite when
   you flip it back on).

Verification recipe — drop the override, comment out
`package = direnv-patched`, then run

```
nix build --no-link '.#darwinConfigurations."thomas@mac-personal".pkgs.direnv' -L
```

If it reaches `installPhase` without hanging on the first
`direnv: loading … test/.envrc` after `## Testing` markers stop
appearing, the bug is gone. If it hangs again, restore the override.

## Sources

- Reproduction stack: `sudo sample <zsh-pid> 3 -mayDie` against the
  hung builder during a vanilla `pkgs.direnv` build. The deadlock
  bottom-frame `__sigsuspend` ← `pause` ← `signal_suspend` ←
  `waitforpid` ← `getoutput` is the diagnosis.
- <https://raw.githubusercontent.com/NixOS/nix/2.34.6/src/libstore/unix/build/sandbox-defaults.sb>
  — confirms the Nix sandbox profile already grants `(allow sysctl-read)`
  unrestricted, refuting the `hw.*` denial theory.
- <https://github.com/anthropics/claude-code/issues/49820> — same
  darwin25-regression *family* in a different sandbox profile;
  retained as related prior art only.
- <https://n8henrie.com/2025/12/nix-debugging-macos-darwin-sandbox-issues/>
  — the methodology used to rule sandbox out (extract profile,
  `log stream` on `sandboxd`, `sandbox-exec -f` reproducer).
- <https://direnv.net/CHANGELOG.html> — direnv 2.37.1 release notes.
