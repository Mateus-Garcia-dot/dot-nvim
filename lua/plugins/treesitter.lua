local ensure = {
  "bash",
  "c",
  "css",
  "diff",
  "dockerfile",
  "eex",
  "elixir",
  "git_rebase",
  "gitcommit",
  "heex",
  "html",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "php",
  "phpdoc",
  "python",
  "query",
  "regex",
  "ruby",
  "rust",
  "scss",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "vue",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- upstream's default branch is "main" (an in-progress breaking rewrite);
    -- this config uses the .configs/.setup() API from "master", so pin it
    -- explicitly instead of relying on lazy-lock.json alone.
    branch = "master",
    build = ":TSUpdate",
    init = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        ensure_installed = ensure,
        -- catches the long tail the list above misses (a one-off .tf or
        -- .graphql file) instead of silently falling back to regex syntax
        auto_install = true,
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
      vim.treesitter.language.register("bash", "zsh")
      require("config.treesitter-query-fix").apply()
    end,
  },
}
