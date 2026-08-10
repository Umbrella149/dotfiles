-- ============================================================================
-- mini.files —— 文件浏览器
-- ============================================================================
-- 它的核心思路：把目录当成一个可编辑的文本列表。
--   改文件名     → 直接像编辑文字一样改那一行
--   新建文件     → 新起一行写个名字
--   新建文件夹   → 新起一行写 名字/  （末尾带斜杠）
--   删除         → 删掉那一行
--   移动/复制    → 剪切(dd)或复制(yy)那一行，粘贴到另一个目录的面板里
--   改完按 = 才真正生效，会先弹出确认列表给你看
--
-- 它是多列的：越往右是越深的层级，所以多层级操作不会丢失上下文。
--
-- 打开后按 g? 看所有按键。常用：
--   h  返回上级        l  进入目录 / 打开文件
--   L  打开文件并关闭浏览器
--   =  确认所有改动    q  退出
--
-- 官方文档：https://github.com/echasnovski/mini.files
-- ============================================================================

require('mini.files').setup({
  windows = {
    preview = true,      -- 右侧预览光标所在的文件/目录
    width_focus = 30,
    width_preview = 50,
  },
  options = {
    -- 删除时移到「垃圾桶」目录而不是真删，误删了还能找回来
    permanent_delete = false,
    use_as_default_explorer = true,
  },
})

vim.keymap.set('n', '<leader>e', function()
  -- 在当前文件所在的目录打开，光标停在当前文件上
  local path = vim.api.nvim_buf_get_name(0)
  if path ~= '' and vim.uv.fs_stat(path) then
    require('mini.files').open(path, true)
  else
    require('mini.files').open(vim.uv.cwd(), true)
  end
end, { desc = '文件浏览器（当前文件位置）' })

vim.keymap.set('n', '<leader>E', function()
  require('mini.files').open(vim.uv.cwd(), true)
end, { desc = '文件浏览器（项目根目录）' })
