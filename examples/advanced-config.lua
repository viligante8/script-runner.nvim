-- Advanced configuration for script-runner.nvim
-- This example shows more advanced configuration options

require('script-runner').setup({
  -- Use horizontal split instead of vertical
  split_direction = "horizontal",
  
  -- Don't reuse terminal - create new one each time
  terminal_reuse = false,
  
  -- Larger terminal window (60% of screen)
  window_size = 0.6,
  
  -- Custom keymaps with descriptions
  keymaps = {
    enabled = true,
    run_script = "<C-r>",       -- Ctrl+r for quick access
    run_last = "<C-r><C-r>",    -- Double Ctrl+r for last script
    run_test = "<leader>t",     -- Shorter test keymap
    run_build = "<leader>b",    -- Shorter build keymap
    run_dev = "<leader>s",      -- 's' for server/start
  },
  
  -- Advanced filtering options
  exclude_lifecycle = false,  -- Include lifecycle scripts
  include_debug = true,       -- Include debug scripts
  
  -- Terminal configuration
  terminal = {
    position = "float",  -- Use floating terminal
    float_opts = {
      border = "double",
      width = 0.9,
      height = 0.7,
      row = 0.1,
      col = 0.05,
    },
  },
})

-- Additional custom commands for power users
vim.api.nvim_create_user_command('RunScript', function(opts)
  local script_runner = require('script-runner')
  if opts.args and opts.args ~= '' then
    -- Try to run specific script by name
    script_runner.run_specific_script(opts.args)
  else
    script_runner.run_script()
  end
end, {
  nargs = '?',
  desc = 'Run a specific script by name or show picker',
  complete = function()
    -- You could implement script name completion here
    return {}
  end
})

-- Custom autocommand to auto-run tests on file save (optional)
--[[
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.js,*.ts,*.jsx,*.tsx",
  callback = function()
    local script_runner = require('script-runner')
    if script_runner.has_package_json() then
      -- Uncomment to auto-run tests on save
      -- script_runner.run_category('test')
    end
  end,
})
--]]
