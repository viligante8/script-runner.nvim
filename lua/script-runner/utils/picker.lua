-- Generic Picker Utility
--
-- This module provides a reusable, flexible interface for creating interactive file
-- and script selectors in Neovim. It intelligently adapts between Telescope and
-- vim.ui.select based on availability, ensuring consistent functionality across
-- different Neovim setups.
-- Adapted for script-runner.nvim plugin.
--
-- Features:
--   • Automatic UI adaptation (Telescope → vim.ui.select fallback)
--   • Flexible file filtering with patterns, depth, and executable checks
--   • Customizable item formatting and display
--   • Comprehensive parameter validation and error handling
--   • Relative path handling for clean display
--   • Seamless integration with other utility modules
--
-- Usage:
--   local picker = require('script-runner.utils.picker')
--   picker.pick_script(script_items, {
--     prompt = "Select script:",
--     format_item = function(item) return "📄 " .. item.name end
--   }, function(selection) vim.cmd('terminal ./' .. selection.name) end)
--
-- Integration with other modules:
--   • Works well with package-scripts for npm script selection
--   • Complements package-manager for project-aware functionality
--   • Can be extended for custom picker scenarios
--
-- Error handling:
--   • Validates all required parameters with user-friendly messages
--   • Handles empty results gracefully
--   • Reports command execution failures
--   • Uses vim.notify() for consistent error reporting

local M = {}

--- Enhanced picker that uses Telescope if available, otherwise falls back to vim.ui.select
--- @param items table Array of items to select from
--- @param opts table Options with prompt and format_item function
--- @param callback function Function to call when an item is selected
--- @return nil
function M.pick_script(items, opts, callback)
  -- Validate required parameters
  if not items or type(items) ~= "table" then
    vim.notify("Error: items parameter must be a table", vim.log.levels.ERROR)
    return
  end
  
  if not callback or type(callback) ~= "function" then
    vim.notify("Error: callback parameter must be a function", vim.log.levels.ERROR)
    return
  end
  
  -- Set default options if not provided
  opts = opts or {}
  local prompt = opts.prompt or "Select item:"
  local format_item = opts.format_item or function(item) return tostring(item) end
  
  -- Handle empty items list
  if #items == 0 then
    vim.notify("No items to select from", vim.log.levels.WARN)
    return
  end
  
  -- Check if telescope is available
  local has_telescope, telescope = pcall(require, "telescope")
  if has_telescope then
    -- Use telescope picker if available
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    
    pickers.new({
      -- Make the picker smaller and centered
      layout_strategy = 'center',
      layout_config = {
        width = 0.6,
        height = 0.4,
      },
    }, {
      prompt_title = prompt,
      finder = finders.new_table({
        results = items,
        entry_maker = function(entry)
          return {
            value = entry,
            display = format_item(entry),
            ordinal = format_item(entry),
          }
        end
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            callback(selection.value)
          end
        end)
        return true
      end,
    }):find()
  else
    -- Fallback to vim.ui.select if telescope is not available
    vim.ui.select(items, {
      prompt = prompt,
      format_item = format_item,
    }, callback)
  end
end


return M
