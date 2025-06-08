-- Neorg concealer to give doper .norg view
vim.opt.conceallevel = 2
vim.opt.concealcursor = "nc" -- Optional: controls when conceal is applied (normal and command mode here)

--------------------------------------------
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- Define Emacs-like colors for headers
    -- Adjust these hex values to match your preferred Emacs theme
    vim.api.nvim_set_hl(0, "@markup.heading.1.norg", { fg = "#FF6600" }) -- Emacs level 1 (often red/orange)
    vim.api.nvim_set_hl(0, "@markup.heading.2.norg", { fg = "#3366FF" }) -- Emacs level 2 (often blue)
    vim.api.nvim_set_hl(0, "@markup.heading.3.norg", { fg = "#50A14F" }) -- Emacs level 3 (often green)
    vim.api.nvim_set_hl(0, "@markup.heading.4.norg", { fg = "#986801" }) -- Emacs level 4 (often yellow/brown)
    vim.api.nvim_set_hl(0, "@markup.heading.5.norg", { fg = "#A626A4" }) -- Emacs level 5 (often purple)
    vim.api.nvim_set_hl(0, "@markup.heading.6.norg", { fg = "#E45649" }) -- Emacs level 6 (often red)
  end,
  group = vim.api.nvim_create_augroup("NeorgColors", { clear = true }),
})
