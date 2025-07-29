-- Custom keymaps configuration for script-runner.nvim
-- This example shows how to customize keybindings

require('script-runner').setup({
  keymaps = {
    enabled = true,
    
    -- Custom keymaps using different leaders or key combinations
    run_script = "<leader>rs",   -- Changed from default <leader>sr
    run_last = "<leader>rl",     -- Changed from default <leader>sR
    run_test = "<leader>rt",     -- Changed from default <leader>st
    run_build = "<leader>rb",    -- Changed from default <leader>sb
    run_dev = "<leader>rd",      -- Changed from default <leader>sd
  },
})

-- Alternative approach: Disable default keymaps and define your own
--[[
require('script-runner').setup({
  keymaps = {
    enabled = false,  -- Disable default keymaps
  },
})

-- Define custom keymaps manually
local script_runner = require('script-runner')

vim.keymap.set('n', '<F5>', script_runner.run_script, { desc = 'Run script' })
vim.keymap.set('n', '<F6>', script_runner.run_last_script, { desc = 'Run last script' })
vim.keymap.set('n', '<leader>tt', function() script_runner.run_category('test') end, { desc = 'Run tests' })
vim.keymap.set('n', '<leader>dd', function() script_runner.run_category('start') end, { desc = 'Run dev server' })
--]]
