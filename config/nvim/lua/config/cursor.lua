vim.o.termguicolors = true -- true‑color on (harmless in Neovide, required in terminal)

-- One Flamingo‑pink + black group for every cursor shape you use
vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#f2cdcd" }) -- block
vim.api.nvim_set_hl(0, "lCursor", { fg = "#000000", bg = "#f2cdcd" }) -- bar
vim.api.nvim_set_hl(0, "CursorIM", { fg = "#000000", bg = "#f2cdcd" }) -- underline

-- Shapes ↔ highlight groups
vim.opt.guicursor = {
  "n-v-c-sm:block-Cursor", -- Normal, Visual, Command, Showmatch
  "i-ci-ve:ver25-lCursor", -- Insert, Cmdline‑insert, Visual‑exclusive
  "r-cr:hor20-CursorIM", -- Replace, Cmdline‑replace
}
