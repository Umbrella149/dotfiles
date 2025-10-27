-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.api.nvim_set_hl(
  0,
  "@type.builtin.c",
  vim.tbl_extend("force", vim.api.nvim_get_hl(0, { name = "@type.builtin.c" }), { italic = false, fg = "#61afef" })
)
vim.api.nvim_set_hl(
  0,
  "@type.builtin.cpp",
  vim.tbl_extend("force", vim.api.nvim_get_hl(0, { name = "@type.builtin.c" }), { italic = false, fg = "#61afef" })
)
