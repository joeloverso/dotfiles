-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Enables Cntrl+Backspace to delete previous word
vim.keymap.set("i", "<C-BS>", "<C-W>", { desc = "Delete previous word", noremap = true, silent = true })
vim.keymap.set("i", "<C-H>", "<C-W>", { desc = "Delete previous word", noremap = true, silent = true })
-- Variable/ function rename with leader+r
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
-- Navigate between windows with Ctrl+h and Ctrl+l
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", silent = true })
-- Reset Ctrl+F to default behavior (full page down)
vim.keymap.del("n", "<C-f>")
-- open a new line *below* the cursor and stay in Normal mode
vim.keymap.set("n", "O", "o<Esc>", { desc = "Open line below (Normal mode)" })
-- Map H to jump to first non-blank character (same as ^)
vim.keymap.set({ "n", "v", "o" }, "H", "^", { desc = "Jump to first non-blank character", noremap = true })
-- Map L to jump to last character (same as $)
vim.keymap.set({ "n", "v", "o" }, "L", "$", { desc = "Jump to last non-blank character", noremap = true })
-- Map J to page down
vim.keymap.set("n", "J", "<C-f>", { desc = "Pagedown", noremap = true })
-- Map K to page up
vim.keymap.set("n", "K", "<C-b>", { desc = "Pageup", noremap = true })
-- Delete to black hole register
vim.keymap.set("n", "d", '"_d', { desc = "Delete to blank register", noremap = true })
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line to blank register", noremap = true })
vim.keymap.set("v", "d", '"_d', { desc = "Delete selection to blank register", noremap = true })
-- Delete character to black hole register
vim.keymap.set("n", "x", '"_x', { desc = "Delete character to blank register", noremap = true })
vim.keymap.set("v", "x", '"_x', { desc = "Delete selection to blank register", noremap = true })
