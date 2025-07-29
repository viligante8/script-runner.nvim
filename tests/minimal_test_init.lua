-- Minimal Neovim configuration for testing script-runner.nvim
-- This ensures we test without LazyVim dependencies

-- Set up basic vim settings
vim.opt.runtimepath:prepend("/Users/vito.pistelli/.dotfiles/nvim/script-runner.nvim")
vim.opt.packpath = vim.fn.stdpath("data") .. "/site"

-- Load the plugin
require("script-runner").setup({
    -- Test with vim.ui.select (no telescope dependency)
    ui = {
        select_provider = "vim_ui_select"
    },
    -- Test different split directions
    terminal = {
        position = "right",
        size = 40,
        reuse = true
    },
    -- Test keymaps
    keymaps = {
        run_script = "<leader>rs",
        run_script_telescope = "<leader>rt"  -- This should gracefully fail without telescope
    },
    -- Test script filtering
    script_filter = function(scripts)
        -- Filter out scripts that start with underscore (test filtering)
        local filtered = {}
        for name, command in pairs(scripts) do
            if not name:match("^_") then
                filtered[name] = command
            end
        end
        return filtered
    end
})

-- Test commands
local function test_basic_functionality()
    print("=== Testing Basic Functionality ===")
    
    -- Test 1: Check if plugin loaded
    local sr = require("script-runner")
    if sr then
        print("✓ Plugin loaded successfully")
    else
        print("✗ Plugin failed to load")
        return
    end
    
    -- Test 2: Check configuration
    local config = require("script-runner.config")
    if config and config.get then
        print("✓ Configuration module available")
        local current_config = config.get()
        print("  - UI provider: " .. (current_config.ui.select_provider or "default"))
        print("  - Terminal position: " .. (current_config.terminal.position or "default"))
        print("  - Terminal reuse: " .. tostring(current_config.terminal.reuse))
    else
        print("✗ Configuration module not available")
    end
    
    -- Test 3: Check package manager detection
    local pm = require("script-runner.utils.package-manager")
    if pm and pm.detect then
        print("✓ Package manager detection available")
        local detected = pm.detect(".")
        print("  - Detected package manager: " .. (detected or "none"))
    else
        print("✗ Package manager detection not available")
    end
    
    -- Test 4: Check script parsing
    local scripts = require("script-runner.utils.package-scripts")
    if scripts and scripts.get then
        print("✓ Script parsing available")
        local parsed = scripts.get(".")
        if parsed and type(parsed) == "table" then
            print("  - Found " .. vim.tbl_count(parsed) .. " scripts")
            for name, _ in pairs(parsed) do
                print("    - " .. name)
            end
        else
            print("  - No scripts found or invalid package.json")
        end
    else
        print("✗ Script parsing not available")
    end
    
    print("=== Basic functionality test complete ===\n")
end

-- Make test function globally available
_G.test_basic_functionality = test_basic_functionality

-- Auto-run tests if this file is loaded directly
if vim.v.vim_did_enter == 1 then
    test_basic_functionality()
end
