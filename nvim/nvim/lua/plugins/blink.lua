return {
  {
    "saghen/blink.cmp",
    --   opts = {
    --     -- 'keymap' 定义了所有的快捷键
    --     keymap = {
    --       -- 禁用默认的预设，完全自定义或在特定预设基础上修改
    --       preset = "none",
    --
    --       -- 核心：Super-tab 设置
    --       ["<Tab>"] = {
    --         function(cmp)
    --           if cmp.snippet_active() then
    --             return cmp.snippet_forward()
    --           else
    --             return cmp.select_and_accept()
    --           end
    --         end,
    --         "snippet_forward",
    --         "fallback",
    --       },
    --       ["<S-Tab>"] = { "snippet_backward", "fallback" },
    --
    --       -- 这里的配置是为了确保方向键和 Enter 依然符合直觉
    --       ["<Up>"] = { "select_prev", "fallback" },
    --       ["<Down>"] = { "select_next", "fallback" },
    --       ["<C-p>"] = { "select_prev", "fallback" },
    --       ["<C-n>"] = { "select_next", "fallback" },
    --
    --       -- 如果你希望 Enter 恢复成纯粹的换行，不触发补全，就不要在这里定义 <CR>
    --       -- 如果希望 Enter 也能确认补全，可以取消下面一行的注释：
    --       -- ["<CR>"] = { "accept", "fallback" },
    --
    --       ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    --       ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    --       ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    --       ["<C-e>"] = { "hide", "fallback" },
    --     },
    --   },
  },
}
