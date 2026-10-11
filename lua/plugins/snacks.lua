-- Replaces nvim-telescope/telescope.nvim + telescope-fzf-native.nvim:
-- telescope has had slow maintenance stretches historically, and
-- snacks.picker ships its own fast native-Lua fzf-syntax matcher (no
-- separate build step/native dependency needed) -- while also being the
-- plugin already pulled in for config/project.lua's root detection.
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

  -- GitHub, via snacks' own `gh` CLI integration (forge/magit-forge
  -- equivalent, no extra plugin): pickers are live, so typing in gh_pr
  -- searches GitHub itself rather than filtering a fetched page -- which is
  -- what makes it usable on a repo with six figures' worth of pull requests.
  vim.keymap.set({ "n", "v" }, "<leader>gP", function() picker.gh_pr() end, { desc = "Pull requests" })
  vim.keymap.set({ "n", "v" }, "<leader>gm", function()
    picker.gh_pr({ author = "@me" })
  end, { desc = "My pull requests" })
  vim.keymap.set({ "n", "v" }, "<leader>gR", function()
    picker.gh_pr({ search = "review-requested:@me draft:false" })
  end, { desc = "Review queue" })
  vim.keymap.set({ "n", "v" }, "<leader>gi", function() picker.gh_issue() end, { desc = "Issues" })

  -- Title (Monday ID + description) and body (EBANX Code Review template)
  -- built from the current branch by ebanx/pay's create-pr script; previews
  -- before actually opening the PR.
  vim.keymap.set({ "n", "v" }, "<leader>gc", function()
    require("config.github").create_pr()
  end, { desc = "Create PR" })

  -- Actions (open in buffer, diff, review, comment, checkout) for the pull
  -- request of the current branch -- no argument needed, it resolves via
  -- `gh pr view`.
  vim.keymap.set({ "n", "v" }, "<leader>gd", function() picker.gh_actions() end, { desc = "Current PR" })

  -- ...and for the pull request that introduced the line under the cursor:
  -- git blame gives the commit, GitHub resolves the commit to its PR. The
  -- review thread there is usually where the reasoning lives.
  vim.keymap.set({ "n", "v" }, "<leader>gw", function()
    require("config.github").pr_for_line()
  end, { desc = "Why is this line here?" })

  -- Waits on the current branch's checks in the background (a `gh` process,
  -- not a terminal tab) and reports through fidget plus terminal-notifier
  -- when they settle.
  vim.keymap.set({ "n", "v" }, "<leader>gW", function()
    require("config.github").watch_checks()
  end, { desc = "Watch PR checks" })

  -- History, at two scopes
  vim.keymap.set({ "n", "v" }, "<leader>gl", function() picker.git_log_file() end, { desc = "File history" })
  vim.keymap.set({ "n", "v" }, "<leader>gL", function() picker.git_log_line() end, { desc = "Line history" })

  -- Permalink to the cursor position (or, in visual mode, the selection).
  -- gy yanks it (the `gh browse -n | pbcopy` equivalent, for pasting into
  -- Slack or a review comment); go opens it. Both pin the commit rather than
  -- the branch, so the link keeps pointing at these lines.
  vim.keymap.set({ "n", "v" }, "<leader>gy", function()
    require("snacks").gitbrowse({
      what = "permalink",
      open = function(url)
        vim.fn.setreg("+", url)
        vim.notify(url)
      end,
    })
  end, { desc = "Yank permalink" })
  vim.keymap.set({ "n", "v" }, "<leader>go", function()
    require("snacks").gitbrowse({ what = "permalink" })
  end, { desc = "Open permalink in browser" })

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
    -- vim.ui.input as a float (LSP rename on <F2>, ...) instead of the
    -- cmdline, which cmdheight=0 would otherwise have to pop open for it
    input = { enabled = true },
    -- cmdheight=0 (options.lua) hides the message area, so a plain
    -- vim.notify (e.g. "client quit with exit code 1") would otherwise
    -- vanish unseen. snacks overrides vim.notify once enabled.
    notifier = { enabled = true },
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
