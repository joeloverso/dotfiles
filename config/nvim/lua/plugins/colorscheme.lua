-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
      flavour = "mocha",
      integrations = { alpha = true },
      custom_highlights = function(colors)
        return {
          Normal = { bg = "#11111b" }, -- Replace default catppuccin background color with desired
          NormalFloat = { bg = "#11111b" },
        }
      end,
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
