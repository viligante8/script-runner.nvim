-- Script execution module for script-runner.nvim
-- Handles the actual execution of scripts

local M = {}

-- Current running job
local current_job = nil

-- Execute a script with the given command
function M.run(command, args)
  -- TODO: Implement script execution logic
  print("Running command: " .. command .. (args and (" " .. args) or ""))

  -- Stop any currently running job
  M.stop()

  -- TODO: Start new job with proper terminal handling
end

-- Stop the currently running script
function M.stop()
  if current_job then
    -- TODO: Implement job stopping logic
    print("Stopping current script...")
    current_job = nil
  end
end

-- Check if a script is currently running
function M.is_running()
  return current_job ~= nil
end

-- Get the status of the current job
function M.get_status()
  if current_job then
    return "running"
  else
    return "idle"
  end
end

return M
