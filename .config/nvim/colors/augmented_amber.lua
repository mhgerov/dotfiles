-- =============================================================================
-- augmented_amber.lua
-- Neovim colorscheme based on the Augmented Amber system style guidelines
--
-- Install: place in ~/.config/nvim/colors/augmented_amber.lua
-- Activate: vim.cmd.colorscheme("augmented_amber")  (in init.lua)
--           or :colorscheme augmented_amber          (command)
-- =============================================================================

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "augmented_amber"
vim.o.termguicolors = true

local hi = vim.api.nvim_set_hl

-- =============================================================================
-- PALETTE
-- =============================================================================

local c = {
  -- Backgrounds
  bg         = "#0c0b00",   -- main background
  panel      = "#151100",   -- panel / sidebar
  panel_alt  = "#1d1600",   -- floating windows, popups
  -- Foregrounds
  fg         = "#ffd86b",   -- primary foreground (bright amber)
  fg_soft    = "#ffc94d",   -- soft amber
  fg_dim     = "#805a00",   -- muted/dim amber (comments, inactive)
  -- Amber accents
  amber      = "#ffb000",   -- primary amber (cursor, highlights)
  -- Semantic accents
  purple     = "#c792ea",   -- keywords / control flow
  cyan       = "#89ddff",   -- functions / types / highlights
  green      = "#a3be8c",   -- strings / success
  orange     = "#ff8f00",   -- warnings / urgent / errors
  -- Borders / subtle
  border     = "#2a1f00",   -- low-contrast border (~rgba amber 0.20)
  selection  = "#2e2000",   -- visual selection background
  line_hl    = "#110f00",   -- current line highlight
  none       = "NONE",
}

-- =============================================================================
-- EDITOR UI
-- =============================================================================

-- Core
hi(0, "Normal",          { fg = c.fg,       bg = c.bg })
hi(0, "NormalFloat",     { fg = c.fg,       bg = c.panel_alt })
hi(0, "NormalNC",        { fg = c.fg_soft,  bg = c.bg })

-- Cursor
hi(0, "Cursor",          { fg = c.bg,       bg = c.amber })
hi(0, "CursorIM",        { fg = c.bg,       bg = c.amber })
hi(0, "CursorLine",      { bg = c.line_hl })
hi(0, "CursorLineNr",    { fg = c.amber,    bg = c.line_hl, bold = true })
hi(0, "CursorColumn",    { bg = c.line_hl })

-- Line numbers
hi(0, "LineNr",          { fg = c.fg_dim })
hi(0, "SignColumn",      { fg = c.fg_dim,   bg = c.bg })

-- Splits / borders
hi(0, "VertSplit",       { fg = c.border,   bg = c.bg })
hi(0, "WinSeparator",    { fg = c.border,   bg = c.bg })

-- Status / tab line
hi(0, "StatusLine",      { fg = c.fg,       bg = c.panel })
hi(0, "StatusLineNC",    { fg = c.fg_dim,   bg = c.panel })
hi(0, "TabLine",         { fg = c.fg_dim,   bg = c.panel })
hi(0, "TabLineFill",     { bg = c.panel })
hi(0, "TabLineSel",      { fg = c.amber,    bg = c.bg, bold = true })

-- Pmenu (autocomplete popup)
hi(0, "Pmenu",           { fg = c.fg,       bg = c.panel_alt })
hi(0, "PmenuSel",        { fg = c.bg,       bg = c.amber, bold = true })
hi(0, "PmenuSbar",       { bg = c.panel })
hi(0, "PmenuThumb",      { bg = c.fg_dim })

-- Search / selection
hi(0, "Visual",          { bg = c.selection })
hi(0, "VisualNOS",       { bg = c.selection })
hi(0, "Search",          { fg = c.bg,       bg = c.amber })
hi(0, "IncSearch",       { fg = c.bg,       bg = c.fg,    bold = true })
hi(0, "CurSearch",       { fg = c.bg,       bg = c.amber, bold = true })
hi(0, "Substitute",      { fg = c.bg,       bg = c.orange })

-- Folds
hi(0, "Folded",          { fg = c.fg_dim,   bg = c.panel, italic = true })
hi(0, "FoldColumn",      { fg = c.fg_dim,   bg = c.bg })

-- Diff
hi(0, "DiffAdd",         { fg = c.green,    bg = c.bg })
hi(0, "DiffChange",      { fg = c.amber,    bg = c.bg })
hi(0, "DiffDelete",      { fg = c.orange,   bg = c.bg })
hi(0, "DiffText",        { fg = c.bg,       bg = c.amber })

