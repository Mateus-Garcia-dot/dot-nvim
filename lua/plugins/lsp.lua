local mason_opts = {
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
    border = "rounded",
  },
}

local ensure_installed = {
  "ansiblels",
  "bashls",
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "elixirls",
  "emmet_ls",
  "html",
  "intelephense",
  "jsonls",
  "lua_ls",
  "marksman",
  "pylsp",
  "rust_analyzer",
  "standardrb",
  "tailwindcss",
  "taplo",
  "ts_ls",
  "volar",
  "yamlls",
}

local config = function()
  local lspconfig = require("lspconfig")
  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  local mason = require("mason")
  local mason_lspconfig = require("mason-lspconfig")

  require("lspconfig.ui.windows").default_options.border = "rounded"

  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP Actions",
    callback = function(event)
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
      end

      -- LSP actions
      map("K", vim.lsp.buf.hover, "Hover Documentation")
      map("gd", vim.lsp.buf.definition, "Goto Definition")
      map("gD", vim.lsp.buf.declaration, "Goto Declaration")
      map("gi", vim.lsp.buf.implementation, "Goto Implementation")
      map("go", vim.lsp.buf.type_definition, "Goto Type Definition")
      map("gr", vim.lsp.buf.references, "Goto References")
      map("gs", vim.lsp.buf.signature_help, "Signature Help")
      map("<F2>", vim.lsp.buf.rename, "Rename")
      map("<F4>", vim.lsp.buf.code_action, "Code Action")

      -- Format on both normal and visual modes
      vim.keymap.set({ "n", "x" }, "<F3>", function()
        vim.lsp.buf.format({ async = true })
      end, { buffer = event.buf, desc = "LSP: Format" })

      -- Diagnostics
      map("gl", vim.diagnostic.open_float, "Show Diagnostics")
      map("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
      map("]d", vim.diagnostic.goto_next, "Next Diagnostic")
    end,
  })

  -- Setup Mason
  mason.setup(mason_opts)
  mason_lspconfig.setup({ ensure_installed })

  -- Ruby (formatting by StandardRB via autocmds.lua)
  lspconfig.standardrb.setup({
    capabilities = capabilities,
  })

  -- Lua (formatting by Stylua via conform)
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim", "describe", "it", "before_each", "after_each" },
        },
      },
    },
  })

  -- JSON (formatting by Prettier via conform)
  lspconfig.jsonls.setup({
    capabilities = capabilities,
  })

  -- CSS
  lspconfig.cssls.setup({
    capabilities = capabilities,
  })

  -- HTML
  lspconfig.html.setup({
    capabilities = capabilities,
  })

  -- JavaScript / TypeScript (formatting by Prettier via conform)
  lspconfig.ts_ls.setup({
    capabilities = capabilities,
  })

  -- Emmet
  lspconfig.emmet_ls.setup({
    capabilities = capabilities,
    -- add eruby as filetype
  })

  -- Vue (formatting by Prettier via conform)
  lspconfig.volar.setup({
    capabilities = capabilities,
  })

  -- Markdown
  lspconfig.marksman.setup({
    capabilities = capabilities,
  })

  -- Tailwind CSS
  lspconfig.tailwindcss.setup({
    capabilities = capabilities,
  })

  -- Bash
  lspconfig.bashls.setup({
    capabilities = capabilities,
    filetypes = { "sh", "zsh" },
  })

  -- Ansible
  lspconfig.ansiblels.setup({
    capabilities = capabilities,
  })

  -- YAML
  lspconfig.yamlls.setup({
    capabilities = capabilities,
  })

  -- Elixir
  lspconfig.elixirls.setup({
    capabilities = capabilities,
  })

  -- Docker
  lspconfig.docker_compose_language_service.setup({
    capabilities = capabilities,
  })

  lspconfig.dockerls.setup({
    capabilities = capabilities,
  })

  -- Python
  lspconfig.pylsp.setup({
    capabilities = capabilities,
  })

  -- PHP
  lspconfig.intelephense.setup({
    capabilities = capabilities,
  })

  -- TOML
  lspconfig.taplo.setup({
    capabilities = capabilities,
  })

  -- Rust
  lspconfig.rust_analyzer.setup({
    capabilities = capabilities,
  })

  local cmp = require("cmp")
  cmp.setup({
    sources = {
      { name = "nvim_lsp" },
      { name = "vim-dadbod-completion", priority = 700 }
    },
    mapping = cmp.mapping.preset.insert({
      -- Enter key confirms completion item
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      -- Ctrl + space triggers completion menu
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
