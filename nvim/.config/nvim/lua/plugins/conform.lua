-- ============================================================================
-- conform.nvim —— 代码格式化
-- ============================================================================
-- 【这玩意儿是干什么的】
-- 「格式化」就是自动把代码排版整齐：缩进对齐、大括号该换行的换行、空格该加的
-- 加上。每种语言都有各自的格式化工具（C/C++ 是 clang-format，Lua 是 stylua，
-- 前端是 prettier），它们是独立的命令行程序，用法各不相同。
--
-- conform 做的事只有一件：给这些工具提供一个统一的入口。
-- 配好之后，不管在什么文件里，你都只按 <leader>cf，它自己去找对应的工具。
-- 没有它的话，你得记住「C++ 文件要跑 clang-format、Lua 文件要跑 stylua」，
-- 还得自己处理光标位置、只格式化选中部分这些细节。
--
-- 【格式化规则从哪来】
-- conform 不决定代码长什么样，规则来自项目里的配置文件：
--   C/C++  →  项目根目录的 .clang-format
--   Lua    →  项目根目录的 .stylua.toml
-- 没有配置文件时用工具的默认风格。要改代码风格，是改那些文件，不是改这里。
--
-- 官方文档：https://github.com/stevearc/conform.nvim
-- 排查「为什么没格式化」：`:ConformInfo`
-- ============================================================================

require('conform').setup({
  -- 哪种文件用哪个工具。左边是 Neovim 的 filetype，右边是工具名。
  -- 加新语言就在这里加一行，然后用 pacman 把那个工具装上。
  formatters_by_ft = {
    c = { 'clang-format' },
    cpp = { 'clang-format' },
    lua = { 'stylua' },          -- 需要 `sudo pacman -S stylua`
    -- python = { 'ruff_format' },
    -- rust = { 'rustfmt' },
    -- json = { 'jq' },
  },

  -- 保存时自动格式化。默认关闭 —— 打开的话每次保存都会改动代码，
  -- 在别人的项目里容易搞出一堆无关 diff。
  -- 用 <leader>uf 可以随时开关（见下方）。
  format_on_save = function(bufnr)
    if not vim.g.autoformat then return nil end
    return { timeout_ms = 1000, lsp_format = 'fallback' }
  end,
})

vim.g.autoformat = false   -- 保存时自动格式化的默认状态

-- 手动格式化。visual 模式下只格式化选中的部分。
vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
  -- lsp_format = 'fallback' 的意思是：没配格式化工具时，退而用 LSP 自带的格式化
  require('conform').format({ async = true, lsp_format = 'fallback' })
end, { desc = '格式化代码' })

-- 开关「保存时自动格式化」
vim.keymap.set('n', '<leader>uf', function()
  vim.g.autoformat = not vim.g.autoformat
  vim.notify('保存时自动格式化：' .. (vim.g.autoformat and '开' or '关'))
end, { desc = '开关保存时自动格式化' })
