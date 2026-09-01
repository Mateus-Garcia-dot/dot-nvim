-- Replaces nvim-cmp (in maintenance mode) along with its cmp-nvim-lsp /
-- cmp_luasnip / lspkind satellites: blink covers LSP capabilities, snippet
-- expansion (via core nvim's vim.snippet, no LuaSnip needed) and kind icons
-- itself.
--
-- Pinned to 1.* on purpose -- v2 is still under active development, and the
-- 1.x tags ship a prebuilt Rust fuzzy matcher, so installing doesn't need a
-- cargo build even though cargo happens to be on this machine.
return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      -- blink's own "default" snippets source loads this directly off the
      -- runtimepath -- no LuaSnip or loader call needed.
      "rafamadriz/friendly-snippets",
    },
    opts = {
      -- 'none' rather than a preset: these are the nvim-cmp bindings this
      -- config already had, kept key-for-key so the muscle memory survives.
      keymap = {
        preset = "none",
        ["<CR>"] = { "accept", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        -- select_* first so an open menu behaves exactly like before;
        -- snippet jumping only kicks in once the menu is closed, which is
        -- new -- LuaSnip + friendly-snippets were installed but had no jump
        -- key at all, leaving you stranded after expanding one.
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },

      snippets = { preset = "default" },

      -- README says a Nerd Font is required; 'mono' is the variant whose
      -- icons are single-width, which is what keeps the menu aligned.
      appearance = { nerd_font_variant = "mono" },

      completion = {
        -- preselect + no auto_insert reproduces nvim-cmp's
        -- confirm({ select = true }): <CR> takes the top item without
        -- arrowing to it, and nothing lands in the buffer until you accept.
        list = { selection = { preselect = true, auto_insert = false } },
        menu = { border = "rounded" },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
      },

      sources = {
        -- path and buffer are new here (nvim-cmp was running lsp + luasnip +
        -- dadbod only); they're blink's defaults and rank below LSP. Drop
        -- them from this list if the extra noise isn't worth it.
        default = { "lsp", "snippets", "path", "buffer" },
        per_filetype = {
          sql = { "dadbod", "buffer" },
          mysql = { "dadbod", "buffer" },
          plsql = { "dadbod", "buffer" },
        },
        providers = {
          -- vim-dadbod-completion ships its own blink source module; the
          -- score_offset carries over the priority = 700 it had under cmp.
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
            score_offset = 700,
          },
        },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
