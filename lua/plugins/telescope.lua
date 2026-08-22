local project_root = require("config.project").root

local config = function()
  require("telescope").setup({
    defaults = {
      -- non-boolean value skips telescope's override that drops the
      -- results/preview windows' bottom border
      border = { 1, 1, 1, 1 },
    },
  })
  local builtin = require("telescope.builtin")

  vim.keymap.set({ "n", "v" }, "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
  vim.keymap.set({ "n", "v" }, "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
  vim.keymap.set({ "n", "v" }, "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
  vim.keymap.set({ "n", "v" }, "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

  -- top-level "/" like emacs' unprefixed project ripgrep search
  vim.keymap.set({ "n", "v" }, "<leader>/", function()
    builtin.live_grep({ cwd = project_root() })
  end, { desc = "Search project" })

  -- M-x equivalent
  vim.keymap.set({ "n", "v" }, "<leader><leader>", builtin.commands, { desc = "Commands" })

  -- projectile-switch-project equivalent, backed by project.nvim's history
  vim.keymap.set({ "n", "v" }, "<leader>pp", "<cmd>Telescope projects<cr>", { desc = "Switch project" })

  vim.keymap.set({ "n", "v" }, "<leader>pf", function()
    builtin.find_files({ cwd = project_root() })
  end, { desc = "Find file in project" })

  vim.keymap.set({ "n", "v" }, "<leader>pb", function()
    builtin.buffers({ cwd = project_root(), cwd_only = true })
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
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    config = config,
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
