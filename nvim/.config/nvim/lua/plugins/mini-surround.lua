-- ============================================================================
-- mini.surround —— 操作「包围」符号（引号、括号、标签）
-- ============================================================================
-- 三个动作，都以 s（surround）开头：
--   sa  add     加上包围符号。用法：sa + 选什么范围 + 用什么包
--   sd  delete  删掉包围符号
--   sr  replace 换掉包围符号
--
-- 例子（光标在 hello 上）：
--   hello        按 saiw"   →  "hello"        （给一个词加双引号）
--   "hello"      按 sd"     →  hello          （删掉双引号）
--   "hello"      按 sr"'    →  'hello'        （双引号换单引号）
--   hello        按 saiw)   →  (hello)        （加括号）
--   visual 选中后按 sa"  →  给选中内容加引号
--
-- 记忆方法：s = surround，a/d/r = add/delete/replace。
-- 注意：它占用了 normal 模式的 s 键（原本等价于 cl，基本没人用）。
--
-- 官方文档：https://github.com/echasnovski/mini.surround
-- ============================================================================

require('mini.surround').setup({
  mappings = {
    add = 'sa',
    delete = 'sd',
    replace = 'sr',
    find = 'sf',           -- 跳到右边的包围符号
    find_left = 'sF',      -- 跳到左边的包围符号
    highlight = 'sh',      -- 高亮一下包围范围，看清楚再操作
    update_n_lines = 'sn', -- 调整搜索范围（默认只在附近 20 行内找）
  },
})
