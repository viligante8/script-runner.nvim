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

-- Script category patterns - now includes both name and command patterns
local CATEGORY_PATTERNS = {
  start = {
    name = { '^start', '^serve', '^server', '^run', '^go', '^launch' },
    command = { 'node.*server', 'npm.*start', 'yarn.*start', 'serve', 'http%-server', 'live%-server' }
  },
  dev = {
    name = { '^dev', '^develop', '^development', '^serve%-dev', '^start%-dev' },
    command = { 'webpack%-dev%-server', 'vite', 'next.*dev', 'nuxt.*dev', 'nodemon', 'ts%-node%-dev' }
  },
  test = {
    name = { '^test', '^spec', '^jest', '^mocha', '^vitest', '^cypress', '^e2e', '^unit', '^integration' },
    command = { 'jest', 'mocha', 'vitest', 'cypress', 'playwright', 'karma', 'ava', 'tap', 'nyc' }
  },
  build = {
    name = { '^build', '^compile', '^bundle', '^dist', '^pack', '^rollup', '^webpack' },
    command = { 'webpack', 'rollup', 'vite.*build', 'next.*build', 'nuxt.*build', 'tsc', 'babel', 'esbuild', 'parcel' }
  },
  lint = {
    name = { '^lint', '^eslint', '^tslint', '^check', '^validate' },
    command = { 'eslint', 'tslint', 'stylelint', 'prettier.*check', 'tsc.*noEmit' }
  },
  format = {
    name = { '^format', '^fmt', '^prettier', '^fix' },
    command = { 'prettier.*write', 'eslint.*fix', 'stylelint.*fix' }
  },
  deploy = {
    name = { '^deploy', '^publish', '^release', '^ship', '^push' },
    command = { 'gh%-pages', 'firebase.*deploy', 'vercel', 'netlify', 'surge', 'aws', 'docker.*push' }
  },
  clean = {
    name = { '^clean', '^clear', '^reset', '^rm', '^remove', '^nuke' },
    command = { 'rm %-rf', 'rimraf', 'del', 'shx.*rm', 'docker.*rm', 'docker.*system.*prune' }
  },
  watch = {
    name = { '^watch', '^monitor' },
    command = { 'nodemon', 'chokidar', 'onchange', 'watch' }
  },
  docs = {
    name = { '^docs', '^doc', '^generate%-docs', '^storybook', '^typedoc' },
    command = { 'typedoc', 'jsdoc', 'storybook', 'docusaurus', 'vuepress' }
  },
  install = {
    name = { '^install', '^setup', '^bootstrap', '^prepare', '^postinstall' },
    command = { 'husky.*install', 'patch%-package', 'install%-peers' }
  },
  typecheck = {
    name = { '^typecheck', '^type%-check', '^tsc', '^types' },
    command = { 'tsc.*noEmit', 'vue%-tsc' }
  },
  generate = {
    name = { '^generate', '^gen', '^create' },
    command = { 'generate', 'create', 'scaffold' }
  },
  fix = {
    name = { '^fix' },
    command = { 'fix', 'repair' }
  },
  check = {
    name = { '^check' },
    command = { 'check', 'validate', 'verify' }
  },
  docker = {
    name = { '^docker', 'docker:' },
    command = { 'docker', 'compose' }
  }
}

-- Icon mapping for different script categories
local SCRIPT_ICONS = {
  start = '🏎️',
  dev = '🏎️',
  test = '🧪',
  build = '🔨',
  deploy = '🚢',
  docker = '🐳',
  debug = '🪲',
  watch = '👀',
  docs = '📚',
  install = '📦',
  typecheck = '🔎',
  generate = '⚡',
  clean = '🧹',
  lint = '🔎',
  format = '🧹',
  fix = '🔧',
  check = '🔎',
  lifecycle = '⚙️',
  migrate = '🐪',
  db = '🏓',
  database = '🏓',
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
  
  -- Check debug scripts first
  if is_debug_script(script_name, script_command) then
    return 'debug'
  end
  
  -- Check each category
  for category, patterns in pairs(CATEGORY_PATTERNS) do
    -- Check name patterns first
    if patterns.name then
      for _, pattern in ipairs(patterns.name) do
        if script_name:match(pattern) then
          return category
        end
      end
    end
    
    -- Check command patterns if no name match
    if patterns.command then
      for _, pattern in ipairs(patterns.command) do
        if script_command:match(pattern) then
          return category
        end
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
