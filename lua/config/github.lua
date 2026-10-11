-- "Why is this line here?" -- resolves the current line to the pull request
-- that introduced it, then opens that PR in a Snacks.gh buffer (description,
-- review comments, checks).
--
-- git blame gives the commit; GitHub's commits/{sha}/pulls endpoint gives the
-- PR without having to guess from the merge commit's message. Worth having in
-- a repo where the PR body and its review thread hold the reasoning that the
-- commit message does not -- and where the title carries the monday card id.
local M = {}

local function root()
  return require("config.project").root()
end

-- Resolves FILE:LINE to a PR number, async. Calls cb(number|nil, err|nil).
function M.resolve(file, line, cb)
  local function fail(msg)
    vim.schedule(function() cb(nil, msg) end)
  end

  -- both resolved up front: the second vim.system call is made from the
  -- first one's exit handler, which runs in a fast event context where
  -- neither vim.fn nor snacks' root detection may be called
  local file_dir = vim.fn.fnamemodify(file, ":h")
  local repo_root = root()

  vim.system(
    { "git", "blame", "-L", line .. "," .. line, "--porcelain", "--", file },
    { cwd = file_dir, text = true },
    function(blame)
      if blame.code ~= 0 then
        return fail("git blame failed: " .. (blame.stderr or ""):gsub("%s+$", ""))
      end

      local sha = (blame.stdout or ""):match("^(%x+)")
      if not sha then
        return fail("Could not read a commit for this line")
      end
      -- all-zero sha is blame's marker for a not-yet-committed line
      if sha:match("^0+$") then
        return fail("Line is not committed yet")
      end

      vim.system(
        { "gh", "api", "repos/{owner}/{repo}/commits/" .. sha .. "/pulls", "--jq", ".[0].number // empty" },
        { cwd = repo_root, text = true },
        function(gh)
          if gh.code ~= 0 then
            return fail("gh api failed: " .. (gh.stderr or ""):gsub("%s+$", ""))
          end

          local number = tonumber((gh.stdout or ""):match("%d+"))
          if not number then
            -- pushed straight to the default branch, or the PR predates the
            -- commit being reachable from it
            return fail("No pull request found for commit " .. sha:sub(1, 8))
          end

          vim.schedule(function() cb(number) end)
        end
      )
    end
  )
end

-- owner/repo from the origin remote (no network; Snacks' gh actions want it
-- explicitly rather than inferring it).
local function repo_slug()
  local out = vim.system({ "git", "remote", "get-url", "origin" }, { cwd = root(), text = true }):wait()
  if out.code ~= 0 then
    return nil
  end
  -- git@github.com:ebanx/pay.git  /  https://github.com/ebanx/pay.git
  local slug = (out.stdout or ""):gsub("%s+$", ""):match("[:/]([%w._-]+/[%w._-]+)$")
  return slug and (slug:gsub("%.git$", "")) or nil
end

-- Opens the action menu (open in buffer, diff, review, comment, browser) for
-- the pull request that introduced the line under the cursor.
function M.pr_for_line()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or vim.bo.buftype ~= "" then
    return vim.notify("Not a file buffer", vim.log.levels.WARN)
  end

  local repo = repo_slug()
  if not repo then
    return vim.notify("No origin remote to resolve the PR against", vim.log.levels.WARN)
  end

  local line = vim.fn.line(".")
  vim.notify("Resolving the PR for line " .. line .. "...")

  M.resolve(file, line, function(number, err)
    if not number then
      return vim.notify(err, vim.log.levels.WARN)
    end
    require("snacks").picker.gh_actions({ type = "pr", repo = repo, number = number })
  end)
end

-- Background CI watcher -------------------------------------------------------

-- One watcher per branch; keyed so a second <leader>gW doesn't spawn a
-- duplicate `gh` process for checks already being waited on.
local watching = {} ---@type table<string, vim.SystemObj>

-- 25 test slots at ~8 minutes, plus queueing. Long enough not to fire on a
-- slow suite, short enough that a wedged run doesn't leak a process for the
-- rest of the session.
local WATCH_TIMEOUT_MS = 90 * 60 * 1000

-- fidget's toast only lands if nvim is on screen, so mirror it to the desktop
-- via the notifier that zsh-notify already uses.
local function desktop(title, message, sound)
  if vim.fn.executable("terminal-notifier") == 0 then
    return
  end
  vim.system({
    "terminal-notifier",
    "-title", title,
    "-message", message,
    "-sound", sound,
  })
end

