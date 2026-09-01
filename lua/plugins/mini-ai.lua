-- The `a`/`i` half of treesitter textobjects: vaf/vif (function), vac/vic
-- (class), vao/vio (block, conditional or loop), on top of mini.ai's own
-- builtins (quotes, brackets, tags, arguments, ...).
--
-- nvim-treesitter-textobjects has a `select` submodule that covers the same
-- ground, and it is deliberately left disabled in plugins/treesitter.lua.
-- mini.ai is the better half of that pair:
--   - it takes counts (v2af -- "around the 2nd function ahead")
--   - it has next/last variants (vin( -- "inside the next parens")
--   - selections are dot-repeatable
-- select offers none of the three. The `move`/`swap` submodules have no
-- mini.ai equivalent, so those stay on treesitter-textobjects -- the two
-- plugins split the job rather than overlap.
--
-- Not a soft dependency: gen_spec.treesitter resolves "@function.inner" &c.
-- through the textobjects queries, which ship with that plugin. Without it
-- on the runtimepath, f/c/o silently match nothing.
--
-- Note the org: mini.* moved from echasnovski to nvim-mini, matching how
-- mini.icons is already pulled in by plugins/oil.lua.
return {
  "nvim-mini/mini.ai",
  event = "VeryLazy",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  opts = function()
    local ai = require("mini.ai")
    return {
      -- how far to scan for a match; the default (50) misses the top of a
      -- long PHP class from somewhere near the bottom of it
      n_lines = 500,
      custom_textobjects = {
        f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
        -- one key for "the nearest enclosing block", whichever of the three
        -- it happens to be -- cio works in an if, a for and a bare { } alike
        o = ai.gen_spec.treesitter({
          a = { "@block.outer", "@conditional.outer", "@loop.outer" },
          i = { "@block.inner", "@conditional.inner", "@loop.inner" },
        }),
      },
    }
  end,
}
