-- script-runner.nvim main module
-- This file contains the main functionality for the script runner plugin

local M = {}

-- Import utility modules
local config = require('script-runner.config')
local package_scripts = require('script-runner.utils.package-scripts')
local package_manager = require('script-runner.utils.package-manager')
local picker = require('script-runner.utils.picker')
local terminal = require('script-runner.terminal')

-- State management
local state = {
  last_executed_script = nil,
  last_executed_manager = nil,
  last_executed_cwd = nil
}

-- Setup function called by the plugin initialization
function M.setup(opts)
  -- Setup configuration
  config.setup(opts or {})
  
  -- Setup terminal with config
  terminal.setup({
    terminal_min_height = config.get_value('window_size') and math.floor(vim.o.lines * config.get_value('window_size')) or 10,
    terminal_min_width = config.get_value('window_size') and math.floor(vim.o.columns * config.get_value('window_size')) or 80,
  })
  
  -- Setup keymaps if enabled
  if config.get_value('keymaps.enabled') then
    M.setup_keymaps()
  end
end

-- Setup default keymaps
function M.setup_keymaps()
  local keymaps = config.get_value('keymaps')
  if not keymaps or not keymaps.enabled then
    return
  end
  
  vim.keymap.set('n', keymaps.run_script, M.run_script, { desc = 'Run script' })
  vim.keymap.set('n', keymaps.run_last, M.run_last_script, { desc = 'Run last script' })
  vim.keymap.set('n', keymaps.run_test, function() M.run_category('test') end, { desc = 'Run test script' })
  vim.keymap.set('n', keymaps.run_build, function() M.run_category('build') end, { desc = 'Run build script' })
  vim.keymap.set('n', keymaps.run_dev, function() M.run_category('start') end, { desc = 'Run dev/start script' })
end

-- Helper function to check if we're in a JavaScript project
local function is_js_project(cwd)
  return package_scripts.has_package_json(cwd)
end

-- Helper function to format script items for picker
local function format_script_item(script)
  return string.format("%s %s - %s", script.icon, script.name, script.command)
end

-- Helper function to execute a selected script
local function execute_selected_script(script, manager, cwd)
  if not script then
    vim.notify("No script selected", vim.log.levels.WARN)
    return
  end
  
  -- Store last executed script for re-running
  state.last_executed_script = script
  state.last_executed_manager = manager
  state.last_executed_cwd = cwd
  
  -- Execute the script
  local success = terminal.execute_script(script.name, manager)
  if success then
    vim.notify(string.format("Executing %s script: %s", manager or "unknown", script.name), vim.log.levels.INFO)
  else
    vim.notify("Failed to execute script", vim.log.levels.ERROR)
  end
end

-- Main function to show picker and run selected script
function M.run_script()
  local cwd = vim.fn.getcwd()
  
  -- Check if we're in a JavaScript project
  if not is_js_project(cwd) then
    vim.notify("No package.json found in current directory or parent directories", vim.log.levels.WARN)
    return
  end
  
  -- Detect package manager
  local manager = package_manager.detect_package_manager(cwd)
  if manager == "unknown" then
    vim.notify("Could not detect package manager", vim.log.levels.WARN)
    manager = "npm" -- fallback to npm
  end
  
  -- Get package scripts with filtering
  local filter_options = {
    exclude_lifecycle = config.get_value('exclude_lifecycle'),
    exclude_debug = not config.get_value('include_debug')
  }
  
  local scripts, err = package_scripts.get_package_scripts(cwd, filter_options)
  if not scripts then
    vim.notify("Error getting package scripts: " .. (err or "unknown error"), vim.log.levels.ERROR)
    return
  end
  
  if #scripts == 0 then
    vim.notify("No scripts found in package.json", vim.log.levels.WARN)
    return
  end
  
  -- Show picker
  picker.pick_script(scripts, {
    prompt = string.format("Select script to run (%s):", manager),
    format_item = format_script_item
  }, function(selected_script)
    execute_selected_script(selected_script, manager, cwd)
  end)
end

-- Re-run the most recently executed script
function M.run_last_script()
  if not state.last_executed_script then
    vim.notify("No script has been executed yet", vim.log.levels.WARN)
    return
  end
  
  local cwd = state.last_executed_cwd or vim.fn.getcwd()
  
  -- Check if we're still in a JavaScript project
  if not is_js_project(cwd) then
    vim.notify("No package.json found - cannot re-run last script", vim.log.levels.WARN)
    return
  end
  
  -- Verify the script still exists
  local scripts, err = package_scripts.get_package_scripts(cwd)
  if not scripts then
    vim.notify("Error getting package scripts: " .. (err or "unknown error"), vim.log.levels.ERROR)
    return
  end
  
  local script_exists = false
  for _, script in ipairs(scripts) do
    if script.name == state.last_executed_script.name then
      script_exists = true
      break
    end
  end
  
  if not script_exists then
    vim.notify(string.format("Script '%s' no longer exists in package.json", state.last_executed_script.name), vim.log.levels.WARN)
    return
  end
  
  -- Re-execute the script
  execute_selected_script(state.last_executed_script, state.last_executed_manager, cwd)
end

-- Run scripts filtered by category
function M.run_category(category)
  local cwd = vim.fn.getcwd()
  
  -- Check if we're in a JavaScript project
  if not is_js_project(cwd) then
    vim.notify("No package.json found in current directory or parent directories", vim.log.levels.WARN)
    return
  end
  
  -- Detect package manager
  local manager = package_manager.detect_package_manager(cwd)
  if manager == "unknown" then
    vim.notify("Could not detect package manager", vim.log.levels.WARN)
    manager = "npm" -- fallback to npm
  end
  
  -- Get package scripts filtered by category
  local filter_options = {
    exclude_lifecycle = config.get_value('exclude_lifecycle'),
    exclude_debug = not config.get_value('include_debug'),
    categories = { category }
  }
  
  local scripts, err = package_scripts.get_package_scripts(cwd, filter_options)
  if not scripts then
    vim.notify("Error getting package scripts: " .. (err or "unknown error"), vim.log.levels.ERROR)
    return
  end
  
  if #scripts == 0 then
    vim.notify(string.format("No %s scripts found in package.json", category), vim.log.levels.WARN)
    return
  end
  
  -- If only one script in category, run it directly
  if #scripts == 1 then
    execute_selected_script(scripts[1], manager, cwd)
    return
  end
  
  -- Show picker for multiple scripts in category
  picker.pick_script(scripts, {
    prompt = string.format("Select %s script to run (%s):", category, manager),
    format_item = format_script_item
  }, function(selected_script)
    execute_selected_script(selected_script, manager, cwd)
  end)
end

-- Get current state (useful for debugging and testing)
function M.get_state()
  return vim.deepcopy(state)
end

-- Clear last executed script state
function M.clear_state()
  state.last_executed_script = nil
  state.last_executed_manager = nil
  state.last_executed_cwd = nil
end

-- Get available script categories
function M.get_categories()
  return package_scripts.get_categories()
end

-- Check if package.json exists in current directory
function M.has_package_json()
  return package_scripts.has_package_json(vim.fn.getcwd())
end

-- Get detected package manager for current directory
function M.get_package_manager()
  return package_manager.detect_package_manager(vim.fn.getcwd())
end

return M
