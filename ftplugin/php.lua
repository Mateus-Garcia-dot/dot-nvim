-- Toggle between a class and its test file (my/php-toggle-test equivalent).

-- Modifiers PHP allows in front of the declaration keyword, in any order:
-- `abstract class`, `readonly class`, `final readonly class`, ...
local MODIFIERS = { abstract = true, final = true, readonly = true }
local DECLARATIONS = { class = true, interface = true, trait = true, enum = true }

-- Word-based rather than a `^%s*class%s+` pattern: the old one only knew
-- `class` and `final class`, so `abstract class Foo` -- and every PHP 8.2
-- `readonly class` -- fell through and reported "No enclosing class found".
local function declared_name(line)
  local words = {}
  for word in line:gmatch("[%w_]+") do
    words[#words + 1] = word
  end

  local i = 1
  while words[i] and MODIFIERS[words[i]:lower()] do
    i = i + 1
  end

  -- requires the keyword to lead the line (after modifiers), which is what
  -- keeps prose like "-- this class Foo does..." from matching
  if words[i] and DECLARATIONS[words[i]:lower()] then
    return words[i + 1]
  end
end

local function class_name()
  -- Treesitter first: it resolves the *enclosing* declaration correctly even
  -- with nested or anonymous classes, and ignores matches inside comments and
  -- strings. Falls back to the line scan when no php parser is attached.
  local ok, node = pcall(function()
    local parser = vim.treesitter.get_parser(0)
    if not parser then return nil end
    -- get_node() reads the last parsed tree, which is empty until something
    -- (highlighting, usually) has run the parser -- so parse first
    parser:parse(true)
    return vim.treesitter.get_node()
  end)
  if ok and node then
    while node do
      if DECLARATIONS[node:type():gsub("_declaration$", "")] then
        local name_node = node:field("name")[1]
        if name_node then
          return vim.treesitter.get_node_text(name_node, 0)
        end
      end
      node = node:parent()
    end
  end

  local lnum = vim.fn.line(".")
  while lnum > 0 do
    local name = declared_name(vim.fn.getline(lnum))
    if name then return name end
    lnum = lnum - 1
  end
end

local function toggle_test()
  local name = class_name()
  if not name then
    vim.notify("No enclosing class found", vim.log.levels.WARN)
    return
  end

  local search_term = name:match("Test$") and name:gsub("Test$", "") or (name .. "Test")

  -- php resolves the name from the enclosing *class* rather than the
  -- filename (a file can hold more than one), then hands off to the shared
  -- locate-and-jump used by every other filetype.
  require("config.test-toggle").jump({ search_term .. ".php" }, search_term)
end

-- <leader>tc is the primary key (it belongs with the other test bindings);
-- <leader>pt stays as an alias, since it's what Doom binds this to.
-- Both are buffer-local, so they only exist in php buffers -- neotest's
-- "Test file" moved off tc to tf to make room.
for _, lhs in ipairs({ "<leader>tc", "<leader>pt" }) do
  vim.keymap.set({ "n", "v" }, lhs, toggle_test, { buffer = true, desc = "Toggle class/test" })
end
