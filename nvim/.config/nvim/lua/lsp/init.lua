-- ============================================================================
-- LSP —— 代码智能（补全、跳转、报错、重命名）
-- ============================================================================
-- 【概念】
-- LSP = Language Server Protocol。每种语言有一个独立的后台程序（叫 language
-- server），Neovim 把你的代码发给它，它回答「这个变量定义在哪」「这里写错了」
-- 之类的问题。所以：
--   · 装 language server 是系统层面的事    → 用 pacman 装
--   · Neovim 只负责「启动它、跟它说话」    → 就是这个文件夹
--
-- 【本配置不用 nvim-lspconfig 插件】
-- Neovim 0.11 起自带了 vim.lsp.config / vim.lsp.enable，配置一个 server 只要
-- 十来行，没必要为此装插件。
--
-- 【要加一门新语言？】看 docs/03-添加新语言.md，三步搞定。
-- 【排查问题】`:checkhealth vim.lsp`  和  `:LspInfo` 的替代命令 `:checkhealth lsp`
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. 启用哪些 language server
-- ---------------------------------------------------------------------------
-- 每个名字对应配置目录里的 lsp/<名字>.lua 文件（注意是根目录的 lsp/，
-- 不是 lua/lsp/。这是 Neovim 原生约定的查找路径）。
vim.lsp.enable({
  'clangd',   -- C / C++
})

-- ---------------------------------------------------------------------------
-- 2. LSP 连上某个文件时做什么
-- ---------------------------------------------------------------------------
-- LspAttach 事件：某个 language server 成功挂到某个 buffer 上了。
-- 键位写在这里而不是全局，是因为没有 LSP 的文件里按这些键没有意义。
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('MyLspAttach', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    local buf = args.buf

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    -- ---- 自动补全（Neovim 原生，不是 blink.cmp / nvim-cmp）----------------
    -- autotrigger = true 表示打字时自动弹出候选，不用手动按 <C-x><C-o>。
    -- 弹窗出来后的操作见本文件最下面的按键设置。
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end

    -- ---- 行内类型提示（inlay hint）----------------------------------------
    -- 就是灰色的「: int」「param:」这种提示。默认开，<leader>ch 可以关。
    if client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
      map('n', '<leader>ch', function()
        local on = vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
        vim.lsp.inlay_hint.enable(not on, { bufnr = buf })
      end, '开关行内类型提示')
    end

    -- ---- 光标停在某个变量上时，高亮它在本文件里的其他出现位置 -------------
    if client:supports_method('textDocument/documentHighlight') then
      local hl_group = vim.api.nvim_create_augroup('LspHighlight' .. buf, { clear = true })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = hl_group, buffer = buf, callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        group = hl_group, buffer = buf, callback = vim.lsp.buf.clear_references,
      })
    end

    -- ---- 键位 --------------------------------------------------------------
    -- 注意：下面这些是「额外加的」。Neovim 0.11 起原生就有这些，不用配：
    --   K    看文档            grn  重命名
    --   gra  代码修复建议      grr  找引用
    --   gri  跳到实现          grt  跳到类型定义
    -- 保留原生键位的同时，这里补上更符合 LazyVim 习惯的写法。
    map('n', '<leader>cr', vim.lsp.buf.rename,      '重命名符号')
    map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, '代码修复建议')
    map('n', 'gD', vim.lsp.buf.declaration,         '跳到声明')

    -- 插入模式看函数签名。
    -- （原生默认是 <C-s>，但我们把 <C-s> 给了「保存」，所以改用 <C-k>）
    map('i', '<C-k>', vim.lsp.buf.signature_help, '查看函数签名')

    -- clangd 独有：在 .c/.cpp 和 .h/.hpp 之间来回跳
    if client.name == 'clangd' then
      map('n', '<leader>co', '<cmd>LspClangdSwitchSourceHeader<cr>', '切换 源文件/头文件')
    end
  end,
})

-- ---------------------------------------------------------------------------
-- 3. 补全弹窗的按键
-- ---------------------------------------------------------------------------
-- 原生补全弹窗的默认操作是 <C-n>/<C-p> 选择、<C-y> 确认、<C-e> 取消。
-- 下面把 Tab 和回车也接上，用起来更接近常见编辑器。
--
-- pumvisible() = 补全弹窗是不是正显示着
-- vim.snippet.active() = 是不是正停在一个代码片段的占位符上
local function feed(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return feed('<C-n>')                        -- 弹窗开着 → 选下一项
  elseif vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)                          -- 在代码片段里 → 跳到下一个空
    return ''
  end
  return feed('<Tab>')                           -- 其他情况 → 正常打 Tab
end, { expr = true, desc = '补全 / 片段跳转 / Tab' })

vim.keymap.set('i', '<S-Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return feed('<C-p>')
  elseif vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
    return ''
  end
  return feed('<S-Tab>')
end, { expr = true, desc = '补全上一项 / 片段回跳' })

vim.keymap.set('i', '<CR>', function()
  -- 弹窗开着时回车 = 确认选中项；否则就是正常换行
  return vim.fn.pumvisible() == 1 and feed('<C-y>') or feed('<CR>')
end, { expr = true, desc = '确认补全 / 换行' })
