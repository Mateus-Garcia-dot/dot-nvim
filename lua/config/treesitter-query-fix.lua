-- Neovim 0.12's core treesitter query engine can hand directive handlers a
-- capture wrapped in a table `{node}` instead of a bare TSNode, even with
-- nvim-treesitter's own `all = false` compat shim (query_predicates.lua) in
-- place. Any directive that calls node methods directly then crashes --
-- notably markdown's fenced-code-block language detection ("attempt to call
-- method 'range' (a nil value)" from vim.treesitter.get_range, hit on every
-- ```lang code fence). Re-register the affected directives with the same
-- logic, but unwrapped.
local M = {}

local function as_node(n)
  if type(n) == "table" then
    return n[1]
  end
  return n
end

function M.apply()
  require("nvim-treesitter.query_predicates")
  local query = vim.treesitter.query

  local html_script_type_languages = {
    ["importmap"] = "json",
    ["module"] = "javascript",
    ["application/ecmascript"] = "javascript",
    ["text/ecmascript"] = "javascript",
  }
  local non_filetype_match_injection_language_aliases = {
    ex = "elixir",
    pl = "perl",
    sh = "bash",
    uxn = "uxntal",
    ts = "typescript",
  }
  local function lang_from_info_string(alias)
    local match = vim.filetype.match({ filename = "a." .. alias })
    return match or non_filetype_match_injection_language_aliases[alias] or alias
  end

  query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
    local node = as_node(match[pred[2]])
    if not node then
      return
    end
    local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
    local parts = vim.split(type_attr_value, "/", {})
    metadata["injection.language"] = html_script_type_languages[type_attr_value] or parts[#parts]
  end, { force = true })

  query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
    local node = as_node(match[pred[2]])
    if not node then
      return
    end
    local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
    metadata["injection.language"] = lang_from_info_string(injection_alias)
  end, { force = true })

  query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
    local id = pred[2]
    local node = as_node(match[id])
    if not node then
      return
    end
    local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
    metadata[id] = metadata[id] or {}
    metadata[id].text = string.lower(text)
  end, { force = true })
end

return M