-- Diagnostics
hi(0, "DiagnosticError",       { fg = c.orange })
hi(0, "DiagnosticWarn",        { fg = c.orange })
hi(0, "DiagnosticInfo",        { fg = c.cyan })
hi(0, "DiagnosticHint",        { fg = c.fg_dim })
hi(0, "DiagnosticUnderlineError", { sp = c.orange, undercurl = true })
hi(0, "DiagnosticUnderlineWarn",  { sp = c.orange, undercurl = true })
hi(0, "DiagnosticUnderlineInfo",  { sp = c.cyan,   undercurl = true })
hi(0, "DiagnosticUnderlineHint",  { sp = c.fg_dim, undercurl = true })
hi(0, "DiagnosticVirtualTextError", { fg = c.orange, italic = true })
hi(0, "DiagnosticVirtualTextWarn",  { fg = c.orange, italic = true })
hi(0, "DiagnosticVirtualTextInfo",  { fg = c.cyan,   italic = true })
hi(0, "DiagnosticVirtualTextHint",  { fg = c.fg_dim, italic = true })

-- Messages / command line
hi(0, "ModeMsg",         { fg = c.amber,    bold = true })
hi(0, "MoreMsg",         { fg = c.green })
hi(0, "WarningMsg",      { fg = c.orange })
hi(0, "ErrorMsg",        { fg = c.orange,   bold = true })
hi(0, "Question",        { fg = c.cyan })
hi(0, "Title",           { fg = c.amber,    bold = true })
hi(0, "Directory",       { fg = c.cyan })

-- Misc UI
hi(0, "MatchParen",      { fg = c.bg,       bg = c.cyan, bold = true })
hi(0, "NonText",         { fg = c.border })
hi(0, "SpecialKey",      { fg = c.fg_dim })
hi(0, "Whitespace",      { fg = c.border })
hi(0, "EndOfBuffer",     { fg = c.border })
hi(0, "Conceal",         { fg = c.fg_dim })
hi(0, "ColorColumn",     { bg = c.panel })
hi(0, "QuickFixLine",    { bg = c.selection })
hi(0, "WildMenu",        { fg = c.bg,       bg = c.amber })
hi(0, "FloatBorder",     { fg = c.border,   bg = c.panel_alt })
hi(0, "FloatTitle",      { fg = c.amber,    bg = c.panel_alt, bold = true })

-- =============================================================================
-- SYNTAX — LEGACY GROUPS
-- =============================================================================

-- Comments
hi(0, "Comment",         { fg = c.fg_dim,   italic = true })
hi(0, "SpecialComment",  { fg = c.fg_dim,   italic = true })

-- Constants & literals
hi(0, "Constant",        { fg = c.fg_soft })
hi(0, "String",          { fg = c.green })
hi(0, "Character",       { fg = c.green })
hi(0, "Number",          { fg = c.fg_soft })
hi(0, "Float",           { fg = c.fg_soft })
hi(0, "Boolean",         { fg = c.purple })

-- Identifiers
hi(0, "Identifier",      { fg = c.fg })
hi(0, "Function",        { fg = c.cyan })

-- Keywords / control flow
hi(0, "Statement",       { fg = c.purple })
hi(0, "Keyword",         { fg = c.purple })
hi(0, "Conditional",     { fg = c.purple })
hi(0, "Repeat",          { fg = c.purple })
hi(0, "Label",           { fg = c.purple })
hi(0, "Operator",        { fg = c.fg_soft })
hi(0, "Exception",       { fg = c.purple })

-- Preprocessor
hi(0, "PreProc",         { fg = c.amber })
hi(0, "Include",         { fg = c.amber })
hi(0, "Define",          { fg = c.amber })
hi(0, "Macro",           { fg = c.amber })
hi(0, "PreCondit",       { fg = c.amber })

-- Types
hi(0, "Type",            { fg = c.cyan })
hi(0, "StorageClass",    { fg = c.purple })
hi(0, "Structure",       { fg = c.cyan })
hi(0, "Typedef",         { fg = c.cyan })

-- Special
hi(0, "Special",         { fg = c.amber })
hi(0, "SpecialChar",     { fg = c.amber })
hi(0, "Tag",             { fg = c.cyan })
hi(0, "Delimiter",       { fg = c.fg_dim })
hi(0, "Debug",           { fg = c.orange })

-- Underlines
hi(0, "Underlined",      { fg = c.cyan,     underline = true })
hi(0, "Ignore",          { fg = c.fg_dim })
hi(0, "Error",           { fg = c.orange,   bold = true })
hi(0, "Todo",            { fg = c.bg,       bg = c.amber, bold = true })

