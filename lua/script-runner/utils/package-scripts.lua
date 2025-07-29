-- Package Scripts Parser Utility
--
-- This module provides comprehensive parsing and categorization of npm scripts from
-- package.json files with advanced filtering, intelligent categorization, and rich metadata.
-- Adapted for script-runner.nvim plugin.

local M = {}

local uv = vim.loop

-- Default filter options
local DEFAULT_FILTER_OPTIONS = {
  exclude_lifecycle = true,
  exclude_debug = false,
  include_patterns = {},
  exclude_patterns = {},
  categories = {}
}

-- NPM lifecycle scripts that are automatically run
local LIFECYCLE_SCRIPTS = {
  'preinstall', 'install', 'postinstall',
  'preuninstall', 'uninstall', 'postuninstall',
  'preversion', 'version', 'postversion',
  'prepublish', 'prepare', 'prepublishOnly', 'publish', 'postpublish'
}

-- Script category patterns
local CATEGORY_PATTERNS = {
  start = { '^start', '^serve', '^dev' },
  test = { '^test', '^spec', '^jest', '^mocha', '^vitest' },
  build = { '^build', '^compile', '^bundle', '^dist' },
  lint = { '^lint', '^eslint', '^tslint', '^prettier' },
  format = { '^format', '^fmt', '^prettier' },
  deploy = { '^deploy', '^publish', '^release' },
  clean = { '^clean', '^clear', '^reset' },
  watch = { '^watch', '^dev' },
  docs = { '^docs', '^doc', '^generate%-docs' },
  install = { '^install', '^setup', '^bootstrap' }
}

-- Icon mapping for different script categories
local SCRIPT_ICONS = {
  start = '🎆',
  test = '🧪',
  build = '🔨',
  lint = '🔍',
  format = '✨',
  deploy = '🚀',
  clean = '🧹',
  watch = '👀',
  docs = '📚',
  install = '📦',
  debug = '🐛',
  lifecycle = '⚙️',
  unknown = '📄'
}

---Get icon for a script category
function M.get_script_icon(category)
  return SCRIPT_ICONS[category] or SCRIPT_ICONS.unknown
end

---Check if a script is a lifecycle script
local function is_lifecycle_script(script_name)
  for _, lifecycle in ipairs(LIFECYCLE_SCRIPTS) do
    if script_name == lifecycle then
      return true
    end
  end
  
  -- Check for pre/post hooks
  if script_name:match('^pre[a-zA-Z]') or script_name:match('^post[a-zA-Z]') then
    return true
  end
  
  return false
end

---Check if a script appears to be debug-related
local function is_debug_script(script_name, script_command)
  return script_name:match('debug') or script_command:match('debug') or
         script_name:match('inspect') or script_command:match('inspect')
end

---Categorize a script based on its name and command
local function categorize_script(script_name, script_command)
  if is_lifecycle_script(script_name) then
    return 'lifecycle'
  end
  
  for category, patterns in pairs(CATEGORY_PATTERNS) do
    for _, pattern in ipairs(patterns) do
      if script_name:match(pattern) then
        return category
      end
    end
  end
  
  return 'unknown'
end

---Parse package.json and extract scripts
local function parse_package_json(package_path)
  local file = io.open(package_path, 'r')
  if not file then
    return nil, 'Could not open package.json at ' .. package_path
  end
  
  local content = file:read('*all')
  file:close()
  
  local success, package_data = pcall(vim.fn.json_decode, content)
  if not success then
    return nil, 'Invalid JSON in package.json'
  end
  
  if not package_data.scripts or type(package_data.scripts) ~= 'table' then
    return {}, nil
  end
  
  return package_data.scripts, nil
end

---Find package.json file starting from cwd and walking up
local function find_package_json(cwd)
  local current_path = vim.fn.fnamemodify(cwd, ':p:h')
  
  while current_path ~= '/' and current_path ~= '' do
    local package_path = current_path .. '/package.json'
    local stat = uv.fs_stat(package_path)
    
    if stat and stat.type == 'file' then
      return package_path, nil
    end
    
    local parent = vim.fn.fnamemodify(current_path, ':h')
    if parent == current_path then
      break
    end
    current_path = parent
  end
  
  return nil, 'No package.json found in ' .. cwd .. ' or parent directories'
end

---Apply filters to scripts
local function apply_filters(scripts, filter_options)
  local filtered = {}
  
  for _, script in ipairs(scripts) do
    local should_include = true
    
    if filter_options.exclude_lifecycle and script.is_lifecycle then
      should_include = false
    end
    
    if filter_options.exclude_debug and script.is_debug then
      should_include = false
    end
    
    -- Filter by categories
    if #filter_options.categories > 0 then
      local category_match = false
      for _, category in ipairs(filter_options.categories) do
        if script.category == category then
          category_match = true
          break
        end
      end
      if not category_match then
        should_include = false
      end
    end
    
    if should_include then
      table.insert(filtered, script)
    end
  end
  
  return filtered
end

---Get package.json scripts with filtering and categorization
function M.get_package_scripts(cwd, filter_options)
  cwd = cwd or vim.fn.getcwd()
  filter_options = vim.tbl_deep_extend('force', DEFAULT_FILTER_OPTIONS, filter_options or {})
  
  -- Find package.json
  local package_path, find_error = find_package_json(cwd)
  if not package_path then
    return nil, find_error
  end
  
  -- Parse package.json
  local raw_scripts, parse_error = parse_package_json(package_path)
  if not raw_scripts then
    return nil, parse_error
  end
  
  -- Convert to PackageScript objects
  local scripts = {}
  for name, command in pairs(raw_scripts) do
    local category = categorize_script(name, command)
    local script = {
      name = name,
      command = command,
      category = category,
      is_lifecycle = is_lifecycle_script(name),
      is_debug = is_debug_script(name, command),
      icon = M.get_script_icon(category)
    }
    table.insert(scripts, script)
  end
  
  -- Sort scripts alphabetically
  table.sort(scripts, function(a, b)
    return a.name < b.name
  end)
  
  -- Apply filters
  local filtered_scripts = apply_filters(scripts, filter_options)
  
  return filtered_scripts, nil
end

---Check if package.json exists in the given directory or parents
function M.has_package_json(cwd)
  cwd = cwd or vim.fn.getcwd()
  local package_path, _ = find_package_json(cwd)
  return package_path ~= nil
end

---Get the path to the nearest package.json file
function M.get_package_json_path(cwd)
  cwd = cwd or vim.fn.getcwd()
  local package_path, _ = find_package_json(cwd)
  return package_path
end

---Get available script categories
function M.get_categories()
  local categories = {}
  for category, _ in pairs(CATEGORY_PATTERNS) do
    table.insert(categories, category)
  end
  table.sort(categories)
  return categories
end

return M