local function announce(ok, branch, detail)
  local level = ok and vim.log.levels.INFO or vim.log.levels.ERROR
  local title = ok and "CI green" or "CI failed"
  vim.notify(("%s — %s%s"):format(title, branch, detail and ("\n" .. detail) or ""), level)
  desktop(title, detail and (branch .. ": " .. detail) or branch, ok and "default" or "Basso")
end

local function start_watch(branch, label, repo_root)
  vim.notify("Watching checks on " .. label .. "...")

  watching[branch] = vim.system({
    "gh", "pr", "checks", "--watch", "--fail-fast", "--interval", "30",
  }, { cwd = repo_root, text = true, timeout = WATCH_TIMEOUT_MS }, function(res)
    vim.schedule(function()
      watching[branch] = nil

      -- killed by the timeout above, or by nvim shutting down
      if res.signal and res.signal ~= 0 then
        return vim.notify("Stopped watching " .. label, vim.log.levels.WARN)
      end

      if res.code == 0 then
        return announce(true, label)
      end

      -- `gh pr checks` exits 8 while checks are still pending, which --watch
      -- normally rules out -- unless the run was cancelled mid-flight, as a
      -- force-push does.
      if res.code == 8 then
        return vim.notify("Checks on " .. label .. " are still pending", vim.log.levels.WARN)
      end

      -- name the red checks rather than just reporting failure
      vim.system({
        "gh", "pr", "checks", branch,
        "--json", "name,bucket",
        "--jq", '[.[] | select(.bucket == "fail") | .name] | join(", ")',
      }, { cwd = repo_root, text = true }, function(failed)
        vim.schedule(function()
          local names = (failed.stdout or ""):gsub("%s+$", "")
          announce(false, label, names ~= "" and names or nil)
        end)
      end)
    end)
  end)
end

-- Waits on `gh pr checks --watch` for the current branch's PR in the
-- background, then reports. Exit codes: 0 all green, 8 still pending, and
-- anything else a failure (--fail-fast returns on the first red check rather
-- than sitting through the remaining slots).
function M.watch_checks()
  local repo_root = root()

  local head = vim.system({ "git", "branch", "--show-current" }, { cwd = repo_root, text = true }):wait()
  local branch = (head.stdout or ""):gsub("%s+$", "")
  if branch == "" then
    return vim.notify("Detached HEAD -- no branch to watch", vim.log.levels.WARN)
  end

  if watching[branch] then
    return vim.notify("Already watching checks on " .. branch)
  end

  -- resolved first so a branch without a pull request reports that, rather
  -- than surfacing `gh pr checks`' generic non-zero exit as a red CI run
  vim.system(
    { "gh", "pr", "view", "--json", "number", "--jq", ".number" },
    { cwd = repo_root, text = true },
    function(res)
      vim.schedule(function()
        local number = tonumber((res.stdout or ""):match("%d+"))
        if not number then
          return vim.notify("No open pull request for " .. branch, vim.log.levels.WARN)
        end
        start_watch(branch, ("#%d %s"):format(number, branch), repo_root)
      end)
    end
  )
end

-- Create PR ------------------------------------------------------------------

-- Runs ebanx/pay's create-pr script (title = Monday ID from the branch +
-- description, body = docs/pull_request_template.md) in --dry-run first,
-- since gh pr create isn't something to fire blind -- only proceeds to the
-- real run after the preview is confirmed.
function M.create_pr()
  local repo_root = root()
  local script = repo_root .. "/.agents/skills/create-pr/scripts/create-pr.sh"
  if vim.fn.filereadable(script) == 0 then
    return vim.notify("No create-pr script at " .. script, vim.log.levels.WARN)
  end

  vim.system({ script, "--dry-run" }, { cwd = repo_root, text = true }, function(preview)
    vim.schedule(function()
      if preview.code ~= 0 then
        return vim.notify("create-pr --dry-run failed:\n" .. (preview.stderr or ""), vim.log.levels.ERROR)
      end

      vim.notify(preview.stdout, vim.log.levels.INFO, { title = "PR preview" })
      vim.ui.select({ "Create PR", "Cancel" }, { prompt = "Open this pull request?" }, function(choice)
        if choice ~= "Create PR" then
          return
        end

        vim.system({ script }, { cwd = repo_root, text = true }, function(res)
          vim.schedule(function()
            if res.code ~= 0 then
              return vim.notify("PR creation failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
            end
            vim.notify(res.stdout, vim.log.levels.INFO, { title = "PR created" })
          end)
        end)
      end)
    end)
  end)
end

return M
