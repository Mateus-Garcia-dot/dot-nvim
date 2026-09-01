-- Replaces nvim-telescope/telescope.nvim + telescope-fzf-native.nvim:
-- telescope has had slow maintenance stretches historically, and
-- snacks.picker ships its own fast native-Lua fzf-syntax matcher (no
-- separate build step/native dependency needed) -- while also being the
-- plugin already pulled in for claudecode.nvim's notifications and
-- config/project.lua's root detection.
local project_root = require("config.project").root

local config = function(_, opts)
  require("snacks").setup(opts)

  local picker = require("snacks").picker

  vim.keymap.set({ "n", "v" }, "<leader>ff", function() picker.files() end, { desc = "Find files" })
  vim.keymap.set({ "n", "v" }, "<leader>fg", function() picker.grep() end, { desc = "Live grep" })
  vim.keymap.set({ "n", "v" }, "<leader>fb", function() picker.buffers() end, { desc = "Buffers" })
  vim.keymap.set({ "n", "v" }, "<leader>fh", function() picker.help() end, { desc = "Help tags" })

  -- top-level "/" like emacs' unprefixed project ripgrep search
  vim.keymap.set({ "n", "v" }, "<leader>/", function()
    picker.grep({ cwd = project_root() })
  end, { desc = "Search project" })

  -- M-x equivalent
  vim.keymap.set({ "n", "v" }, "<leader><leader>", function() picker.commands() end, { desc = "Commands" })

  -- projectile-switch-project equivalent, backed by snacks' recent-projects
  -- finder (oldfiles resolved to their git root, plus its configured dev dirs)
  vim.keymap.set({ "n", "v" }, "<leader>pp", function() picker.projects() end, { desc = "Switch project" })

  vim.keymap.set({ "n", "v" }, "<leader>pf", function()
    picker.files({ cwd = project_root() })
  end, { desc = "Find file in project" })

  vim.keymap.set({ "n", "v" }, "<leader>pb", function()
    picker.buffers({ filter = { cwd = project_root() } })
  end, { desc = "Switch buffer in project" })

  vim.keymap.set({ "n", "v" }, "<leader>pk", function()
    local root = project_root()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and vim.startswith(name, root) then
        vim.api.nvim_buf_delete(buf, {})
      end
    end
  end, { desc = "Kill project buffers" })
end

return {
  "folke/snacks.nvim",
  lazy = false,
  ---@type snacks.Config
  opts = {
    picker = {
      enabled = true,
      sources = {
        files = {
          hidden = true, -- fd --hidden (.git is already excluded by default)
          args = { "--strip-cwd-prefix" }, -- drops the leading "./"; no dedicated field for this flag
        },
        grep = {
          -- one minified .js or base64 blob in a fixture would otherwise
          -- stream a multi-megabyte single line through the matcher
          args = { "--max-columns=200" },
        },
      },
      previewers = {
        -- there's no preview-timeout equivalent to telescope's here, only a
        -- size cap
        file = { max_size = 1024 * 1024 }, -- 1MB
      },
    },
  },
  config = config,
}
