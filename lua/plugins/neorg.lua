return {
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    dependencies = {
      "folke/zen-mode.nvim",
      -- core.completion only knows nvim-cmp / coq_nvim / nvim-compe natively,
      -- none of which are installed since the move to blink. interim-ls is
      -- the escape hatch neorg documents for that case: it exposes the same
      -- completions through an in-process shim LSP, so blink's plain "lsp"
      -- source picks them up with no neorg-specific glue.
      "benlubas/neorg-interim-ls",
    },
    -- core.integrations.treesitter probes package.cpath for the norg/norg_meta
    -- parsers, then falls back to `parser/<lang>.so` on the runtimepath. Both
    -- ship solely as luarocks rocks (tree-sitter-norg / tree-sitter-norg-meta;
    -- nvim-treesitter's main branch doesn't offer norg at all), whose cpath
    -- entries aren't in place yet when neorg loads. Hence "norg_meta parser was
    -- not found" on every start, with metadata (@document.meta) parsing
    -- silently dead. Registering them by explicit path here runs before
    -- require("neorg").setup() and sidesteps the ordering entirely. The rock
    -- tree is globbed rather than read off package.cpath because cpath is
    -- what's late in the first place.
    init = function()
      local rocks = vim.fn.stdpath("data") .. "/lazy-rocks"
      for _, lang in ipairs({ "norg", "norg_meta" }) do
        if not vim.treesitter.language.add(lang) then
          local found = vim.fn.glob(rocks .. "/*/lib/lua/*/parser/" .. lang .. ".so", true, true)
          if found[1] then
            vim.treesitter.language.add(lang, { path = found[1] })
          end
        end
      end
    end,
    config = {
      load = {
        ["core.defaults"] = {},
        ["core.export"] = {},
        ["core.export.markdown"] = {},
        -- init above has already registered both parsers by absolute path, but
        -- this module's own probe only ever looks at package.cpath and
        -- `parser/*.so` on the runtimepath -- it can't see an in-memory
        -- registration, so it would keep warning about a parser that is in
        -- fact loaded and working. configure_parsers stays on: the cpath
        -- lookup is harmless, and it's the thing that keeps working if the
        -- rock layout changes.
        ["core.integrations.treesitter"] = {
          config = {
            warn_missing_parsers = false,
          },
        },
        ["core.completion"] = {
          config = {
            engine = { module_name = "external.lsp-completion" },
          },
        },
        ["external.interim-ls"] = {
          config = {
            completion_provider = {
              enable = true,
              documentation = true,
              -- categories are a metadata field this config never fills in,
              -- so they'd only pad the menu with empty suggestions.
              categories = false,
            },
          },
        },
        ["core.concealer"] = {
          config = {
            icon_preset = "diamond",
          },
        },
        ["core.presenter"] = {
          config = {
            zen_mode = "zen-mode",
          },
        },
      }
    },
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
  },
}
