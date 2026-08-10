-- ============================================================================
-- Treesitter 语法高亮 —— 这一层是 Neovim 原生的，不需要任何插件
-- ============================================================================
-- 很多人以为「treesitter 高亮」是 nvim-treesitter 插件的功能，其实不是：
--   · 解析和高亮      → Neovim 内置（vim.treesitter）
--   · 下载语言 parser → 需要 nvim-treesitter 插件（见 lua/plugins/treesitter.lua）
--
-- Neovim 0.12 已经自带这几种语言的 parser，开箱即用：
--   c、lua、vim、vimdoc、markdown、query
-- 所以哪怕把 lua/plugins/ 全删了，写 C 和 Markdown 依然有完整高亮。
--
-- cpp、python、rust 这些需要用 `:TSInstall cpp` 装 parser（插件提供的命令）。
-- ============================================================================

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('TreesitterHighlight', { clear = true }),
  desc = '有 parser 就用 treesitter 高亮，没有就退回传统正则高亮',
  callback = function(args)
    -- 大文件跳过（autocmds.lua 里标记的），否则会卡
    if vim.b[args.buf].large_file then return end

    -- pcall = 「试着执行，失败也不报错」。
    -- 没装对应 parser 时 vim.treesitter.start 会失败，这时就保持 Neovim
    -- 传统的正则高亮，不影响使用。
    local ok = pcall(vim.treesitter.start, args.buf)
    if ok then
      -- treesitter 接管后关掉传统正则高亮，避免两套高亮打架
      vim.bo[args.buf].syntax = ''
    end
  end,
})
