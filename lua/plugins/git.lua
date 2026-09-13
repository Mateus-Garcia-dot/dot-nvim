return {
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "dlyongemallo/diffview.nvim" },
    cmd = "Neogit",
    keys = {
      { "<leader>gs", "<cmd>Neogit<cr>", desc = "Git status", mode = { "n", "v" } },
    },
    config = true,
  },
}
