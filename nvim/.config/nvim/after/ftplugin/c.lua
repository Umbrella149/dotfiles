-- ============================================================================
-- C 语言的局部设置
-- ============================================================================
-- after/ftplugin/<文件类型>.lua 是 Neovim 原生机制：打开对应类型的文件时
-- 自动执行。比在 lua 里写一堆 FileType autocmd 干净得多。
--
-- 关键：这里必须用 vim.bo / vim.wo（buffer 局部 / window 局部），
-- 不要用 vim.o（全局），否则打开一个 C 文件会把全局设置也改掉。
--
-- 文件名就是 filetype。想知道当前文件的 filetype：`:set filetype?`
-- ============================================================================

vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true

-- 注释符号：让 gcc（注释一行）用 // 而不是 /* */
vim.bo.commentstring = '// %s'

-- 第 100 列画一条竖线，提醒行别写太长
vim.wo.colorcolumn = '100'
