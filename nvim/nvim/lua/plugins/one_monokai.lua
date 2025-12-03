-- ~/.config/nvim/lua/plugins/theme.lua
return {
  { "cpea2506/one_monokai.nvim" },
  -- Configure LazyVim to load
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "one_monokai",
      colors = {
        blue = "#e06c75",
      },
      highlights = function(colors)
        return {
          ["@type.builtin.c"] = { fg = colors.blue },
        }
      end,
    },
  },
}
