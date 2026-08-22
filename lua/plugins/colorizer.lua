-- Inline color swatches for hex/rgb/hsl values (not Tailwind-specific).
-- catgoose's fork is the actively maintained successor to the original
-- norcalli/nvim-colorizer.lua, which has been stale since mid-2024.
return {
  "catgoose/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("colorizer").setup()
  end,
}
