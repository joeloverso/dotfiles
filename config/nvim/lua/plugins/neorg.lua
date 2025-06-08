return {
  "nvim-neorg/neorg",
  lazy = false,
  version = "*",
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {
          config = {
            --icon_preset = "diamond",
            icons = {
              heading = false,
            },
          },
        },
        ["core.dirman"] = {
          config = { workspaces = { notes = "~/notes" } },
        },
        ["core.esupports.hop"] = {
          config = {
            external_filetypes = {
              "png",
              "jpg",
              "jpeg",
              "gif",
              "webp",
              "bmp",
              "tiff",
              "tif",
              "svg",
            },
          },
        },
      },
    })

    -- Your existing image handler autocmd
    vim.api.nvim_create_autocmd("User", {
      pattern = "NeorgFiletypeDetected",
      callback = function(args)
        local ext = vim.fn.fnamemodify(args.file, ":e"):lower()
        if vim.tbl_contains({ "png", "jpg", "jpeg", "gif", "webp", "bmp", "tiff", "tif", "svg" }, ext) then
          vim.fn.system("eog " .. vim.fn.shellescape(args.file) .. " &")
          return true
        end
      end,
    })

    -- Add your page navigation mappings specifically for neorg
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "norg",
      callback = function()
        vim.keymap.set("n", "J", "<C-f>", { buffer = true, silent = true })
        vim.keymap.set("n", "K", "<C-b>", { buffer = true, silent = true })
      end,
    })
  end,
}
