-- ============================================================================
-- 自动命令（autocmd）—— 全部原生功能
-- ============================================================================
-- autocmd = 「当某件事发生时，自动做某件事」。
-- 常见事件：BufWritePre（保存前）、FileType（识别出文件类型时）、
--           BufReadPost（读完文件后）、VimResized（窗口大小变了）。
-- 查所有事件：`:help events`
-- 查当前生效的 autocmd：`:autocmd`
-- ============================================================================

-- 所有 autocmd 都挂在同一个 group 里。group 的作用是：配置重新加载时先清空旧的，
-- 否则同一个 autocmd 会被注册很多次，越用越卡。
local group = vim.api.nvim_create_augroup('MyConfig', { clear = true })
local autocmd = function(event, opts)
  opts.group = group
  vim.api.nvim_create_autocmd(event, opts)
end

-- ---------------------------------------------------------------------------
-- 保存时自动删掉行尾多余的空格
-- ---------------------------------------------------------------------------
autocmd('BufWritePre', {
  desc = '删除行尾空格',
  callback = function()
    local cursor = vim.api.nvim_win_get_cursor(0)  -- 记住光标位置
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    pcall(vim.api.nvim_win_set_cursor, 0, cursor)  -- 恢复光标位置
  end,
})

-- ---------------------------------------------------------------------------
-- 重新打开文件时，光标回到上次离开的位置
-- ---------------------------------------------------------------------------
autocmd('BufReadPost', {
  desc = '恢复上次的光标位置',
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ---------------------------------------------------------------------------
-- 终端 buffer 里不要行号和标记栏（会很丑）
-- ---------------------------------------------------------------------------
autocmd('TermOpen', {
  desc = '终端界面简化',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
})

-- ---------------------------------------------------------------------------
-- 在这些只读窗口里按 q 直接关掉（帮助文档、quickfix 等）
-- ---------------------------------------------------------------------------
autocmd('FileType', {
  desc = '临时窗口按 q 关闭',
  pattern = { 'help', 'qf', 'man', 'checkhealth', 'lspinfo' },
  callback = function(args)
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = args.buf, silent = true })
  end,
})

-- ---------------------------------------------------------------------------
-- 终端窗口大小变化时，自动重排 nvim 的分屏
-- ---------------------------------------------------------------------------
autocmd('VimResized', {
  desc = '窗口大小变化时重排分屏',
  callback = function() vim.cmd('tabdo wincmd =') end,
})

-- ---------------------------------------------------------------------------
-- 打开超大文件时关掉高亮，防止卡死
-- ---------------------------------------------------------------------------
autocmd('BufReadPre', {
  desc = '大文件降级处理',
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 1024 * 1024 then  -- 大于 1MB
      vim.b[args.buf].large_file = true
      vim.opt_local.foldmethod = 'manual'
      vim.opt_local.undofile = false
    end
  end,
})
