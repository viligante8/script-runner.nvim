-- Package Manager Detection Utility
--
-- This module provides automatic detection of JavaScript package managers (npm, yarn, bun)
-- in project directories by examining lock files and package.json files.
-- Adapted for script-runner.nvim plugin.
--
-- Usage:
--   local pkg_mgr = require('script-runner.utils.package-manager')
--   local manager = pkg_mgr.detect_package_manager() -- "npm", "yarn", "bun", or "unknown"
--
-- Features:
--   - Prioritized detection (bun > yarn > npm > fallback)
--   - Handles missing directories and files gracefully
--   - No external dependencies
--   - Comprehensive error handling
--
-- Example Integration:
--   if pkg_mgr.detect_package_manager() ~= "unknown" then
--     -- Setup package manager specific keybindings
--     setup_js_project_keymaps()
--   end

---@class PackageManagerUtils
local M = {}

---Detect the package manager used in a project directory
---
---This function checks for the presence of lock files and package manager-specific
---files to determine which package manager (npm, yarn, or bun) is being used.
---
---The detection follows a specific priority order to ensure the most specific
---package manager is detected first:
---
---Detection priority:
---1. bun.lockb (Bun) - Fastest and most recent
---2. yarn.lock (Yarn) - Popular alternative to npm
---3. package-lock.json (npm) - Default Node.js package manager
---4. package.json exists → fallback to npm
---5. No package files found → "unknown"
---
---Edge cases handled:
---• Non-existent directories → returns "unknown"
---• Permission denied → returns "unknown"
---• Paths with/without trailing slashes → normalized automatically
---• Special characters in paths → handled correctly
---
---Performance notes:
---• Uses vim.fn.filereadable() for efficient file existence checks
---• No file parsing - only checks existence
---• Single directory scan, no recursive searching
---
---@param cwd? string Optional current working directory (defaults to vim.fn.getcwd())
---@return string package_manager The detected package manager: "npm", "yarn", "bun", or "unknown"
---
---@usage
---local pkg_mgr = require('script-runner.utils.package-manager')
---
----- Basic usage
---local manager = pkg_mgr.detect_package_manager()
---print("Using package manager: " .. manager)
---
----- With specific directory
---local manager = pkg_mgr.detect_package_manager("/path/to/project")
---
----- Conditional logic
---if manager == "bun" then
---  vim.cmd('terminal bun install')
---elseif manager == "yarn" then
---  vim.cmd('terminal yarn install')
---elseif manager == "npm" then
---  vim.cmd('terminal npm install')
---else
---  vim.notify("No JavaScript project detected", vim.log.levels.WARN)
---end
function M.detect_package_manager(cwd)
  -- Default to current working directory if not provided
  cwd = cwd or vim.fn.getcwd()

  -- Ensure the path ends with a separator for consistent file path construction
  if not cwd:match("/$") then
    cwd = cwd .. "/"
  end

  -- Check for Bun first (bun.lockb or bun.lock)
  if
    vim.fn.filereadable(cwd .. "bun.lockb") == 1 or vim.fn.filereadable(cwd .. "bun.lock") == 1
  then
    return "bun"
  end

  -- Check for Yarn (yarn.lock)
  if vim.fn.filereadable(cwd .. "yarn.lock") == 1 then
    return "yarn"
  end

  -- Check for npm (package-lock.json)
  if vim.fn.filereadable(cwd .. "package-lock.json") == 1 then
    return "npm"
  end

  -- Fallback: if package.json exists, assume npm
  if vim.fn.filereadable(cwd .. "package.json") == 1 then
    return "npm"
  end

  -- No package manager detected
  return "unknown"
end

return M
