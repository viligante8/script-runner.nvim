-- script-runner.nvim - A Neovim plugin for running scripts
-- Plugin entry point with initialization checks, commands, and lazy loading

-- Plugin initialization check to prevent double loading
if vim.g.loaded_script_runner then
  return
end
vim.g.loaded_script_runner = 1

-- Global variable to track plugin state
vim.g.script_runner_state = {
  initialized = false,
  setup_called = false,
  commands_created = false,
  keymaps_registered = false
}

-- Lazy loading flag - set to true if plugin should be lazy loaded
local lazy_loading = vim.g.script_runner_lazy_load or false

-- Main module reference for lazy loading
local script_runner = nil

-- Helper function to ensure plugin is loaded
local function ensure_loaded()
  if not script_runner then
    script_runner = require('script-runner')
    
    -- Call setup if not already called and we have a config
    if not vim.g.script_runner_state.setup_called then
      local user_config = vim.g.script_runner_config or {}
      script_runner.setup(user_config)
      vim.g.script_runner_state.setup_called = true
      vim.g.script_runner_state.initialized = true
    end
  end
  return script_runner
end

-- Create user commands
local function create_commands()
  if vim.g.script_runner_state.commands_created then
    return
  end
  
  -- Main command to run a script with picker
  vim.api.nvim_create_user_command('ScriptRunner', function(opts)
    local sr = ensure_loaded()
    if opts.args and opts.args ~= '' then
      -- If argument provided, try to run that specific script
      sr.run_specific_script(opts.args)
    else
      -- Show picker
      sr.run_script()
    end
  end, {
    nargs = '?',
    desc = 'Run a script from package.json (shows picker or runs specific script)',
    complete = function()
      -- Lazy load and get available scripts for completion
      local sr = ensure_loaded()
      return sr.get_available_scripts and sr.get_available_scripts() or {}
    end
  })
  
  -- Command to re-run the last executed script
  vim.api.nvim_create_user_command('ScriptRunnerLast', function()
    local sr = ensure_loaded()
    sr.run_last_script()
  end, {
    desc = 'Re-run the last executed script'
  })
  
  -- Commands for specific categories
  vim.api.nvim_create_user_command('ScriptRunnerTest', function()
    local sr = ensure_loaded()
    sr.run_category('test')
  end, {
    desc = 'Run test scripts from package.json'
  })
  
  vim.api.nvim_create_user_command('ScriptRunnerBuild', function()
    local sr = ensure_loaded()
    sr.run_category('build')
  end, {
    desc = 'Run build scripts from package.json'
  })
  
  vim.api.nvim_create_user_command('ScriptRunnerDev', function()
    local sr = ensure_loaded()
    sr.run_category('start')
  end, {
    desc = 'Run dev/start scripts from package.json'
  })
  
  -- Command to check plugin status
  vim.api.nvim_create_user_command('ScriptRunnerStatus', function()
    local sr = ensure_loaded()
    local state = sr.get_state and sr.get_state() or {}
    local has_package_json = sr.has_package_json and sr.has_package_json() or false
    local package_manager = sr.get_package_manager and sr.get_package_manager() or 'unknown'
    
    print('Script Runner Status:')
    print('  Plugin loaded: ' .. tostring(vim.g.script_runner_state.initialized))
    print('  Setup called: ' .. tostring(vim.g.script_runner_state.setup_called))
    print('  Package.json found: ' .. tostring(has_package_json))
    print('  Package manager: ' .. package_manager)
    print('  Last script: ' .. (state.last_executed_script and state.last_executed_script.name or 'none'))
  end, {
    desc = 'Show script runner plugin status'
  })
  
  -- Command to clear last script state
  vim.api.nvim_create_user_command('ScriptRunnerClear', function()
    local sr = ensure_loaded()
    sr.clear_state()
    vim.notify('Script runner state cleared', vim.log.levels.INFO)
  end, {
    desc = 'Clear last executed script state'
  })
  
  vim.g.script_runner_state.commands_created = true
end

-- Setup default keymaps (if enabled in config)
local function setup_default_keymaps()
  if vim.g.script_runner_state.keymaps_registered then
    return
  end
  
  -- Check if keymaps should be registered
  local config = vim.g.script_runner_config or {}
  local keymaps = config.keymaps or { enabled = true }
  
  if not keymaps.enabled then
    return
  end
  
  -- Set up default keymaps with lazy loading
  local default_keymaps = {
    run_script = keymaps.run_script or '<leader>sr',
    run_last = keymaps.run_last or '<leader>sR',
    run_test = keymaps.run_test or '<leader>st',
    run_build = keymaps.run_build or '<leader>sb',
    run_dev = keymaps.run_dev or '<leader>sd'
  }
  
  vim.keymap.set('n', default_keymaps.run_script, function()
    local sr = ensure_loaded()
    sr.run_script()
  end, { desc = 'Run script' })
  
  vim.keymap.set('n', default_keymaps.run_last, function()
    local sr = ensure_loaded()
    sr.run_last_script()
  end, { desc = 'Run last script' })
  
  vim.keymap.set('n', default_keymaps.run_test, function()
    local sr = ensure_loaded()
    sr.run_category('test')
  end, { desc = 'Run test script' })
  
  vim.keymap.set('n', default_keymaps.run_build, function()
    local sr = ensure_loaded()
    sr.run_category('build')
  end, { desc = 'Run build script' })
  
  vim.keymap.set('n', default_keymaps.run_dev, function()
    local sr = ensure_loaded()
    sr.run_category('start')
  end, { desc = 'Run dev/start script' })
  
  vim.g.script_runner_state.keymaps_registered = true
end

-- Auto command to setup keymaps after VimEnter (for lazy loading)
local function setup_autocmd()
  vim.api.nvim_create_autocmd('VimEnter', {
    group = vim.api.nvim_create_augroup('ScriptRunnerSetup', { clear = true }),
    callback = function()
      -- Only setup keymaps if not in lazy loading mode or if explicitly requested
      if not lazy_loading or vim.g.script_runner_setup_keymaps then
        setup_default_keymaps()
      end
    end,
    once = true
  })
end

-- Initialize plugin
local function init_plugin()
  -- Always create commands (they're lightweight)
  create_commands()
  
  -- Setup autocmd for keymaps
  setup_autocmd()
  
  -- If not lazy loading, initialize immediately
  if not lazy_loading then
    -- Load and setup the main module
    local user_config = vim.g.script_runner_config or {}
    script_runner = require('script-runner')
    script_runner.setup(user_config)
    
    vim.g.script_runner_state.setup_called = true
    vim.g.script_runner_state.initialized = true
    
    -- Setup keymaps immediately if enabled
    setup_default_keymaps()
  end
end

-- Public setup function for manual initialization
function _G.script_runner_setup(config)
  vim.g.script_runner_config = config or {}
  
  if not vim.g.script_runner_state.setup_called then
    local sr = ensure_loaded()
    vim.g.script_runner_state.setup_called = true
    vim.g.script_runner_state.initialized = true
  end
  
  -- Force setup keymaps if requested
  if config and config.keymaps and config.keymaps.enabled then
    vim.g.script_runner_setup_keymaps = true
    setup_default_keymaps()
  end
end

-- Initialize the plugin
init_plugin()
