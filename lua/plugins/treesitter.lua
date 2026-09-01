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
    dependencies = {
      -- Same master/main split as nvim-treesitter itself, and for the same
      -- reason: textobjects' "main" targets the nvim-treesitter rewrite and
      -- registers nothing against the .configs API used below. Its default
      -- branch IS "main", so this pin is load-bearing, not decoration.
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    },
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
        -- Only `move` and `swap`. The `a`/`i` select textobjects (vaf, vif,
        -- vac, ...) come from mini.ai instead -- see plugins/mini-ai.lua for
        -- why, and note that mini.ai still reads this plugin's queries.
        textobjects = {
          move = {
            enable = true,
            -- record the pre-jump position, so <C-o> comes back
            set_jumps = true,
            -- ]c/[c are deliberately absent: gitsigns already owns those for
            -- hunk navigation (plugins/git.lua), so class jumps take ]C/[C.
            -- ]a/[a shadow the built-in argument-list :next/:previous, which
            -- nothing here uses; "a for argument" matches the swap keys below.
            goto_next_start = {
              ["]f"] = { query = "@function.outer", desc = "Next function" },
              ["]C"] = { query = "@class.outer", desc = "Next class" },
              ["]a"] = { query = "@parameter.inner", desc = "Next parameter" },
            },
            goto_next_end = {
              ["]F"] = { query = "@function.outer", desc = "Next function end" },
            },
            goto_previous_start = {
              ["[f"] = { query = "@function.outer", desc = "Prev function" },
              ["[C"] = { query = "@class.outer", desc = "Prev class" },
              ["[a"] = { query = "@parameter.inner", desc = "Prev parameter" },
            },
            goto_previous_end = {
              ["[F"] = { query = "@function.outer", desc = "Prev function end" },
            },
          },
          -- reorder arguments in place, without a yank/paste round trip
          swap = {
            enable = true,
            swap_next = {
              ["<leader>a"] = { query = "@parameter.inner", desc = "Swap parameter next" },
            },
            swap_previous = {
              ["<leader>A"] = { query = "@parameter.inner", desc = "Swap parameter prev" },
            },
          },
          -- The `repeatable_move` submodule (";"/"," repeating the jumps
          -- above) is left off on purpose: it works by remapping f/F/t/T,
          -- which eyeliner.nvim already owns (plugins/motions.lua). Taking
          -- those would kill its per-character hints.
        },
      })
      vim.treesitter.language.register("bash", "zsh")
      require("config.treesitter-query-fix").apply()
    end,
  },
}