-- =============================================================================
-- TREESITTER GROUPS (@capture.names)
-- =============================================================================

-- Comments
hi(0, "@comment",                    { link = "Comment" })
hi(0, "@comment.documentation",      { fg = c.fg_dim, italic = true })

-- Literals
hi(0, "@string",                     { link = "String" })
hi(0, "@string.escape",              { fg = c.amber })
hi(0, "@string.special",             { fg = c.amber })
hi(0, "@string.regex",               { fg = c.orange })
hi(0, "@character",                  { link = "Character" })
hi(0, "@number",                     { link = "Number" })
hi(0, "@float",                      { link = "Float" })
hi(0, "@boolean",                    { link = "Boolean" })

-- Functions
hi(0, "@function",                   { link = "Function" })
hi(0, "@function.builtin",           { fg = c.cyan, italic = true })
hi(0, "@function.call",              { fg = c.cyan })
hi(0, "@function.macro",             { fg = c.amber })
hi(0, "@method",                     { fg = c.cyan })
hi(0, "@method.call",                { fg = c.cyan })
hi(0, "@constructor",                { fg = c.cyan })

-- Keywords
hi(0, "@keyword",                    { link = "Keyword" })
hi(0, "@keyword.function",           { fg = c.purple })
hi(0, "@keyword.operator",           { fg = c.purple })
hi(0, "@keyword.return",             { fg = c.purple })
hi(0, "@keyword.import",             { fg = c.amber })
hi(0, "@keyword.export",             { fg = c.amber })
hi(0, "@conditional",                { link = "Conditional" })
hi(0, "@repeat",                     { link = "Repeat" })
hi(0, "@exception",                  { link = "Exception" })
hi(0, "@include",                    { link = "Include" })

-- Variables / identifiers
hi(0, "@variable",                   { fg = c.fg })
hi(0, "@variable.builtin",           { fg = c.fg_soft, italic = true })
hi(0, "@variable.parameter",         { fg = c.fg_soft })
hi(0, "@variable.member",            { fg = c.fg })
hi(0, "@constant",                   { fg = c.fg_soft })
hi(0, "@constant.builtin",           { fg = c.amber })
hi(0, "@constant.macro",             { fg = c.amber })

-- Types
hi(0, "@type",                       { link = "Type" })
hi(0, "@type.builtin",               { fg = c.cyan, italic = true })
hi(0, "@type.definition",            { fg = c.cyan })
hi(0, "@type.qualifier",             { fg = c.purple })
hi(0, "@storageclass",               { link = "StorageClass" })

-- Namespace / module
hi(0, "@namespace",                  { fg = c.fg_soft })
hi(0, "@module",                     { fg = c.fg_soft })

-- Operators / punctuation
hi(0, "@operator",                   { fg = c.fg_soft })
hi(0, "@punctuation.delimiter",      { fg = c.fg_dim })
hi(0, "@punctuation.bracket",        { fg = c.fg_soft })
hi(0, "@punctuation.special",        { fg = c.amber })

-- Tags (HTML/JSX)
hi(0, "@tag",                        { fg = c.amber })
hi(0, "@tag.builtin",                { fg = c.amber })
hi(0, "@tag.attribute",              { fg = c.fg_soft })
hi(0, "@tag.delimiter",              { fg = c.fg_dim })

-- Markup (markdown, rst)
hi(0, "@markup.heading",             { fg = c.amber, bold = true })
hi(0, "@markup.bold",                { fg = c.fg,    bold = true })
hi(0, "@markup.italic",              { fg = c.fg,    italic = true })
hi(0, "@markup.link",                { fg = c.cyan,  underline = true })
hi(0, "@markup.link.url",            { fg = c.cyan,  underline = true })
hi(0, "@markup.raw",                 { fg = c.green })
hi(0, "@markup.list",                { fg = c.amber })

-- Misc
hi(0, "@label",                      { fg = c.purple })
hi(0, "@attribute",                  { fg = c.amber })
hi(0, "@error",                      { link = "Error" })
hi(0, "@none",                       { })

-- =============================================================================
-- LSP SEMANTIC TOKENS
-- =============================================================================

