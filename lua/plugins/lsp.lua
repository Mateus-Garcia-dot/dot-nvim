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
  "standardrb",
  "tailwindcss",
  "ts_ls",
  "volar",
  "elixir-ls",
}

local config = function()
  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  local mason = require("mason")
  local mason_lspconfig = require("mason-lspconfig")

  -- Keymaps on LspAttach
  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP Actions",
    callback = function(event)
      local opts = { buffer = event.buf }

      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)
      vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
      vim.keymap.set({ "n", "x" }, "<F3>", function() vim.lsp.buf.format({ async = true }) end, opts)
      vim.keymap.set("n", "<F4>", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    end,
  })

  -- Setup Mason
  mason.setup(mason_opts)
  mason_lspconfig.setup({ ensure_installed = ensure_installed })

  -- Define LSP configs
  vim.lsp.config('standardrb', { capabilities = capabilities })
  vim.lsp.config('jsonls', { capabilities = capabilities })
  vim.lsp.config('cssls', { capabilities = capabilities })
  vim.lsp.config('html', { capabilities = capabilities })
  vim.lsp.config('ts_ls', { capabilities = capabilities })
  vim.lsp.config('emmet_ls', { capabilities = capabilities })
  vim.lsp.config('volar', { capabilities = capabilities })
  vim.lsp.config('marksman', { capabilities = capabilities })
  vim.lsp.config('tailwindcss', { capabilities = capabilities })
  vim.lsp.config('ansiblels', { capabilities = capabilities })
  vim.lsp.config('yamlls', { capabilities = capabilities })
  vim.lsp.config('elixirls', { capabilities = capabilities })
  vim.lsp.config('docker_compose_language_service', { capabilities = capabilities })
  vim.lsp.config('dockerls', { capabilities = capabilities })
  vim.lsp.config('pylsp', { capabilities = capabilities })
  vim.lsp.config('intelephense', { capabilities = capabilities })
  vim.lsp.config('taplo', { capabilities = capabilities })
  vim.lsp.config('rust_analyzer', { capabilities = capabilities })

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

  vim.lsp.config('bashls', {
    capabilities = capabilities,
    filetypes = { 'sh', 'zsh' },
  })

  -- Enable all servers
  vim.lsp.enable({
    'standardrb',
    'lua_ls',
    'jsonls',
    'cssls',
    'html',
    'ts_ls',
    'emmet_ls',
    'volar',
    'marksman',
    'tailwindcss',
    'bashls',
    'ansiblels',
    'yamlls',
    'elixirls',
    'docker_compose_language_service',
    'dockerls',
    'pylsp',
    'intelephense',
    'taplo',
    'rust_analyzer',
  })

  -- nvim-cmp setup
  local cmp = require("cmp")
  cmp.setup({
    sources = {
      { name = "nvim_lsp" },
      { name = "vim-dadbod-completion", priority = 700 },
    },
    mapping = cmp.mapping.preset.insert({
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end),
    }),
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
  })
end

return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    lazy = false,
    config = config,
  },
}
