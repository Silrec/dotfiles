-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "<S-Tab>", "<C-v><Tab>", { desc = "Insert literal tab" })
vim.keymap.set({ "i", "c" }, "<C-BS>", "<C-w>", { desc = "Delete word backward" })
vim.keymap.set({ "i", "c" }, "<C-h>", "<C-w>", { desc = "Delete word backward" })