hi(0, "@lsp.type.function",          { link = "@function" })
hi(0, "@lsp.type.method",            { link = "@method" })
hi(0, "@lsp.type.variable",          { link = "@variable" })
hi(0, "@lsp.type.parameter",         { link = "@variable.parameter" })
hi(0, "@lsp.type.property",          { link = "@variable.member" })
hi(0, "@lsp.type.class",             { link = "@type" })
hi(0, "@lsp.type.interface",         { link = "@type" })
hi(0, "@lsp.type.struct",            { link = "@type" })
hi(0, "@lsp.type.enum",              { link = "@type" })
hi(0, "@lsp.type.enumMember",        { fg = c.fg_soft })
hi(0, "@lsp.type.type",              { link = "@type" })
hi(0, "@lsp.type.typeParameter",     { fg = c.cyan, italic = true })
hi(0, "@lsp.type.namespace",         { link = "@namespace" })
hi(0, "@lsp.type.module",            { link = "@module" })
hi(0, "@lsp.type.keyword",           { link = "@keyword" })
hi(0, "@lsp.type.decorator",         { fg = c.amber })
hi(0, "@lsp.type.macro",             { link = "@function.macro" })
hi(0, "@lsp.type.comment",           { link = "Comment" })
hi(0, "@lsp.type.string",            { link = "String" })
hi(0, "@lsp.type.number",            { link = "Number" })
hi(0, "@lsp.type.operator",          { link = "@operator" })
hi(0, "@lsp.mod.deprecated",         { strikethrough = true })
hi(0, "@lsp.mod.readonly",           { italic = true })

-- =============================================================================
-- PLUGIN HIGHLIGHTS
-- =============================================================================

-- Gitsigns
hi(0, "GitSignsAdd",                 { fg = c.green })
hi(0, "GitSignsChange",              { fg = c.amber })
hi(0, "GitSignsDelete",              { fg = c.orange })

-- Telescope
hi(0, "TelescopeNormal",             { fg = c.fg,      bg = c.panel_alt })
hi(0, "TelescopeBorder",             { fg = c.border,  bg = c.panel_alt })
hi(0, "TelescopeTitle",              { fg = c.amber,   bg = c.panel_alt, bold = true })
hi(0, "TelescopePromptNormal",       { fg = c.fg,      bg = c.panel })
hi(0, "TelescopePromptBorder",       { fg = c.border,  bg = c.panel })
hi(0, "TelescopePromptTitle",        { fg = c.amber,   bg = c.panel, bold = true })
hi(0, "TelescopePromptPrefix",       { fg = c.amber })
hi(0, "TelescopeSelection",          { fg = c.bg,      bg = c.amber })
hi(0, "TelescopeSelectionCaret",     { fg = c.bg,      bg = c.amber })
hi(0, "TelescopeMatching",           { fg = c.cyan,    bold = true })
hi(0, "TelescopePreviewNormal",      { fg = c.fg,      bg = c.bg })
hi(0, "TelescopePreviewBorder",      { fg = c.border,  bg = c.bg })

-- nvim-tree
hi(0, "NvimTreeNormal",              { fg = c.fg,      bg = c.panel })
hi(0, "NvimTreeNormalNC",            { fg = c.fg_dim,  bg = c.panel })
hi(0, "NvimTreeRootFolder",          { fg = c.amber,   bold = true })
hi(0, "NvimTreeFolderName",          { fg = c.fg })
hi(0, "NvimTreeOpenedFolderName",    { fg = c.amber })
hi(0, "NvimTreeFolderIcon",          { fg = c.amber })
hi(0, "NvimTreeFileIcon",            { fg = c.fg_soft })
hi(0, "NvimTreeGitNew",              { fg = c.green })
hi(0, "NvimTreeGitDirty",            { fg = c.amber })
hi(0, "NvimTreeGitDeleted",          { fg = c.orange })
hi(0, "NvimTreeIndentMarker",        { fg = c.border })
hi(0, "NvimTreeWinSeparator",        { fg = c.border,  bg = c.panel })

-- neo-tree
hi(0, "NeoTreeNormal",               { fg = c.fg,      bg = c.panel })
hi(0, "NeoTreeNormalNC",             { fg = c.fg_dim,  bg = c.panel })
hi(0, "NeoTreeDirectoryName",        { fg = c.fg })
hi(0, "NeoTreeDirectoryIcon",        { fg = c.amber })
hi(0, "NeoTreeRootName",             { fg = c.amber,   bold = true })
hi(0, "NeoTreeFileName",             { fg = c.fg })
hi(0, "NeoTreeGitAdded",             { fg = c.green })
hi(0, "NeoTreeGitModified",          { fg = c.amber })
hi(0, "NeoTreeGitDeleted",           { fg = c.orange })
hi(0, "NeoTreeIndentMarker",         { fg = c.border })

