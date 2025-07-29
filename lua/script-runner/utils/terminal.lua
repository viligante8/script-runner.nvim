-- Terminal management utilities for script-runner.nvim
-- Handles terminal creation and management

local M = {}

-- Terminal buffer and window IDs
local terminal_buf = nil
local terminal_win = nil

-- Create or show terminal window
function M.show_terminal(config)
  config = config or {}
  local position = config.position or "horizontal"
  local size = config.size or 15
  
  -- If terminal already exists, just show it
  if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
    if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
      -- Terminal is already visible
      return terminal_buf, terminal_win
    else
      -- Terminal buffer exists but window is closed, reopen it
      M.open_terminal_window(position, size)
      return terminal_buf, terminal_win
    end
  end
  
  -- Create new terminal
  M.create_terminal(position, size)
  return terminal_buf, terminal_win
end

-- Create a new terminal
function M.create_terminal(position, size)
  position = position or "horizontal"
  size = size or 15
  
  -- Create terminal window
  M.open_terminal_window(position, size)
  
  -- Create terminal buffer
  terminal_buf = vim.api.nvim_create_buf(false, true)
  if terminal_win then
    vim.api.nvim_win_set_buf(terminal_win, terminal_buf)
  end
  
  -- TODO: Start terminal job in the buffer
end

-- Open terminal window with specified position and size
function M.open_terminal_window(position, size)
  if position == "horizontal" then
    vim.cmd("split")
    vim.cmd("resize " .. size)
    terminal_win = vim.api.nvim_get_current_win()
  elseif position == "vertical" then
    vim.cmd("vsplit")
    vim.cmd("vertical resize " .. size)
    terminal_win = vim.api.nvim_get_current_win()
  elseif position == "float" then
    -- TODO: Implement floating window
    -- For now, fall back to horizontal split
    vim.cmd("split")
    vim.cmd("resize " .. size)
    terminal_win = vim.api.nvim_get_current_win()
  end
end

-- Hide terminal window
function M.hide_terminal()
  if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
    vim.api.nvim_win_close(terminal_win, false)
    terminal_win = nil
  end
end

-- Check if terminal is visible
function M.is_terminal_visible()
  return terminal_win and vim.api.nvim_win_is_valid(terminal_win)
end

return M
