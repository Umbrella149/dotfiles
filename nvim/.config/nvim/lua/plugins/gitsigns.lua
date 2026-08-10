-- ============================================================================
-- gitsigns —— 在编辑器里看到 git 改动
-- ============================================================================
-- 效果：左边标记栏显示每一行是新增(│)、修改(│)还是删除(_)，
-- 状态栏的分支名也是它提供的（core/statusline.lua 里读 vim.b.gitsigns_head）。
--
-- 术语：hunk = 一块连续的改动。git 是按 hunk 为单位暂存(stage)的。
-- 官方文档：https://github.com/lewis6991/gitsigns.nvim
-- ============================================================================

require('gitsigns').setup({
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '' },
    topdelete    = { text = '' },
    changedelete = { text = '┃' },
    untracked    = { text = '┆' },
  },

  -- 行尾显示「这行是谁什么时候改的」。默认关，觉得有用就改成 true
  current_line_blame = false,
  current_line_blame_opts = { delay = 300 },

  on_attach = function(bufnr)
    local gs = require('gitsigns')
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- ] 和 [ 是 Neovim 的惯例：往后跳 / 往前跳
    map('n', ']h', function() gs.nav_hunk('next') end, '下一处改动')
    map('n', '[h', function() gs.nav_hunk('prev') end, '上一处改动')

    map('n', '<leader>gs', gs.stage_hunk,    '暂存这处改动')
    map('n', '<leader>gr', gs.reset_hunk,    '撤销这处改动')
    map('n', '<leader>gS', gs.stage_buffer,  '暂存整个文件')
    map('n', '<leader>gR', gs.reset_buffer,  '撤销整个文件的改动')
    map('n', '<leader>gp', gs.preview_hunk,  '预览这处改动')
    map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, '看这行的提交信息')
    map('n', '<leader>gd', gs.diffthis,      '和 HEAD 对比')

    -- visual 模式下：只暂存/撤销选中的那几行
    map('v', '<leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, '暂存选中的改动')
    map('v', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, '撤销选中的改动')

    -- ih 是一个「文本对象」：dih 删掉整块改动，vih 选中整块改动
    map({ 'o', 'x' }, 'ih', gs.select_hunk, '选中这处改动')
  end,
})