-- nvim-cmp
hi(0, "CmpItemAbbr",                 { fg = c.fg })
hi(0, "CmpItemAbbrDeprecated",       { fg = c.fg_dim,  strikethrough = true })
hi(0, "CmpItemAbbrMatch",            { fg = c.cyan,    bold = true })
hi(0, "CmpItemAbbrMatchFuzzy",       { fg = c.cyan })
hi(0, "CmpItemKind",                 { fg = c.fg_dim })
hi(0, "CmpItemKindFunction",         { fg = c.cyan })
hi(0, "CmpItemKindMethod",           { fg = c.cyan })
hi(0, "CmpItemKindKeyword",          { fg = c.purple })
hi(0, "CmpItemKindVariable",         { fg = c.fg })
hi(0, "CmpItemKindText",             { fg = c.fg_dim })
hi(0, "CmpItemKindModule",           { fg = c.amber })
hi(0, "CmpItemKindClass",            { fg = c.cyan })
hi(0, "CmpItemKindField",            { fg = c.fg_soft })
hi(0, "CmpItemKindProperty",         { fg = c.fg_soft })
hi(0, "CmpItemKindSnippet",          { fg = c.green })
hi(0, "CmpItemMenu",                 { fg = c.fg_dim, italic = true })

-- Which-key
hi(0, "WhichKey",                    { fg = c.cyan })
hi(0, "WhichKeyGroup",               { fg = c.amber })
hi(0, "WhichKeyDesc",                { fg = c.fg })
hi(0, "WhichKeySeparator",           { fg = c.fg_dim })
hi(0, "WhichKeyFloat",               { bg = c.panel_alt })
hi(0, "WhichKeyBorder",              { fg = c.border, bg = c.panel_alt })

-- Indent-blankline
hi(0, "IblIndent",                   { fg = c.border })
hi(0, "IblScope",                    { fg = c.fg_dim })
hi(0, "IndentBlanklineChar",         { fg = c.border })
hi(0, "IndentBlanklineContextChar",  { fg = c.fg_dim })

-- Noice / notify
hi(0, "NoiceCmdline",                { fg = c.fg,      bg = c.panel_alt })
hi(0, "NoiceCmdlineIcon",            { fg = c.amber })
hi(0, "NoiceCmdlinePopupBorder",     { fg = c.border })
hi(0, "NotifyINFOBorder",            { fg = c.cyan })
hi(0, "NotifyINFOTitle",             { fg = c.cyan })
hi(0, "NotifyWARNBorder",            { fg = c.orange })
hi(0, "NotifyWARNTitle",             { fg = c.orange })
hi(0, "NotifyERRORBorder",           { fg = c.orange })
hi(0, "NotifyERRORTitle",            { fg = c.orange })

-- Lualine (statusline plugin) — use these color names in your lualine config
-- Normal:   fg = c.bg,     bg = c.amber   (active section)
-- Insert:   fg = c.bg,     bg = c.green
-- Visual:   fg = c.bg,     bg = c.purple
-- Replace:  fg = c.bg,     bg = c.orange
-- Command:  fg = c.bg,     bg = c.cyan

-- =============================================================================
-- TERMINAL COLORS (built-in :terminal)
-- =============================================================================

vim.g.terminal_color_0  = "#0c0b00"   -- black        → bg
vim.g.terminal_color_1  = "#cc5500"   -- red          → muted burnt orange
vim.g.terminal_color_2  = "#a3be8c"   -- green        → strings
vim.g.terminal_color_3  = "#ffb000"   -- yellow       → primary amber
vim.g.terminal_color_4  = "#89ddff"   -- blue         → cyan (functions)
vim.g.terminal_color_5  = "#c792ea"   -- magenta      → purple (keywords)
vim.g.terminal_color_6  = "#89ddff"   -- cyan         → same as blue
vim.g.terminal_color_7  = "#ffd86b"   -- white        → foreground amber
vim.g.terminal_color_8  = "#2a1f00"   -- bright black → border/muted
vim.g.terminal_color_9  = "#ff8f00"   -- bright red   → orange (warnings)
vim.g.terminal_color_10 = "#a3be8c"   -- bright green → strings
vim.g.terminal_color_11 = "#ffc94d"   -- bright yel   → soft amber
vim.g.terminal_color_12 = "#89ddff"   -- bright blue  → cyan
vim.g.terminal_color_13 = "#c792ea"   -- bright mag   → purple
vim.g.terminal_color_14 = "#89ddff"   -- bright cyan
vim.g.terminal_color_15 = "#ffd86b"   -- bright white → bright amber
