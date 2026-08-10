-- ============================================================================
-- 插件清单与加载策略
-- ============================================================================
-- 用的是 Neovim 0.12 自带的插件管理器 vim.pack，不需要装 lazy.nvim。
--
-- 【怎么加一个插件】
--   1. 在下面的 EAGER 或 LAZY 列表里加一行 gh('作者/仓库名')
--   2. 在 lua/plugins/ 下新建一个同名的配置文件，写它的 setup 和键位
--   3. 在本文件底部的 require 列表里加上它
--   4. 重启 nvim，会自动下载
--
-- 【怎么删一个插件】
--   1. 从列表和 require 里删掉
--   2. 删掉 lua/plugins/<它>.lua
--   3. 重启 nvim，然后执行 :lua vim.pack.del({'插件名'}) 把磁盘上的文件删掉
--
-- 【常用命令】
--   :lua vim.pack.update()                  更新全部插件（会先给你看 diff 再确认）
--   :lua vim.pack.update({'fzf-lua'})       只更新一个
--   :lua vim.pack.update(nil,{offline=true}) 离线查看当前装了些什么
--   版本锁定在 nvim-pack-lock.json，建议纳入 git
-- ============================================================================

local gh = function(repo) return 'https://github.com/' .. repo end

-- ---------------------------------------------------------------------------
-- 立即加载：影响「第一眼看到的画面」的插件，晚加载会闪烁
-- ---------------------------------------------------------------------------
vim.pack.add({
  { src = gh('catppuccin/nvim'), name = 'catppuccin' },
}, { confirm = false })

require('plugins.catppuccin')

-- ---------------------------------------------------------------------------
-- 延迟加载：等界面画完再加载，用户感知不到，但启动时间不算它们
-- ---------------------------------------------------------------------------
-- 这就是 LazyVim 里 `VeryLazy` 事件的原理，只不过这里是 6 行明明白白的代码。
-- UIEnter = 界面已经画出来了；vim.schedule = 再等主循环空闲的下一拍。
vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    vim.schedule(function() require('plugins.deferred') end)
  end,
})
