return {
  {
    -- sindrets/diffview.nvim has had no commits since 2024; this fork is
    -- actively maintained and stays API-compatible (same `diffview` module).
    "dlyongemallo/diffview.nvim",
    opts = function()
      local actions = require("diffview.actions")
      return {
        view = {
          merge_tool = {
            layout = "diff3_mixed",
            disable_diagnostics = true,
            winbar_info = true,
          },
        },
        keymaps = {
          view = {
            { "n", "<C-n>", actions.toggle_files, { desc = "Toggle the file panel" } },
          },
          file_panel = {
            { "n", "<C-n>", actions.toggle_files, { desc = "Toggle the file panel" } },
          },
        },
      }
    end
  }
}
