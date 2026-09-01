-- Tints code-block backgrounds in markdown buffers (tokyonight already ships
-- colors for it: CodeBlock = { bg = c.bg_dark }) and renders headings and
-- other markdown constructs in place. Also covers the LSP hover float:
-- render-markdown attaches synchronously on FileType, and that scratch
-- buffer's filetype is "markdown" -- headlines.nvim needed a manual-refresh
-- hack for this (config/hover-codeblock.lua, now removed); this one doesn't.
--
-- norg/org dropped from the filetype list (headlines.nvim covered both):
-- rendering here is driven by markdown treesitter queries, so it can't
-- render neorg's or org's own syntax -- neorg has its own concealer for
-- headings anyway.
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ft = { "markdown", "rmd" },
  opts = {},
}
