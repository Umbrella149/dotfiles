-- ============================================================================
-- 延迟加载的插件
-- ============================================================================
-- 这个文件在界面画完之后才执行，所以它里面的插件不占启动时间。
-- 判断一个插件该放这里还是 init.lua：
--   · 影响启动瞬间的画面（主题）→ init.lua
--   · 其他一律放这里
-- ============================================================================

local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add({
  -- treesitter：只用来「下载语言 parser」。高亮本身是 Neovim 原生的，
  -- 配置在 lua/core/treesitter.lua。
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },

  gh('ibhagwan/fzf-lua'),        -- 模糊查找（文件、内容、符号……）
  gh('lewis6991/gitsigns.nvim'), -- 行内 git 标记
  gh('echasnovski/mini.files'),  -- 文件浏览器
  gh('echasnovski/mini.surround'), -- 包围符号操作（引号、括号）
  gh('folke/which-key.nvim'),    -- 按键提示弹窗
  gh('stevearc/conform.nvim'),   -- 代码格式化
  -- blink.cmp
  gh('saghen/blink.lib'), -- 依赖
  gh('saghen/blink.cmp'), -- blink.cmp
}, { confirm = false })

-- 每个插件一个配置文件，顺序无所谓
require('plugins.treesitter')
require('plugins.fzf')
require('plugins.gitsigns')
require('plugins.mini-files')
require('plugins.mini-surround')
require('plugins.which-key')
require('plugins.conform')
require('plugins.blink-cmp')
