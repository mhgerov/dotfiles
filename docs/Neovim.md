# Neovim

The main text editor on **hexbench**. Fedora's `neovim` package (v0.11.6),
launched as `nvim` — `vim` is aliased to `nvim` in `.bashrc`.

Config lives in `~/.config/nvim/` and is versioned in the dotfiles repo (see
`~/docs/dotfiles.md`). Colors follow Augmented Amber
(`~/docs/Style-Guidelines.txt`).

---

## Plugin manager: lazy.nvim

Plugins are managed by **[lazy.nvim](https://github.com/folke/lazy.nvim)**
(folke). It bootstraps itself: on first launch, `lua/config/lazy.lua` clones it
from GitHub (`stable` branch) into `~/.local/share/nvim/lazy/lazy.nvim` if it
isn't already there, so a fresh machine only needs the config files plus `git`
and network access.

How it's set up:

- Every file in `lua/plugins/` returns a plugin spec; lazy picks them all up via
  `{ import = "plugins" }`. **To add a plugin, drop a new file in
  `lua/plugins/`.**
- `checker = { enabled = true }` — lazy checks for plugin updates in the
  background and notifies you. It does not install them on its own.
- Installed plugins live in `~/.local/share/nvim/lazy/` (not tracked).
- Exact plugin commits are pinned in `lazy-lock.json`.

| Task | Command |
|------|---------|
| Open the lazy dashboard | `:Lazy` |
| Install missing plugins | `:Lazy install` |
| Update plugins (rewrites `lazy-lock.json`) | `:Lazy update` |
| Restore plugins to the commits in `lazy-lock.json` | `:Lazy restore` |
| Remove plugins no longer in a spec | `:Lazy clean` |
| Check plugin health | `:checkhealth lazy` |

---

## Config layout

```
~/.config/nvim/
├── init.lua                  colorscheme + require("config.lazy")
├── lazy-lock.json            pinned plugin commits
├── colors/
│   └── augmented_amber.lua   custom colorscheme
└── lua/
    ├── config/
    │   └── lazy.lua          lazy.nvim bootstrap, leader keys, setup()
    └── plugins/              one spec file per plugin (group)
        ├── beancount.lua
        ├── neo-tree.lua
        ├── render-markdown.lua
        └── treesitter.lua
```

**Leader keys:** `<leader>` = `Space`, `<localleader>` = `\`. These are set in
`lua/config/lazy.lua` before lazy loads, so plugin mappings bind correctly.

There are no custom options or keymaps yet — everything beyond the plugins is
Neovim defaults.

---

## Plugins

| Plugin | Spec file | What it does |
|--------|-----------|--------------|
| `folke/lazy.nvim` | `config/lazy.lua` | Plugin manager |
| `nvim-neo-tree/neo-tree.nvim` (v3.x) | `neo-tree.lua` | File-tree sidebar — `:Neotree` |
| `antosha417/nvim-lsp-file-operations` | `neo-tree.lua` | Lets LSP servers react to renames/moves done in neo-tree |
| `s1n7ax/nvim-window-picker` (2.x) | `neo-tree.lua` | Pick a target window when opening files from neo-tree |
| `nvim-treesitter/nvim-treesitter` (**`master`**) | `treesitter.lua` | Syntax highlighting, indentation, incremental selection |
| `MeanderingProgrammer/render-markdown.nvim` | `render-markdown.lua` | Renders Markdown in-buffer (headings, tables, checkboxes) |
| `hxueh/beancount.nvim` | `beancount.lua` | Beancount ledger support; lazy-loads on `beancount`/`bean` files |
| `L3MON4D3/LuaSnip` | `beancount.lua` | Snippet engine (dependency of beancount.nvim) |

Pulled in as dependencies: `plenary.nvim`, `nui.nvim`, `nvim-web-devicons`,
`mini.nvim`.

`beancount.lua` also declares `saghen/blink.cmp` as an *optional* dependency.
blink.cmp isn't installed, so that completion source is inert until a
completion plugin is added.

### Treesitter: stay on `master`

`treesitter.lua` pins `branch = 'master'` on purpose. Upstream made the `main`
rewrite the default branch, and `main` requires Neovim 0.12 — this box runs
0.11.6. An unpinned spec silently migrates to `main` and breaks. Don't remove
the pin until Neovim is upgraded to 0.12+.

Parsers installed (via `ensure_installed`): `bash`, `beancount`, `json`, `lua`,
`markdown`, `markdown_inline`, `query`, `toml`, `vim`, `vimdoc`, `yaml`. Add a
language by appending it to that list, or run `:TSInstall <lang>`.
`:TSUpdate` runs automatically when the plugin updates.

---

## Colorscheme: Augmented Amber

`colors/augmented_amber.lua` is a hand-written colorscheme, loaded first thing
in `init.lua` with `vim.cmd.colorscheme("augmented_amber")`. It defines its
palette in one table at the top (`c.bg`, `c.amber`, `c.cyan`, …) and covers:

- Editor UI, legacy syntax groups, Treesitter `@captures`, LSP semantic tokens
- Plugin groups: neo-tree, Telescope, nvim-tree, nvim-cmp, Gitsigns,
  which-key, indent-blankline, noice/notify (most are pre-styled for plugins not
  installed yet)
- The 16 `:terminal` colors

Keep any new highlight inside that palette — no colors outside the style spec.

During a first-time plugin install lazy uses `habamax` temporarily
(`install.colorscheme`); that's expected.

---

## Common tasks

**Add a plugin**

1. Create `~/.config/nvim/lua/plugins/<name>.lua` returning a spec.
2. Restart nvim (or `:Lazy`), let it install.
3. If it adds highlight groups, style them in `augmented_amber.lua`.
4. Track it: `dotfiles add ~/.config/nvim/lua/plugins/<name>.lua ~/.config/nvim/lazy-lock.json`

**Remove a plugin** — delete its spec file, then `:Lazy clean`.

**Recover a broken update** — `:Lazy restore` returns every plugin to the
commits in `lazy-lock.json`. If the lockfile itself was updated, check out the
old one first: `dotfiles checkout -- .config/nvim/lazy-lock.json`.

**Nuke and reinstall plugins** — `rm -rf ~/.local/share/nvim/lazy` then start
nvim; lazy re-bootstraps and installs from the lockfile.

---

## Where things live

| Path | Contents | Tracked? |
|------|----------|----------|
| `~/.config/nvim/` | Config | Yes |
| `~/.local/share/nvim/lazy/` | Installed plugins + treesitter parsers | No |
| `~/.local/state/nvim/` | Undo, shada, swap, logs | No |
| `~/.cache/nvim/` | Cache | No |

---

## Default editor wiring

nvim is the default editor at every level:

- **Shell:** `.bashrc` exports `EDITOR=nvim VISUAL=nvim`, overriding Fedora's
  `/etc/profile.d/nano-default-editor.sh`. `git commit`, `sudoedit`,
  `crontab -e` etc. open nvim. (New shells only — existing terminals keep nano
  until reopened or `source ~/.bashrc`.)
- **Desktop / `xdg-open`:** `~/.local/share/applications/nvim-kitty.desktop`
  runs `kitty nvim %F` (`NoDisplay=true`, so it doesn't clutter rofi). It's the
  default in `~/.config/mimeapps.list` for `text/plain`, `text/markdown`,
  `text/x-log`, shell scripts, JSON, TOML, YAML, Python and Lua. Fedora's own
  `nvim.desktop` uses `Terminal=true`, which isn't reliable under i3 with no
  desktop environment — hence the custom entry.
  To add a type: `xdg-mime default nvim-kitty.desktop <mime/type>`.

All of `~/.config/nvim/` (including `lua/` and `lazy-lock.json`), the desktop
entry and `mimeapps.list` are tracked in the dotfiles repo.
