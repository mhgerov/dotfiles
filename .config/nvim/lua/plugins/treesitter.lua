return {
  'nvim-treesitter/nvim-treesitter',
  -- Pin the branch explicitly.
  --
  -- Upstream made `main` (the rewrite) the default branch, so an unpinned spec
  -- silently migrates off `master` -- which is what broke the old config here.
  -- `main` also requires Neovim 0.12 (nightly); this box runs 0.11.6, so
  -- `master` is the correct branch. It is locked upstream, but stays supported
  -- for 0.11 and keeps the classic `nvim-treesitter.configs` API.
  branch = 'master',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup({
      -- All treesitter parsers are declared here, including beancount's;
      -- beancount.nvim itself does not require treesitter.
      ensure_installed = {
        'beancount',
        'bash',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'query',
        'toml',
        'vim',
        'vimdoc',
        'yaml',
      },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = { enable = true },
    })
  end,
}
