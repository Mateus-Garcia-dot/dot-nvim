return {
  "ahmedkhalf/project.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  event = "VeryLazy",
  opts = {
    detection_methods = { "pattern" },
    patterns = { ".git" },
  },
  config = function(_, opts)
    require("project_nvim").setup(opts)
    require("telescope").load_extension("projects")
  end,
}
