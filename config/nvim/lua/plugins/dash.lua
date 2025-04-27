return {
  -- tell LazyVim: “when you load Snacks, merge in these extra options”
  "folke/snacks.nvim",
  optional = true, -- only runs if Snacks is present

  ---@param opts table  -- the options LazyVim already built
  opts = function(_, opts)
    -- make sure the tables exist (LazyVim always creates them, but be safe)
    opts.dashboard = opts.dashboard or {}
    opts.dashboard.preset = opts.dashboard.preset or {}

    -- ⬇️  your custom header art
    opts.dashboard.preset.header = [[


███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]]

    -- choose the color
    local violet = "#cba6f7" -- Catppuccin “mauve” (violet)
    local red = "#f28ba8" -- Catppuccin "flamingo" (pastel-pinkish--yellow)
    local yellow = "#f9e2af" -- Catppucin "yellow"
    local maroon = "#eba0ac" -- Catppucin "marroon" (pink-red)
    local lavender = "#b4befe" -- Catppucin "lavender"

    -- make header & desc mauve whenever the dashboard buffer is entered
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = violet, bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { fg = lavender, bg = "NONE" })

    -- 1) unlink + recolor the ASCII header
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { link = nil })
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = violet, bg = "NONE" })

    -- 2) recolor the left-hand icons
    vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = violet, bg = "NONE" })

    -- 3) recolor the righthand shortcuts on Dash
    vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = red, bg = "NONE" }) -- Apply color to the loading information text at the bottom

    -- 4) recolor the footer
    vim.api.nvim_set_hl(0, "SnacksDashboardFooter", { fg = red, bg = "NONE" })

    -- Alternative names if the above doesn't work
    --vim.api.nvim_set_hl(0, "SnacksDashboardStats", { fg = red, bg = "NONE" })
    --vim.api.nvim_set_hl(0, "SnacksDashboardLoading", { fg = red, bg = "NONE" })
  end,
}
