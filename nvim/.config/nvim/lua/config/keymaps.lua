-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ══════════════════════════════════════════════════════════════════════
-- Disable Alt+j/k Move Line (Conflicts with Aerospace Window Manager)
-- ══════════════════════════════════════════════════════════════════════
-- LazyVim default: <A-j> and <A-k> move lines up/down in normal/insert/visual
-- Our Aerospace config uses Alt+j/k for window focus navigation (down/up)
-- Priority: System-level window manager > editor line movement convenience
--
-- Alternatives for line movement:
--   - LazyVim's [e and ]e (move line up/down, already mapped)
--   - Visual mode + :m '>+1 or :m '<-2 (classic vim)
--   - dd then p or P (cut and paste)

vim.keymap.del("n", "<A-j>")
vim.keymap.del("n", "<A-k>")
vim.keymap.del("i", "<A-j>")
vim.keymap.del("i", "<A-k>")
vim.keymap.del("v", "<A-j>")
vim.keymap.del("v", "<A-k>")
