-- Parsers this config always wants on hand. Anything else is installed the
-- first time a buffer needs it (see the FileType autocmd below).
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

-- Like master's highlight/indent modules: only take over from regex syntax
-- and the filetype's own indent script where there's a query to replace them
-- with -- a parser with no indents query would otherwise get an indentexpr
-- that returns -1 (keep the current indent) on every line.
local function attach(buf, lang)
  if vim.treesitter.query.get(lang, "highlights") then
    vim.treesitter.start(buf, lang)
  end
  if vim.treesitter.query.get(lang, "indents") then
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- main is the maintained rewrite; master is frozen at nvim 0.11, and its
    -- query directives crashed on 0.12 (markdown code fences) until patched
    -- locally. main only installs parsers and queries: highlighting, indent
    -- and master's auto_install are wired up by hand below.
    branch = "main",
    lazy = false, -- main doesn't support lazy-loading
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      -- its own directory rather than the default stdpath("data")/site:
      -- kulala copies its kulala_http queries into site/queries, and main
      -- counts every directory there as an installed language -- so
      -- :TSUpdate (the build step above, on every plugin update) would try
      -- to update kulala_http and log "Parser not available" each time
      ts.setup({ install_dir = vim.fn.stdpath("data") .. "/treesitter" })
      vim.treesitter.language.register("bash", "zsh")

      -- main compiles parsers with the tree-sitter CLI rather than a bare C
      -- compiler; without it, keep highlighting whatever is installed already
      local can_install = vim.fn.executable("tree-sitter") == 1
      if can_install then
        ts.install(ensure) -- async, and a no-op for anything already installed
      else
        vim.notify(
          "tree-sitter CLI not found -- `brew install tree-sitter-cli` to install parsers.",
          vim.log.levels.WARN
        )
      end

      local available -- filled on first use; only changes when the plugin updates
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then
            return
          end
          if vim.treesitter.language.add(lang) then
            return attach(args.buf, lang)
          end

          -- master's auto_install: catches the long tail the list above
          -- misses (a one-off .tf or .graphql file) instead of silently
          -- falling back to regex syntax
          available = available or ts.get_available()
          if can_install and vim.list_contains(available, lang) then
            ts.install(lang):await(function(err)
              vim.schedule(function()
                if not err and vim.api.nvim_buf_is_valid(args.buf) and vim.treesitter.language.add(lang) then
                  attach(args.buf, lang)
                end
              end)
            end)
          end
        end,
      })
    end,
  },
}
