return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    require("config.dap-php").setup()
  end,
  keys = {
    { "<leader>dd", function() require("dap").continue() end, desc = "Start/continue", mode = { "n", "v" } },
    { "<leader>dq", function() require("dap").terminate() end, desc = "Stop", mode = { "n", "v" } },
    { "<leader>dc", function() require("dap").continue() end, desc = "Continue", mode = { "n", "v" } },
    { "<leader>dn", function() require("dap").step_over() end, desc = "Step over", mode = { "n", "v" } },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step in", mode = { "n", "v" } },
    { "<leader>do", function() require("dap").step_out() end, desc = "Step out", mode = { "n", "v" } },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Breakpoint", mode = { "n", "v" } },
    { "<leader>dB", function() require("dapui").toggle() end, desc = "Breakpoints/UI", mode = { "n", "v" } },
    { "<leader>dr", function() require("dap").restart() end, desc = "Restart", mode = { "n", "v" } },
  },
}
