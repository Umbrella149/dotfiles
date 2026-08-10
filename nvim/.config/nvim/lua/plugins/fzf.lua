-- ============================================================================
-- fzf-lua —— 模糊查找器
-- ============================================================================
-- 为什么选它（不是 telescope）：它把搜索交给你系统里已经装好的 fzf 和 ripgrep
-- 这两个 C/Rust 写的命令行工具，所以在大仓库里明显更快，插件自身代码也少得多。
--
-- 用法：按下快捷键 → 输入几个字母（模糊匹配，不用连续）→ 回车打开
--   在结果列表里：<C-j>/<C-k> 上下移动，<C-x> 水平分屏打开，<C-v> 竖直分屏打开
--   <Tab> 多选，<C-q> 把所有结果送到 quickfix 列表
--
-- 官方文档：https://github.com/ibhagwan/fzf-lua
-- 看所有能用的搜索器：`:FzfLua` 然后按 Tab
-- ============================================================================

local fzf = require('fzf-lua')

fzf.setup({
  -- 'telescope' 是内置的一套外观预设（搜索框在上、预览在右）
  'telescope',
  winopts = {
    height = 0.85,
    width = 0.85,
    preview = { layout = 'flex' },  -- 窗口窄的时候预览自动挪到下方
  },
  files = {
    -- 用 fd 列文件：比 find 快，而且自动忽略 .gitignore 里的文件
    cmd = 'fd --type f --hidden --follow --exclude .git',
  },
})

-- fzf-lua 可以接管 Neovim 原生的选择弹窗（比如 LSP code action 的选项列表）
fzf.register_ui_select()

local map = vim.keymap.set

-- ---------------------------------------------------------------------------
-- 文件类  <leader>f
-- ---------------------------------------------------------------------------
map('n', '<leader><leader>', fzf.buffers,   { desc = '切换 buffer' })
map('n', '<leader>ff', fzf.files,           { desc = '查找文件' })
map('n', '<leader>fr', fzf.oldfiles,        { desc = '最近打开的文件' })
map('n', '<leader>fg', fzf.git_files,       { desc = '查找文件（只看 git 跟踪的）' })

-- ---------------------------------------------------------------------------
-- 搜索类  <leader>s
-- ---------------------------------------------------------------------------
map('n', '<leader>sg', fzf.live_grep,       { desc = '全局搜索内容' })
map('n', '<leader>sw', fzf.grep_cword,      { desc = '搜索光标下的词' })
map('v', '<leader>sw', fzf.grep_visual,     { desc = '搜索选中的内容' })
map('n', '<leader>/',  fzf.lgrep_curbuf,    { desc = '在当前文件里搜索' })
map('n', '<leader>sh', fzf.helptags,        { desc = '搜索帮助文档' })
map('n', '<leader>sk', fzf.keymaps,         { desc = '搜索键位（忘了快捷键就按这个）' })
map('n', '<leader>sd', fzf.diagnostics_document, { desc = '当前文件的诊断' })
map('n', '<leader>sD', fzf.diagnostics_workspace, { desc = '整个项目的诊断' })
map('n', '<leader>sr', fzf.resume,          { desc = '恢复上次的搜索' })
map('n', '<leader>sc', fzf.commands,        { desc = '搜索命令' })

-- ---------------------------------------------------------------------------
-- git 类  <leader>g  （另见 plugins/gitsigns.lua 和 core/keymaps.lua 的 lazygit）
-- ---------------------------------------------------------------------------
map('n', '<leader>gc', fzf.git_commits,     { desc = 'git 提交历史' })
map('n', '<leader>gC', fzf.git_bcommits,    { desc = '当前文件的提交历史' })
map('n', '<leader>gB', fzf.git_branches,    { desc = 'git 分支' })

-- ---------------------------------------------------------------------------
-- 代码导航  —— 用 LSP 的信息，但界面用 fzf
-- ---------------------------------------------------------------------------
-- 注意：Neovim 原生已经有 grr（找引用）、gri（找实现）、grn（重命名）等键位，
-- 用的是 quickfix 列表。下面这几个是「同样的功能，但用 fzf 界面」。
map('n', 'gd', fzf.lsp_definitions,         { desc = '跳到定义' })
map('n', 'gr', fzf.lsp_references,          { desc = '找所有引用' })
map('n', 'gI', fzf.lsp_implementations,     { desc = '跳到实现' })
map('n', 'gy', fzf.lsp_typedefs,            { desc = '跳到类型定义' })
map('n', '<leader>ss', fzf.lsp_document_symbols,   { desc = '当前文件的符号（函数/变量）' })
map('n', '<leader>sS', fzf.lsp_live_workspace_symbols, { desc = '整个项目的符号' })
