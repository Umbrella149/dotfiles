-- ============================================================================
-- nvim-treesitter —— 只做一件事：下载语言 parser
-- ============================================================================
-- 高亮逻辑不在这里，在 lua/core/treesitter.lua（那是 Neovim 原生功能）。
-- 这个插件的唯一价值是帮你把 parser 编译好放到 Neovim 能找到的地方。
--
-- 【想给新语言加高亮】在下面 ENSURE 列表里加一行，重启即可；
--   或者临时用命令：`:TSInstall rust`
-- 【看支持哪些语言】`:TSInstall ` 然后按 Tab 补全
-- 【更新 parser】`:TSUpdate`
-- ============================================================================

require('nvim-treesitter').setup()

-- 需要的 parser。c/lua/vim/vimdoc/markdown/query 是 Neovim 自带的，
-- 列在这里是为了拿到更新的版本，删掉也不影响基本高亮。
local ENSURE = {
  'c',
  'cpp',              -- Neovim 没自带，写 C++ 必须装
  'cmake',
  'lua',
  'vim',
  'vimdoc',
  'query',
  'markdown',
  'markdown_inline',
  'bash',
  'json',
  'yaml',
  'toml',
  'diff',             -- 让 git diff / lazygit 的输出有颜色
  'gitcommit',        -- 写 commit message 时有高亮
}

-- 只装缺的，已经装过的跳过（否则每次启动都要检查一遍，很慢）
local ok, config = pcall(require, 'nvim-treesitter.config')
if ok then
  local installed = config.get_installed('parsers')
  local missing = vim.tbl_filter(function(lang)
    return not vim.tbl_contains(installed, lang)
  end, ENSURE)

  if #missing > 0 then
    vim.notify('正在安装 treesitter parser: ' .. table.concat(missing, ', '), vim.log.levels.INFO)
    require('nvim-treesitter').install(missing)
  end
end
