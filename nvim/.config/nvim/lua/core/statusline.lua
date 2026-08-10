-- ============================================================================
-- 状态栏（最底下那一条）—— 手写，不用 lualine
-- ============================================================================
-- 为什么手写：lualine 是一套自己的配置语言，你要改还得先学它。这里就是普通
-- Lua 字符串拼接，想加什么就在 render() 里 append 一段。
--
-- 效果大致是：
--   NORMAL │ src/main.cpp [+]        main   2  1 │ cpp │ 12:34 │ 45%
--
-- 想删掉某一块：在最下面的 render() 里删掉对应的 add(...) 那一行即可。
-- ============================================================================

local M = {}

-- ---------------------------------------------------------------------------
-- 1. 模式名称与配色
-- ---------------------------------------------------------------------------
-- 左边那个 NORMAL / INSERT 色块。key 是 Neovim 的模式代号（`:help mode()`）
local MODES = {
  n       = { 'NORMAL',   'StlNormal'  },
  i       = { 'INSERT',   'StlInsert'  },
  v       = { 'VISUAL',   'StlVisual'  },
  V       = { 'V-LINE',   'StlVisual'  },
  ['\22'] = { 'V-BLOCK',  'StlVisual'  },  -- \22 是 Ctrl-V
  s       = { 'SELECT',   'StlVisual'  },
  S       = { 'S-LINE',   'StlVisual'  },
  R       = { 'REPLACE',  'StlReplace' },
  c       = { 'COMMAND',  'StlCommand' },
  t       = { 'TERMINAL', 'StlCommand' },
}

-- 从主题里「借」颜色来定义状态栏的高亮组。
-- 这样换主题（比如从 catppuccin 换成别的）时，状态栏会自动跟着变色。
local function setup_highlights()
  local function fg_of(group)
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    return hl.fg
  end

  local bg = vim.api.nvim_get_hl(0, { name = 'StatusLine', link = false }).bg

  local pairs_ = {
    StlNormal  = fg_of('Function'),   -- 蓝色系
    StlInsert  = fg_of('String'),     -- 绿色系
    StlVisual  = fg_of('Statement'),  -- 紫色系
    StlReplace = fg_of('Error'),      -- 红色系
    StlCommand = fg_of('Constant'),   -- 橙/黄色系
    StlDim     = fg_of('Comment'),    -- 灰色，用于次要信息
  }

  for name, color in pairs(pairs_) do
    -- 模式块用「反色」：把颜色当背景，加粗
    if name == 'StlDim' then
      vim.api.nvim_set_hl(0, name, { fg = color, bg = bg })
    else
      vim.api.nvim_set_hl(0, name, { fg = bg, bg = color, bold = true })
    end
  end
end

-- ---------------------------------------------------------------------------
-- 2. 各个组件
-- ---------------------------------------------------------------------------

local function mode_block()
  local m = vim.api.nvim_get_mode().mode
  local info = MODES[m] or MODES[m:sub(1, 1)] or { m:upper(), 'StlNormal' }
  return string.format('%%#%s# %s %%*', info[2], info[1])
end

-- git 分支名。数据来自 gitsigns 插件；插件没装就什么都不显示。
local function git_branch()
  local head = vim.b.gitsigns_head
  if not head or head == '' then return '' end
  return string.format('%%#StlDim# %s %%*', head)
end

-- 诊断计数：  2  1
local function diagnostics()
  local counts = vim.diagnostic.count(0)
  local out = {}
  local items = {
    { vim.diagnostic.severity.ERROR, ' ', 'DiagnosticError' },
    { vim.diagnostic.severity.WARN,  ' ', 'DiagnosticWarn'  },
    { vim.diagnostic.severity.INFO,  ' ', 'DiagnosticInfo'  },
    { vim.diagnostic.severity.HINT,  ' ', 'DiagnosticHint'  },
  }
  for _, item in ipairs(items) do
    local n = counts[item[1]]
    if n and n > 0 then
      table.insert(out, string.format('%%#%s#%s%d%%*', item[3], item[2], n))
    end
  end
  if #out == 0 then return '' end
  return ' ' .. table.concat(out, ' ') .. ' '
end

-- 当前挂载的 LSP 名字（比如 clangd）。没有就不显示。
local function lsp_name()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return '' end
  local names = {}
  for _, c in ipairs(clients) do table.insert(names, c.name) end
  return string.format('%%#StlDim# %s %%*', table.concat(names, ','))
end

-- ---------------------------------------------------------------------------
-- 3. 组装
-- ---------------------------------------------------------------------------
-- 下面这些 %x 是 Neovim 状态栏的占位符语法（`:help 'statusline'`）：
--   %f 文件相对路径   %m 修改标记[+]   %r 只读标记
--   %= 左右分隔（右边的内容靠右对齐）
--   %y 文件类型       %l 行号   %c 列号   %P 位置百分比
function M.render()
  local parts = {
    mode_block(),
    ' %f%m%r',                      -- 文件名 + 修改标记
    ' %=',                          -- ← 这里之后的内容全部靠右
    git_branch(),
    diagnostics(),
    lsp_name(),
    '%#StlDim# %{&filetype} %*',    -- 文件类型
    ' %l:%c ',                      -- 行:列
    '%#StlDim# %P %*',              -- 百分比
  }
  return table.concat(parts)
end

-- ---------------------------------------------------------------------------
-- 4. 启用
-- ---------------------------------------------------------------------------
-- %! 表示「每次重画都执行这个表达式，用返回值当状态栏」
vim.o.statusline = "%!v:lua.require'core.statusline'.render()"

setup_highlights()
-- 换主题后重新取色
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('StatuslineColors', { clear = true }),
  callback = setup_highlights,
})

return M
