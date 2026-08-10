-- ============================================================================
-- catppuccin 主题
-- ============================================================================
-- 换风格：把 flavour 改成 latte（浅色）/ frappe / macchiato / mocha（最深）
-- 官方文档：https://github.com/catppuccin/nvim
-- ============================================================================

require('catppuccin').setup({
  flavour = 'mocha',
  transparent_background = true,  -- 想让终端背景透出来就改成 true

  -- 让注释变斜体、关键字加粗等。不喜欢就把对应项清空 {}
  styles = {
    comments = { 'italic' },
    conditionals = { 'italic' },
  },

  -- 给这些插件专门做过配色适配，开着效果更统一
  integrations = {
    gitsigns = true,
    fzf = true,
    mini = { enabled = true },
    which_key = true,
    treesitter = true,
    native_lsp = { enabled = true },
  },
})

vim.cmd.colorscheme('catppuccin')
