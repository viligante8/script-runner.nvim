-- Health check for script-runner.nvim
--
-- This module provides a health check for the script-runner.nvim plugin.
-- It checks for the following:
--   - Neovim version
--   - Configuration validity
--   - Presence of a package.json file

local M = {}

-- Compatibility layer for health check API
local health = vim.health or require("health")

function M.check()
  health.start("script-runner.nvim")

  -- Check Neovim version
  if vim.fn.has("nvim-0.7") == 1 then
    health.ok("Neovim version is compatible")
  else
    health.error("Neovim 0.7+ is required")
  end

  -- Check configuration
  local config = require("script-runner.config")
  local user_config = vim.g.script_runner_config or {}

  local valid, err = pcall(config.setup, user_config)

  if valid then
    health.ok("Configuration is valid")
  else
    health.error("Invalid configuration: " .. tostring(err))
  end

  -- Check package.json presence
  local package_scripts = require("script-runner.utils.package-scripts")
  if package_scripts.has_package_json() then
    health.ok("Found package.json in the current directory or parent directories")
  else
    health.warn("No package.json found. The plugin will not be functional in this project.")
  end

  -- Check package manager detection
  local package_manager = require("script-runner.utils.package-manager")
  local detected_manager = package_manager.detect_package_manager(vim.fn.getcwd())
  if detected_manager and detected_manager ~= "unknown" then
    health.ok("Detected package manager: " .. detected_manager)
  else
    health.warn("Could not detect package manager, will default to npm")
  end

  -- Check if we can parse scripts
  if package_scripts.has_package_json() then
    local scripts, script_err = package_scripts.get_package_scripts()
    if scripts and #scripts > 0 then
      health.ok("Found " .. #scripts .. " scripts in package.json")
    elseif scripts and #scripts == 0 then
      health.warn("No runnable scripts found in package.json")
    else
      health.error("Error parsing package.json scripts: " .. tostring(script_err))
    end
  end
end

return M
