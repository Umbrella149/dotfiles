-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true, desc = "Exit Insert Mode with jk" })
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true, desc = "Exit Insert Mode with jk" })
vim.keymap.set("n", "D", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
