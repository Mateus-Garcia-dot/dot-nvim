-- toppair/peek.nvim replaced: no commits in ~2 years, a hard Deno build
-- dependency, and other people forking it just to keep the build working.
-- markview renders markdown in the buffer directly (extmarks/conceal, no
-- external process or browser window) instead of shelling out to Firefox.
--
-- PeekOpen/PeekClose kept as thin aliases onto markview's own :Markview
-- command so muscle memory (and anything that still runs those commands)
-- survives the swap.
return {
  "OXY2DEV/markview.nvim",
  lazy = false, -- README: "Do not lazy load this plugin as it is already lazy-loaded"
  config = function()
    vim.api.nvim_create_user_command("PeekOpen", function() vim.cmd.Markview("enable") end, {})
    vim.api.nvim_create_user_command("PeekClose", function() vim.cmd.Markview("disable") end, {})
  end,
}
