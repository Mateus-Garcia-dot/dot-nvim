return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "olimorris/neotest-phpunit",
    "nvim-neotest/neotest-python",
  },
  keys = {
    { "<leader>tt", function() require("neotest").run.run() end,                     desc = "Test nearest", mode = { "n", "v" } },
    { "<leader>tc", function() require("neotest").run.run(vim.fn.expand("%")) end,   desc = "Test file",    mode = { "n", "v" } },
    { "<leader>ta", function() require("neotest").run.run(vim.uv.cwd()) end,         desc = "Test all",     mode = { "n", "v" } },
    { "<leader>to", function() require("neotest").summary.toggle() end,              desc = "Test summary", mode = { "n", "v" } },
    { "<leader>tO", function() require("neotest").output.open({ enter = true }) end, desc = "Test output",  mode = { "n", "v" } },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-phpunit"),
        require("neotest-python"),
      },
    })
  end,
}
