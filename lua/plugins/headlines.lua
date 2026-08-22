-- Tints code-block (and heading) backgrounds in markdown-like buffers.
-- tokyonight already ships colors for this (CodeBlock = { bg = c.bg_dark }).
-- Applies to the LSP hover float too, since it's just a scratch buffer
-- with filetype=markdown.
return {
  "lukas-reineke/headlines.nvim",
  dependencies = "nvim-treesitter/nvim-treesitter",
  ft = { "markdown", "norg", "org", "rmd" },
  opts = {
    markdown = { fat_headlines = false },
    norg = { fat_headlines = false },
  },
}
