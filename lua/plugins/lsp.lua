local mason_opts = {
  ui = {
    border = "rounded",
  },
}

local ensure_installed = {
  "bashls",
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "emmet_ls",
  "harper_ls",
  "html",
  "pylsp",
  "jsonls",
  "lua_ls",
  "tailwindcss",
  "ts_ls",
  "elixirls",
}

local config = function()
  -- show the full diagnostic message on its own line below the cursor's
  -- line, instead of (or in addition to) the truncated end-of-line text
  vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = { current_line = true },
  })

  -- '*' is merged into every server's config. blink.cmp's plugin/ file (it's
  -- a dependency below, so it has already run) put its completion
  -- capabilities there, and vim.lsp.config() deep-merges -- so this only
  -- layers the file-watching flag on top, and no server needs its own
  -- `capabilities`.
  local watchman_available = require("config.lsp-watchman").apply()
  vim.lsp.config('*', {
    capabilities = {
      workspace = { didChangeWatchedFiles = { dynamicRegistration = watchman_available } },
    },
  })

  require("config.lsp-progress").setup()

  local mason = require("mason")
  local mason_lspconfig = require("mason-lspconfig")
  -- module names stay "mason"/"mason-lspconfig" regardless of the org the
  -- repo lives under -- only the plugin spec source needed updating

  -- nvim-lspconfig stopped defining these once nvim's native `:lsp` command
  -- appeared, assuming it covered the same ground -- but `:lsp` only has
  -- enable/disable/restart/stop, no log viewer. Restore the shortcuts.
  vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd("tabnew " .. vim.lsp.log.get_filename())
  end, { desc = "Opens the Nvim LSP client log." })

  vim.api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", { desc = "Alias to `:checkhealth vim.lsp`" })

  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP Actions",
    callback = function(event)
      local opts = { buffer = event.buf }

      -- bare key on the left, <leader>l... eglot-style mirror on the right;
      -- a couple (gs/[d/]d, <leader>ld) only exist on one side
      local maps = {
        { bare = "K", leader = "lh", action = vim.lsp.buf.hover },
        { bare = "gd", leader = "lgd", action = function() require("snacks").picker.lsp_definitions() end },
        { bare = "gD", leader = "lgD", action = vim.lsp.buf.declaration },
        { bare = "gi", leader = "lgi", action = function() require("snacks").picker.lsp_implementations() end },
        { bare = "go", leader = "lgy", action = function() require("snacks").picker.lsp_type_definitions() end },
        { bare = "gr", leader = "lgr", action = function() require("snacks").picker.lsp_references() end },
        { bare = "gs", action = vim.lsp.buf.signature_help },
        { bare = "<F2>", leader = "lr", action = vim.lsp.buf.rename },
        { bare = "<F3>", bare_modes = { "n", "x" }, leader = "lf", action = function() vim.lsp.buf.format({ async = true }) end },
        { bare = "<F4>", leader = "la", action = vim.lsp.buf.code_action },
        { bare = "gl", leader = "le", action = vim.diagnostic.open_float },
        { bare = "[d", action = vim.diagnostic.goto_prev },
        { bare = "]d", action = vim.diagnostic.goto_next },
        { leader = "ld", action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>" },
      }
      for _, m in ipairs(maps) do
        if m.bare then
          vim.keymap.set(m.bare_modes or "n", m.bare, m.action, opts)
        end
        if m.leader then
          vim.keymap.set({ "n", "v" }, "<leader>" .. m.leader, m.action, opts)
        end
      end
    end,
  })

  mason.setup(mason_opts)
  mason_lspconfig.setup({ ensure_installed = ensure_installed })

  vim.lsp.config('lua_ls', {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim", "describe", "it", "before_each", "after_each" },
        },
      },
    },
  })

  -- jsonls/yamlls both ship with zero schemas by default, so package.json,
  -- tsconfig.json, .eslintrc, docker-compose.yml and GitHub Actions
  -- workflows were being treated as anonymous JSON/YAML -- no completion, no
  -- validation, no hover docs on keys. SchemaStore.nvim is a data-only
  -- plugin that vendors the schemastore.org catalog, so this needs no
  -- network access at runtime.
  vim.lsp.config('jsonls', {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  })

  vim.lsp.config('yamlls', {
    settings = {
      yaml = {
        -- yamlls has its own SchemaStore client, which would register every
        -- schema a second time (and fetch the catalog over HTTP on each
        -- start). Turn it off and let the vendored copy above be the only
        -- source.
        schemaStore = { enable = false, url = "" },
        schemas = require('schemastore').yaml.schemas(),
      },
    },
  })

  vim.lsp.config('bashls', {
    filetypes = { 'sh', 'zsh' },
  })

  -- Spelling/prose pair. typos-lsp wraps crate-ci/typos, which only reports a
  -- word when it has a confident correction for it -- cheap enough and quiet
  -- enough to run over every filetype. harper-ls is a full prose linter, so it
  -- stays on prose filetypes only (see below).
  --
  -- typos-lsp takes init_options, not `settings`. A repo's own config file
  -- (typos.toml / _typos.toml / .typos.toml, also a root marker) still wins
  -- over anything set here, which is where per-project allowed words belong.
  vim.lsp.config('typos_lsp', {
    -- deliberately no `filetypes`: nil means "attach to every filetype".
    init_options = {
      -- upstream default is "Info"; a real typo in an identifier or a doc is
      -- worth a warning sign, and false positives are rare enough for that.
      diagnosticSeverity = "Warning",
    },
    -- the server logs every document sync at info level otherwise
    cmd_env = { RUST_LOG = "typos_lsp=error" },
  })

  -- harper is the actual spell checker of the two: it carries an English
  -- dictionary, so it catches `lazzy`/`jumpd`/`fense` -- misspellings typos-lsp
  -- has no entry for and therefore stays silent about. In code filetypes it
  -- parses with treesitter and only lints comments and strings, so no
  -- `filetypes` override here: upstream's list (php, ruby, python, lua, js,
  -- ts, go, rust, sh, html, toml, c/cpp, ... plus markdown/gitcommit/tex) is
  -- what we want. Anything NOT on that list would be linted as if the whole
  -- file were prose, which is why widening it further is a bad idea.
  vim.lsp.config('harper_ls', {
    filetypes = vim.list_extend(
      vim.deepcopy(vim.lsp.config.harper_ls.filetypes),
      -- upstream ships no plain-text entry, and `text` is what a stray .txt
      -- or a `:setf text` scratch buffer lands on
      { 'text' }
    ),
    settings = {
      ["harper-ls"] = {
        -- default on macOS is ~/Library/Application Support/harper-ls/
        -- dictionary.txt; pointing it here means the words added via the
        -- "add to dictionary" code action are version-controlled with the rest
        -- of the config instead of being lost on the next machine.
        userDictPath = vim.fn.stdpath("config") .. "/spell/harper-dictionary.txt",
        dialect = "American",
        diagnosticSeverity = "hint",
        linters = {
          -- style opinions rather than mistakes, and noisy on commit messages,
          -- bullet lists and (sentence-case) headings. Every other linter --
          -- SpellCheck, RepeatedWords, AnA, UnclosedQuotes... -- stays default.
          LongSentences = false,
          SentenceCapitalization = false,
          UseTitleCase = false,
        },
      },
    },
  })

  -- mason-lspconfig's `automatic_enable` (on by default) already calls
  -- vim.lsp.enable() for anything actually installed via Mason (currently
  -- bashls, cssls, docker_compose_language_service, dockerls, emmet_ls,
  -- html, jsonls, lua_ls, tailwindcss, ts_ls, pylsp, and now harper_ls and
  -- typos_lsp). Only enable the servers here that are NOT Mason-managed on
  -- this machine.
  vim.lsp.enable({
    'marksman',
    'ansiblels',
    'yamlls',
    'elixirls',
    'taplo',
    'rust_analyzer',
  })
end

return {
  {
    "mason-org/mason.nvim",
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
      "rafamadriz/friendly-snippets",
      "folke/snacks.nvim",
      { "b0o/SchemaStore.nvim", version = false },
    },
    lazy = false,
    config = config,
  },
}
