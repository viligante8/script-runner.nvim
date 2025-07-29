-- File type detection utilities for script-runner.nvim
-- Handles detection of file types and corresponding run commands

local M = {}

-- Default file type patterns and their run commands
local default_patterns = {
  python = {
    pattern = "%.py$",
    command = "python3",
  },
  javascript = {
    pattern = "%.js$",
    command = "node",
  },
  lua = {
    pattern = "%.lua$",
    command = "lua",
  },
  shell = {
    pattern = "%.sh$",
    command = "bash",
  },
  -- Add more patterns as needed
}

-- Get the appropriate run command for the current file
function M.get_run_command(filepath)
  filepath = filepath or vim.fn.expand("%")
  
  for _, pattern_info in pairs(default_patterns) do
    if filepath:match(pattern_info.pattern) then
      return pattern_info.command .. " " .. vim.fn.shellescape(filepath)
    end
  end
  
  -- If no pattern matches, return nil
  return nil
end

-- Get file type from extension
function M.get_filetype(filepath)
  filepath = filepath or vim.fn.expand("%")
  
  for filetype, pattern_info in pairs(default_patterns) do
    if filepath:match(pattern_info.pattern) then
      return filetype
    end
  end
  
  return "unknown"
end

-- Check if current file is runnable
function M.is_runnable(filepath)
  return M.get_run_command(filepath) ~= nil
end

return M
