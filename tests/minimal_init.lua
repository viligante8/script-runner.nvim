-- Minimal init.lua for testing script-runner.nvim
-- This file sets up the minimum required environment for running tests

-- Set up package path for the plugin
local plugin_dir = vim.fn.expand("<sfile>:p:h:h")
vim.opt.rtp:prepend(plugin_dir)

-- Ensure lua directory is in package path
package.path = package.path .. ";" .. plugin_dir .. "/lua/?.lua"
package.path = package.path .. ";" .. plugin_dir .. "/lua/?/init.lua"

-- Basic Neovim settings for testing
vim.opt.compatible = false
vim.opt.runtimepath:append(plugin_dir)

-- Load the plugin
vim.cmd("runtime! plugin/script-runner.lua")
