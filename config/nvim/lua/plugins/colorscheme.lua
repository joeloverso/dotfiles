-- ~/.config/nvim/lua/plugins/colorscheme.lua
-- Custom Catppuccin setup with Flamingo‑pink cursor
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
      flavor = "mocha",
      integrations = { alpha = true },
      custom_highlights = function(colors)
        return {
          -----------------------------------------------------------------
          -- UI background adjustments
          -----------------------------------------------------------------
          --Normal = { bg = "#11111b" }, -- darken main background
          Normal = { bg = "#000000" }, -- darken main background
          --NormalFloat = { bg = "#11111b" }, -- floating windows match
          NormalFloat = { bg = "#000000" }, -- floating windows match
          -----------------------------------------------------------------
          -- Flamingo cursor for all shapes / modes
          -----------------------------------------------------------------
          Cursor = { fg = "#000000", bg = "#f5e0dc" }, -- block cursor
          lCursor = { fg = "#000000", bg = "#f5e0dc" }, -- vertical bar cursor
          CursorIM = { fg = "#000000", bg = "#f5e0dc" }, -- underline cursor
        }
      end,
    },
  },
  -- Tell LazyVim to load Catppuccin as the active colorscheme
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
