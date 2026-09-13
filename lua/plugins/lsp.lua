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
  "html",
  "pylsp",
  "jsonls",
  "lua_ls",
  "tailwindcss",
  "ts_ls",
  "elixirls",
}

local config = function()
  local capabilities = require("blink.cmp").get_lsp_capabilities()

  local watchman_available = require("config.lsp-watchman").apply()
  capabilities.workspace = capabilities.workspace or {}
  capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = watchman_available }

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

  -- servers that need nothing beyond capabilities; anything with its own
  -- settings (lua_ls, jsonls, yamlls, bashls) is configured separately below
  local plain_servers = {
    'standardrb', 'cssls', 'html', 'ts_ls', 'emmet_ls', 'volar', 'marksman',
    'tailwindcss', 'ansiblels', 'elixirls', 'docker_compose_language_service',
    'dockerls', 'pylsp', 'phpactor', 'taplo', 'rust_analyzer',
  }
  for _, server in ipairs(plain_servers) do
    vim.lsp.config(server, { capabilities = capabilities })
  end

  vim.lsp.config('lua_ls', {
    capabilities = capabilities,
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
    capabilities = capabilities,
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  })

  vim.lsp.config('yamlls', {
    capabilities = capabilities,
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
    capabilities = capabilities,
    filetypes = { 'sh', 'zsh' },
  })

  -- mason-lspconfig's `automatic_enable` (on by default) already calls
  -- vim.lsp.enable() for anything actually installed via Mason (currently
  -- bashls, cssls, docker_compose_language_service, dockerls, emmet_ls,
  -- html, jsonls, lua_ls, tailwindcss, ts_ls, pylsp). Only enable the
  -- servers here that are NOT Mason-managed on this machine.
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
