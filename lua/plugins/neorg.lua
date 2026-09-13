return {
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    dependencies = { "folke/zen-mode.nvim" },
    config = {
      load = {
        ["core.defaults"] = {},
        ["core.export"] = {},
        ["core.export.markdown"] = {},
        ["core.concealer"] = {
          config = {
            icon_preset = "diamond",
          },
        },
        ["core.presenter"] = {
          config = {
            zen_mode = "zen-mode",
          },
        },
      }
    },
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
  },
}
