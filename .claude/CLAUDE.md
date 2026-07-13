# Environment: hexbench

Personalized Fedora + i3 workstation, managed as dotfiles. This file is my
**user-global** Claude instructions (loaded in every project) and is itself
versioned in the dotfiles repo — see @docs/dotfiles.md for how that works.

## The dotfiles repo

- Bare repo at `~/.dotfiles`, work-tree is `$HOME`.
- Manage it with the alias: `dotfiles <git-subcommand>`
  (= `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME`).
- `status.showUntrackedFiles=no`, so `dotfiles status` only shows tracked files.
  New files must be added explicitly with `dotfiles add <path>`.
- Do **not** create a `~/CLAUDE.md` — because the work-tree is `$HOME`, it would
  load into every project via ancestor-walking. Keep global instructions here in
  `~/.claude/CLAUDE.md` instead.

## Conventions

- Theme: Augmented Amber (amber-first, retro CRT). Full spec: @docs/Style-Guidelines.txt
- WM: i3, with picom (compositor) and polybar (status bar).
- Terminal: kitty. Editor: neovim (`~/.config/nvim/init.lua`).
- Launcher: rofi. Sound: `alsamixer`. Network: `nmtui`.

## When editing config

- Match the Augmented Amber palette — no colors outside the spec.
- After changing a tracked config, stage it: `dotfiles add <path>`.
