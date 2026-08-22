-- Toggle between a class and its test file (my/php-toggle-test equivalent).
local function class_name()
  local lnum = vim.fn.line(".")
  while lnum > 0 do
    local line = vim.fn.getline(lnum)
    local name = line:match("^%s*class%s+([%w_]+)") or line:match("^%s*final%s+class%s+([%w_]+)")
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
  local root = require("config.project").root()

  require("telescope.builtin").find_files({
    cwd = root,
    default_text = search_term,
    prompt_title = "Find " .. search_term,
  })
end

vim.keymap.set("n", "<leader>pt", toggle_test, { buffer = true, desc = "Toggle class/test" })
