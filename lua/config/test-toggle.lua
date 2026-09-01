-- Jump between a source file and its test (projectile-toggle-between-
-- implementation-and-test equivalent). Bound to <leader>tc, with <leader>pt
-- as an alias.
--
-- Deliberately filename-based rather than path-based: it never needs to know
-- that tests live in tests/Unit or spec/ or wherever, only what the test file
-- is *called*. php overrides this in ftplugin/php.lua, where the name comes
-- from the enclosing class instead of the filename.
local M = {}

-- suffix/prefix go on the stem, before the extension, so ".spec" turns
-- foo.ts into foo.spec.ts. test_ext/source_ext are only needed where the
-- extension itself differs between the two (elixir's .ex -> .exs).
local RULES = {
  php = { { suffix = "Test" } },
  python = { { prefix = "test_" }, { suffix = "_test" } },
  ruby = { { suffix = "_spec" }, { suffix = "_test" } },
  lua = { { suffix = "_spec" } },
  go = { { suffix = "_test" } },
  elixir = { { suffix = "_test", test_ext = "exs", source_ext = "ex" } },
  javascript = { { suffix = ".test" }, { suffix = ".spec" } },
  typescript = { { suffix = ".test" }, { suffix = ".spec" } },
  javascriptreact = { { suffix = ".test" }, { suffix = ".spec" } },
  typescriptreact = { { suffix = ".test" }, { suffix = ".spec" } },
  vue = { { suffix = ".spec" }, { suffix = ".test" } },
}

-- Every candidate basename worth looking for, given the current buffer.
-- Returns test names for a source file, and source names for a test file.
function M.candidates()
  local rules = RULES[vim.bo.filetype]
  if not rules then return {} end

  local path = vim.fn.expand("%:p")
  if path == "" then return {} end
  local stem = vim.fn.fnamemodify(path, ":t:r")
  local ext = vim.fn.fnamemodify(path, ":e")

  local names = {}
  for _, rule in ipairs(rules) do
    local test_ext = rule.test_ext or ext
    local source_ext = rule.source_ext or ext

    local source_stem
    if rule.suffix and ext == test_ext and vim.endswith(stem, rule.suffix) then
      source_stem = stem:sub(1, #stem - #rule.suffix)
    elseif rule.prefix and ext == test_ext and vim.startswith(stem, rule.prefix) then
      source_stem = stem:sub(#rule.prefix + 1)
    end

    if source_stem and source_stem ~= "" then
      names[#names + 1] = source_stem .. "." .. source_ext -- test -> source
    else
      names[#names + 1] = (rule.prefix or "") .. stem .. (rule.suffix or "") .. "." .. test_ext
    end
  end
  return names
end

-- Look the candidates up on disk in one fd call (basename match, anchored),
-- rather than guessing directory layout.
local function find(names, root)
  local escaped = {}
  for _, name in ipairs(names) do
    escaped[#escaped + 1] = name:gsub("[%.%-%+%*%?%[%]%^%$%(%)%{%}|\\]", "\\%0")
  end
  local pattern = "^(" .. table.concat(escaped, "|") .. ")$"

  local ok, res = pcall(function()
    return vim
      -- fd matches against the basename unless --full-path is passed, which
      -- is exactly what's wanted: find FooTest.php wherever it lives.
      .system({ "fd", "--type", "f", "--hidden", "--exclude", ".git", pattern }, {
        cwd = root,
        text = true,
      })
      :wait(2000)
  end)
  if not ok or not res or res.code ~= 0 then return {} end

  local hits = {}
  for line in (res.stdout or ""):gmatch("[^\n]+") do
    hits[#hits + 1] = vim.fs.joinpath(root, line)
  end
  return hits
end

-- Jump to the single match, or hand the ambiguous case to the picker with the
-- name prefilled -- which is also what happens when nothing matches at all,
-- so a missing test still lands you somewhere useful.
function M.jump(names, fallback_text)
  if #names == 0 then
    vim.notify("No test-file convention for filetype '" .. vim.bo.filetype .. "'", vim.log.levels.WARN)
    return
  end

  local root = require("config.project").root()
  local hits = find(names, root)

  if #hits == 1 then
    vim.cmd.edit(vim.fn.fnameescape(hits[1]))
    return
  end

  require("snacks").picker.files({
    cwd = root,
    pattern = fallback_text or vim.fn.fnamemodify(names[1], ":r"),
    title = #hits == 0 and ("No " .. names[1] .. " -- search") or ("Find " .. names[1]),
  })
end

function M.toggle()
  M.jump(M.candidates())
end

return M
