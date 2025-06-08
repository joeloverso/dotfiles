local rainbow = {
  "#ff6c6b", -- 1 red
  "#da8548", -- 2 orange
  "#ecbe7b", -- 3 yellow
  "#98be65", -- 4 green
  "#51afef", -- 5 blue
  "#c678dd", -- 6 violet
}

local function apply_rainbow()
  for i, hex in ipairs(rainbow) do
    -- heading text  *and* the raw "**" stars
    vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".title.norg", { fg = hex, bold = true })
    vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".prefix.norg", { fg = hex, bold = true })
  end
end

-- run once now…
apply_rainbow()
-- …and again after *every* colourscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = apply_rainbow,
})
