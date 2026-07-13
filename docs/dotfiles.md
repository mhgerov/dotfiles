# Dotfiles

Versioned config for **hexbench** (Fedora + i3). Managed as a *bare git repo*
whose work-tree is `$HOME`, so config files live in their normal locations and
are tracked in place — no symlinks, no `stow`.

## Setup on a new machine

```bash
git clone --bare git@github.com:mhgerov/dotfiles.git $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config status.showUntrackedFiles no
dotfiles checkout            # may need to move/backup conflicting files first
```

The `dotfiles` alias is defined in `.bashrc`.

## Daily use

| Task | Command |
|------|---------|
| See what changed | `dotfiles status` |
| Track a new file | `dotfiles add <path>` |
| Commit | `dotfiles commit -m "..."` |
| Push | `dotfiles push` |
| Diff | `dotfiles diff` |

Because `showUntrackedFiles=no`, only already-tracked files appear in `status`.
Anything new is invisible until you `dotfiles add` it — this is what keeps `$HOME`
noise (caches, sessions, credentials) out of the repo.

## What's tracked

- Shell: `.bashrc`
- WM / desktop: `.config/i3`, `.config/picom`, `.config/polybar`, `.config/rofi`
- Terminal: `.config/kitty`
- Editor: `.config/nvim`
- Claude: `.claude/CLAUDE.md` (global instructions only — the rest of `.claude/`
  is intentionally untracked)
- Docs: `README.md`, `docs/`

## Claude Code notes

`.claude/CLAUDE.md` is my user-global Claude instructions. It's tracked here so
the AI environment travels with the dotfiles. See that file for why there's no
top-level `~/CLAUDE.md` (the `$HOME` work-tree would leak it into every project).
