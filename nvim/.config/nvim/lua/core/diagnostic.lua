-- ============================================================================
-- 诊断（报错、警告、提示）的外观  ——  Neovim 原生功能，不是插件
-- ============================================================================
-- 「诊断」指的是 LSP / 编译器报给你的错误和警告。
-- 注意：这个文件只管「怎么显示」，不管「从哪来」。来源在 lua/lsp/ 里。
--
-- 原生就有的诊断跳转键（不需要配置，也不是插件给的）：
--   ]d / [d   下一个 / 上一个诊断
--   <C-w>d    在浮窗里看当前行的完整诊断信息
-- 原生只有「所有诊断」的跳转，没有「只跳错误、跳过警告」的，所以下面自己加了 ]e / [e
-- ============================================================================

vim.diagnostic.config({
  -- 行尾的简短提示文字。设成 false 可以关掉（有些人觉得吵）
  virtual_text = {
    prefix = '●',
    spacing = 2,
  },

  -- virtual_lines 是 0.11 的新功能：把完整诊断显示在下一行。
  -- 默认关掉（和 virtual_text 同时开会很挤），用 <leader>cd 临时切换，见下方。
  virtual_lines = false,

  -- 左侧标记栏的图标
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN]  = ' ',
      [vim.diagnostic.severity.INFO]  = ' ',
      [vim.diagnostic.severity.HINT]  = ' ',
    },
  },

  underline = true,       -- 出问题的代码加下划线
  update_in_insert = false, -- 打字时不要一直刷新诊断（很烦）
  severity_sort = true,     -- 错误排在警告前面

  -- 浮窗样式
  float = {
    border = 'rounded',
    source = true,   -- 显示是哪个工具报的（clangd / cppcheck ...）
  },
})

-- ---------------------------------------------------------------------------
-- 只在「错误」之间跳，跳过警告和提示
-- ---------------------------------------------------------------------------
-- 一个文件里警告往往很多（未使用的变量之类），真正要修的是错误。
-- ]d/[d 会挨个经过所有警告，很烦，所以补一组只看错误的。
vim.keymap.set('n', ']e', function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = '下一个错误' })

vim.keymap.set('n', '[e', function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = '上一个错误' })

-- <leader>cd 切换「详细诊断」显示模式
vim.keymap.set('n', '<leader>cd', function()
  local enabled = vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({
    virtual_lines = not enabled,
    virtual_text = enabled and { prefix = '●', spacing = 2 } or false,
  })
end, { desc = '切换详细诊断显示' })
