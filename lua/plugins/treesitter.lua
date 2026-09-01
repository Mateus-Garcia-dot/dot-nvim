-- Parsers for every language with an LSP configured in plugins/lsp.lua, plus
-- the ones neovim itself is written in (lua/vim/query) since this config is
-- edited more than anything else. norg is deliberately absent: neorg pins and
-- installs its own tree-sitter-norg, and listing it here fights that.
--
-- neotest's adapters run treesitter queries to find tests, so php/python
-- aren't optional decoration -- without them `<leader>tt` finds nothing.
--
-- jsonc is deliberately omitted: its upstream tarball is currently corrupt
-- ("tar: Unrecognized archive format"), which would fail on every startup.
-- json covers .json; auto_install picks jsonc up if upstream ever fixes it.
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
