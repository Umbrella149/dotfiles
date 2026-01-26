return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function(_, opts)
    local ls = require("luasnip")
    ls.setup(opts)
    -- 加载 VSCode 风格片段 (包括你自己的 json)
    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })
    -- === 关键步骤：让 markdown 继承 tex 的所有片段 ===
    -- ls.filetype_extend("markdown", { "tex" })
  end,
}
