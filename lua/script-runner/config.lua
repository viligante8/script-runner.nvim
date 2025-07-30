local M = {}

-- Default configuration
M.defaults = {
  split_direction = "auto", -- auto/horizontal/vertical
  terminal_reuse = true,
  exclude_lifecycle = true,
  include_debug = true,
  keymaps = {
    enabled = true,
    run_script = "<leader>dxr",
    run_last = "<leader>dxR",
    run_test = "<leader>dxt",
  },
  terminal_position = "right", -- right/bottom for splits
  window_size = 0.4, -- percentage of screen
}

-- Current configuration (starts as defaults)
M.config = vim.deepcopy(M.defaults)

-- Validation functions
local function validate_split_direction(value)
  local valid_values = { "auto", "horizontal", "vertical" }
  for _, v in ipairs(valid_values) do
    if value == v then
      return true
    end
  end
  return false, "split_direction must be one of: " .. table.concat(valid_values, ", ")
end

local function validate_terminal_position(value)
  local valid_values = { "right", "bottom" }
  for _, v in ipairs(valid_values) do
    if value == v then
      return true
    end
  end
  return false, "terminal_position must be one of: " .. table.concat(valid_values, ", ")
end

local function validate_window_size(value)
  if type(value) ~= "number" then
    return false, "window_size must be a number"
  end
  if value <= 0 or value >= 1 then
    return false, "window_size must be between 0 and 1 (exclusive)"
  end
  return true
end

local function validate_keymaps(keymaps)
  if type(keymaps) ~= "table" then
    return false, "keymaps must be a table"
  end

  -- Check required keys
  local required_keys = { "enabled", "run_script", "run_last", "run_test" }
  for _, key in ipairs(required_keys) do
    if keymaps[key] == nil then
      return false, "keymaps." .. key .. " is required"
    end
  end

  -- Validate enabled field
  if type(keymaps.enabled) ~= "boolean" then
    return false, "keymaps.enabled must be a boolean"
  end

  -- Validate keymap strings (if enabled)
  if keymaps.enabled then
    local keymap_fields = { "run_script", "run_last", "run_test" }
    for _, field in ipairs(keymap_fields) do
      if type(keymaps[field]) ~= "string" or keymaps[field] == "" then
        return false, "keymaps." .. field .. " must be a non-empty string when keymaps are enabled"
      end
    end
  end

  return true
end

-- Main validation function
local function validate_config(config)
  if type(config) ~= "table" then
    return false, "Configuration must be a table"
  end

  -- Validate split_direction
  if config.split_direction ~= nil then
    local valid, err = validate_split_direction(config.split_direction)
    if not valid then
      return false, err
    end
  end

  -- Validate terminal_reuse
  if config.terminal_reuse ~= nil and type(config.terminal_reuse) ~= "boolean" then
    return false, "terminal_reuse must be a boolean"
  end

  -- Validate exclude_lifecycle
  if config.exclude_lifecycle ~= nil and type(config.exclude_lifecycle) ~= "boolean" then
    return false, "exclude_lifecycle must be a boolean"
  end

  -- Validate include_debug
  if config.include_debug ~= nil and type(config.include_debug) ~= "boolean" then
    return false, "include_debug must be a boolean"
  end

  -- Validate keymaps
  if config.keymaps ~= nil then
    local valid, err = validate_keymaps(config.keymaps)
    if not valid then
      return false, err
    end
  end

  -- Validate terminal_position
  if config.terminal_position ~= nil then
    local valid, err = validate_terminal_position(config.terminal_position)
    if not valid then
      return false, err
    end
  end

  -- Validate window_size
  if config.window_size ~= nil then
    local valid, err = validate_window_size(config.window_size)
    if not valid then
      return false, err
    end
  end

  return true
end

-- Deep merge function
local function deep_merge(target, source)
  for key, value in pairs(source) do
    if type(value) == "table" and type(target[key]) == "table" then
      target[key] = deep_merge(target[key], value)
    else
      target[key] = value
    end
  end
  return target
end

-- Setup function to merge user config with defaults
function M.setup(user_config)
  user_config = user_config or {}

  -- Validate user configuration
  local valid, err = validate_config(user_config)
  if not valid then
    error("Invalid configuration: " .. err)
  end

  -- Start with a copy of defaults
  M.config = vim.deepcopy(M.defaults)

  -- Merge user config with defaults
  M.config = deep_merge(M.config, user_config)

  return M.config
end

-- Get current configuration
function M.get()
  return M.config
end

-- Get a specific configuration value
function M.get_value(key)
  local keys = vim.split(key, ".", { plain = true })
  local value = M.config

  for _, k in ipairs(keys) do
    if type(value) == "table" and value[k] ~= nil then
      value = value[k]
    else
      return nil
    end
  end

  return value
end

-- Update a specific configuration value (with validation)
function M.set_value(key, value)
  local keys = vim.split(key, ".", { plain = true })

  -- Create a temporary config to validate the change
  local temp_config = vim.deepcopy(M.config)
  local target = temp_config

  -- Navigate to the parent of the target key
  for i = 1, #keys - 1 do
    if type(target[keys[i]]) ~= "table" then
      target[keys[i]] = {}
    end
    target = target[keys[i]]
  end

  -- Set the value
  target[keys[#keys]] = value

  -- Validate the updated configuration
  local valid, err = validate_config(temp_config)
  if not valid then
    error("Invalid configuration change: " .. err)
  end

  -- If validation passes, apply the change
  M.config = temp_config

  return true
end

-- Reset configuration to defaults
function M.reset()
  M.config = vim.deepcopy(M.defaults)
end

return M
