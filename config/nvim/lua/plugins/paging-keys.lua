---@type LazySpec[]
return {
  {
    -- we patch the key-list used by every LSP buffer
    "neovim/nvim-lspconfig",

    -- ⌨️  use the *opts()* hook the docs show
    opts = function(_, opts)
      local keys = require("lazyvim.plugins.lsp.keymaps").get()

      ------------------------------------------------------------------
      -- 1.  publish an **empty** buffer-local map for K
      --     → Neovim now thinks “K is already mapped” and will NOT
      --       install the built-in hover map when the client attaches
      ------------------------------------------------------------------
      keys[#keys + 1] = { "K", "" } -- "" = do nothing

      ------------------------------------------------------------------
      -- 2.  add your scrolling keys (still buffer-local, so nothing
      --     else can override them)
      ------------------------------------------------------------------
      keys[#keys + 1] = { "K", "<C-b>", desc = "Page-up", mode = "n" }
      keys[#keys + 1] = { "J", "<C-f>", desc = "Page-down", mode = "n" }

      ------------------------------------------------------------------
      -- 3. OPTIONAL – keep hover docs on <leader>k
      ------------------------------------------------------------------
      keys[#keys + 1] = {
        "<leader>k",
        vim.lsp.buf.hover,
        desc = "LSP hover",
        mode = "n",
      }
    end,
  },
}
