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
  local telescope_builtin = require("telescope.builtin")

  -- Watchman scales to large repos better than libuv's recursive fs_event;
  -- falls back to nvim's default (capability disabled) if not installed.
  local watchman_available = vim.fn.executable("watchman-wait") == 1
  if watchman_available then
    local watchfiles = require("vim.lsp._watchfiles")
    local watch = require("vim._watch")
    local uv = vim.uv

    watchfiles._watchfunc = function(path, opts, callback)
      opts = opts or {}
      path = vim.fs.normalize(path)

      local function skip(fullpath)
        if opts.include_pattern and opts.include_pattern:match(fullpath) == nil then
          return true
        end
        if opts.exclude_pattern and opts.exclude_pattern:match(fullpath) ~= nil then
          return true
        end
        return false
      end

      local buf = ""
      local obj = vim.system({ "watchman-wait", "--relative", path, "--max-events", "0", path }, {
        stdout = function(err, data)
          if err or not data then
            return
          end
          buf = buf .. data
          local lines = vim.split(buf, "\n", { plain = true })
          buf = table.remove(lines) or ""
          for _, line in ipairs(lines) do
            if line ~= "" then
              local fullpath = vim.fs.normalize(vim.fs.joinpath(path, line))
              if not skip(fullpath) then
                uv.fs_stat(fullpath, function(_, stat)
                  local change_type = stat and watch.FileChangeType.Changed or watch.FileChangeType.Deleted
                  callback(fullpath, change_type)
                end)
              end
            end
          end
        end,
        stderr = function(err, data)
          if not err and data and #vim.trim(data) > 0 then
            vim.schedule(function()
              vim.notify("watchman-wait: " .. data, vim.log.levels.ERROR)
            end)
          end
        end,
      })

      return function()
        obj:kill(2)
      end
    end
  end

  capabilities.workspace = capabilities.workspace or {}
  capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = watchman_available }

  local mason = require("mason")
  local mason_lspconfig = require("mason-lspconfig")

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

      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "gd", telescope_builtin.lsp_definitions, opts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gi", telescope_builtin.lsp_implementations, opts)
      vim.keymap.set("n", "go", telescope_builtin.lsp_type_definitions, opts)
      vim.keymap.set("n", "gr", telescope_builtin.lsp_references, opts)
      vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)
      vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
      vim.keymap.set({ "n", "x" }, "<F3>", function() vim.lsp.buf.format({ async = true }) end, opts)
      vim.keymap.set("n", "<F4>", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

      -- <leader>l mirror of the keys above, for eglot-style muscle memory
      vim.keymap.set({ "n", "v" }, "<leader>lr", vim.lsp.buf.rename, opts)
      vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)
      vim.keymap.set({ "n", "v" }, "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, opts)
      vim.keymap.set({ "n", "v" }, "<leader>ld", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", opts)
      vim.keymap.set({ "n", "v" }, "<leader>le", vim.diagnostic.open_float, opts)
      vim.keymap.set({ "n", "v" }, "<leader>lh", vim.lsp.buf.hover, opts)
      vim.keymap.set({ "n", "v" }, "<leader>lgd", telescope_builtin.lsp_definitions, opts)
      vim.keymap.set({ "n", "v" }, "<leader>lgD", vim.lsp.buf.declaration, opts)
      vim.keymap.set({ "n", "v" }, "<leader>lgi", telescope_builtin.lsp_implementations, opts)
      vim.keymap.set({ "n", "v" }, "<leader>lgy", telescope_builtin.lsp_type_definitions, opts)
      vim.keymap.set({ "n", "v" }, "<leader>lgr", telescope_builtin.lsp_references, opts)
    end,
  })

  mason.setup(mason_opts)
  mason_lspconfig.setup({ ensure_installed = ensure_installed })

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
  vim.lsp.config('phpactor', { capabilities = capabilities })
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

  -- mason-lspconfig's `automatic_enable` (on by default) already calls
  -- vim.lsp.enable() for anything actually installed via Mason (currently
  -- bashls, cssls, docker_compose_language_service, dockerls, emmet_ls,
  -- html, jsonls, lua_ls, tailwindcss, ts_ls, pylsp). Only enable the
  -- servers here that are NOT Mason-managed on this machine.
  vim.lsp.enable({
    'standardrb',
    'volar',
    'marksman',
    'ansiblels',
    'yamlls',
    'elixirls',
    'phpactor',
    'taplo',
    'rust_analyzer',
  })

  require("luasnip.loaders.from_vscode").lazy_load()

  local cmp = require("cmp")
  local lspkind = require("lspkind")
  cmp.setup({
    sources = {
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "vim-dadbod-completion", priority = 700 },
    },
    formatting = {
      format = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 }),
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
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
      "nvim-telescope/telescope.nvim",
    },
    lazy = false,
    config = config,
  },
}
