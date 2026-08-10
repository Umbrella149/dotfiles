-- ============================================================================
-- Markdown 的局部设置（写文档、笔记时用）
-- ============================================================================

-- 散文要自动折行，而且要按单词折而不是从中间切断
vim.wo.wrap = true
vim.wo.linebreak = true

-- 折行后，被折下来的部分保持原来的缩进（列表看起来才整齐）
vim.wo.breakindent = true

-- 折行时 j/k 按「屏幕上看到的一行」移动，而不是跳过整个长段落
vim.keymap.set({ 'n', 'v' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, buffer = true })
vim.keymap.set({ 'n', 'v' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, buffer = true })

vim.bo.shiftwidth = 2
vim.bo.tabstop = 2

-- 拼写检查（只检查英文；中文不受影响）。不想要就删掉这两行。
vim.wo.spell = true
vim.bo.spelllang = 'en_us'

-- 中文排版：允许在中文字符之间断行，不需要空格
vim.opt_local.formatoptions:append('m')
