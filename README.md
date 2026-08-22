# dot-nvim

My personal Neovim config. I came from Emacs (Doom/Spacemacs muscle memory) and
tmux, so a lot of this is deliberately shaped to feel like those instead of
"vanilla" Neovim defaults. If a keybinding looks like an odd choice, it's
probably mirroring an Emacs command I refused to unlearn. The file that
defines it usually says so in a comment.

Leader is `<space>`. Plugin manager is [lazy.nvim](https://github.com/folke/lazy.nvim).

## Layout

```
init.lua       -- just requires the stuff below, in order
lua/config/    -- non-plugin config: options, keymaps, autocmds, lazy.nvim bootstrap
lua/plugins/   -- one file per plugin (or tight group of plugins), each returns a lazy.nvim spec
```

No framework, no auto-discovery magic. Want to know what a plugin does or how
it's configured? Open its file in `lua/plugins/`. That's the source of truth,
not this file.

## Finding keybindings

Don't look here for a keymap list, it'll go stale before you finish reading it
(check the git log for how many times the resize keys alone got reshuffled in
one afternoon). Press `<leader>` and wait: which-key.nvim shows the live set,
grouped by find/project/git/test/debug/lsp/etc. `lua/config/keymaps.lua` has
the ungrouped, global ones.

## External dependencies

Beyond what Mason installs automatically for LSP servers:

- `rg` (ripgrep), for Telescope live grep
- `watchman`, optional: used for LSP file watching when present, falls back
  cleanly if it's missing
- `deno`, builds peek.nvim's markdown preview on first install
- a Nerd Font in your terminal, or icons render as boxes

Requires a reasonably recent Neovim (this tracks current stable, not LTS). If
something LSP-related looks broken after an update, `lua/plugins/lsp.lua` is
usually the first place to check, it tends to be first in line for a newer API.

## Installing

```sh
git clone <this repo> ~/.config/nvim
nvim
```

lazy.nvim bootstraps itself and installs everything on first launch. Mason
takes it from there for the LSP servers.
