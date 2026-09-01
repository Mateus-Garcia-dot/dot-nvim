-- Neovim 0.10+ has `gc`/`gcc` commenting built in, so this is not a
-- Comment.nvim replacement -- it only fixes which marker `gc` inserts.
--
-- The builtin reads a single buffer-wide `commentstring`, which is wrong the
-- moment one file holds more than one language: `//` gets inserted into a
-- Vue <template> (needs `<!-- -->`), JSX children need `{/* */}` while the
-- surrounding TS needs `//`, and a <style> block needs `/* */`. All three
-- live in the same buffer here, given the volar/ts_ls/tailwind setup in
-- plugins/lsp.lua.
--
-- ts-comments swaps `commentstring` based on the treesitter node under the
-- cursor, so the marker is picked per region rather than per file. It only
-- touches filetypes it has a rule for, so hand-set values elsewhere (see
-- ftplugin/sql.lua) are left alone.
return {
  "folke/ts-comments.nvim",
  event = "VeryLazy",
  opts = {},
}
