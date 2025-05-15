-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-----------------------------------------------------------------
-- Neovide cursor color, remember to set these in your colorscheme
-- init.lua  ───────────────
-- The block itself is Flamingo, the text underneath is black.
-- Otherwise my cursor was white
vim.o.termguicolors = true
vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#f2cdcd" })

vim.opt.guicursor = {
  -- normal, visual, command, showmatch
  "n-v-c-sm:block-Cursor",
  -- insert, command‑insert, visual‑exclusive
  "i-ci-ve:ver25-Cursor",
  -- replace, command‑replace
  "r-cr:hor20-Cursor",
}

vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#f2cdcd" }) -- block
vim.api.nvim_set_hl(0, "lCursor", { fg = "#000000", bg = "#f2cdcd" }) -- bar
vim.api.nvim_set_hl(0, "CursorIM", { fg = "#000000", bg = "#f2cdcd" }) -- underline

-- Neorg concealer to give doper .norg view
vim.opt.conceallevel = 2
vim.opt.concealcursor = "nc" -- Optional: controls when conceal is applied (normal and command mode here)
