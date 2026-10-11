-- GitHub issues/PRs/reviews via the gh CLI. Keys live in a <leader>gh
-- subgroup so the rest of <leader>g stays free for local git (diff, blame,
-- hunks); <leader>o* would also clash with <leader>op (Neorg presenter).
return {
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/snacks.nvim",
      "nvim-mini/mini.icons",
    },
    keys = {
      { "<leader>ghi", "<cmd>Octo issue list<cr>", desc = "GitHub issues" },
      { "<leader>ghp", "<cmd>Octo pr list<cr>", desc = "GitHub pull requests" },
      { "<leader>ghd", "<cmd>Octo discussion list<cr>", desc = "GitHub discussions" },
      { "<leader>ghn", "<cmd>Octo notification list<cr>", desc = "GitHub notifications" },
      { "<leader>ghr", "<cmd>Octo review<cr>", desc = "Review PR for current branch" },
      {
        "<leader>ghs",
        function()
          require("octo.utils").create_base_search_command({ include_current_repo = true })
        end,
        desc = "Search GitHub",
      },
    },
    opts = {
      picker = "snacks",
      -- bare :Octo opens a picker of all actions
      enable_builtin = true,
      -- right side of reviews is the real file on disk (when on the PR
      -- branch) so the LSP attaches to it; otherwise falls back to GitHub's copy
      use_local_fs = true,
      -- reload open issue/PR buffers when they change on GitHub; buffers
      -- with unsaved edits are left alone (just a notification)
      poll = { enabled = true },
      -- mini.icons is already loaded for oil; avoids pulling in nvim-web-devicons
      file_panel = {
        icons = function(name, _)
          return require("mini.icons").get("file", name)
        end,
      },
    },
    config = function(_, opts)
      require("octo").setup(opts)
      -- octo buffers are markdown underneath; reuse that parser for highlighting
      vim.treesitter.language.register("markdown", "octo")
    end,
  },
}
