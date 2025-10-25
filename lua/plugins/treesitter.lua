return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "css",
          "diff",
          "dockerfile",
          "eex",
          "elixir",
          "fish",
          "git_config",
          "git_rebase",
          "gitcommit",
          "gitignore",
          "heex",
          "html",
          "javascript",
          "json",
          "lua",
          "luadoc",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "regex",
          "ruby",
          "rust",
          "toml",
          "typescript",
          "vim",
          "vimdoc",
          "vue",
          "yaml",
        },
        auto_install = true,
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            scope_incremental = false,
            node_decremental = "<BS>",
          },
        },
      })

      -- Register bash parser for zsh files
      vim.treesitter.language.register("bash", "zsh")
    end,
  },
}
