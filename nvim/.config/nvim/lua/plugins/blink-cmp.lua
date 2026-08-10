-- ============================================================================
-- 补全：blink.cmp（nvim-cmp 的替代品）
-- ============================================================================
-- 依赖 blink.lib。装好后需要一次编译，所以 setup 前要 pwait。
-- 它和你的 treesitter / conform / 原生 LSP 不冲突，直接可用。

local cmp = require('blink.cmp')
cmp.build():pwait()
cmp.setup()
