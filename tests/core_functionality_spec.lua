-- tests/core_functionality_spec.lua
describe("script-runner.nvim", function()
  -- Mock the vim api before tests run
  before_each(function()
    -- Clear package cache to ensure clean state
    package.loaded["script-runner"] = nil
    package.loaded["script-runner.init"] = nil
    package.loaded["script-runner.config"] = nil
    package.loaded["script-runner.utils.package-scripts"] = nil
    package.loaded["script-runner.utils.package-manager"] = nil
    package.loaded["script-runner.utils.picker"] = nil
    package.loaded["script-runner.terminal"] = nil

    -- Mock essential vim functions and variables
    _G.vim = {
      g = {},
      o = { lines = 50, columns = 120, shell = "bash" },
      bo = {},
      loop = {
        fs_stat = function()
          return { type = "file" }
        end,
      },
      fn = {
        getcwd = function()
          return "/tmp"
        end,
        filereadable = function()
          return 1
        end,
        has = function()
          return 1
        end,
        expand = function(s)
          return s
        end,
        json_decode = function(s)
          return { scripts = {} }
        end,
        fnamemodify = function(path, mod)
          return path
        end,
        shellescape = function(s)
          return s
        end,
        stdpath = function()
          return "/tmp"
        end,
        jobstop = function() end,
        termopen = function()
          return 1
        end,
      },
      api = {
        nvim_create_user_command = function() end,
        nvim_create_autocmd = function() end,
        nvim_create_augroup = function()
          return 1
        end,
        nvim_create_buf = function()
          return 1
        end,
        nvim_get_current_win = function()
          return 1
        end,
        nvim_win_set_buf = function() end,
        nvim_win_get_width = function()
          return 120
        end,
        nvim_win_get_height = function()
          return 50
        end,
        nvim_buf_is_valid = function()
          return true
        end,
        nvim_win_is_valid = function()
          return true
        end,
        nvim_set_current_win = function() end,
        nvim_chan_send = function() end,
      },
      log = {
        levels = {
          INFO = 1,
          WARN = 2,
          ERROR = 3,
        },
      },
      notify = function(msg, level) end,
      keymap = {
        set = function() end,
      },
      cmd = function() end,
      deepcopy = function(t)
        return t
      end,
      tbl_deep_extend = function(mode, t1, t2)
        for k, v in pairs(t2) do
          t1[k] = v
        end
        return t1
      end,
      split = function(str, sep)
        local result = {}
        for match in (str .. sep):gmatch("(.-)" .. sep) do
          table.insert(result, match)
        end
        return result
      end,
      ui = {
        select = function(items, opts, callback)
          if callback and items and #items > 0 then
            callback(items[1])
          end
        end,
      },
    }
  end)

  it("should have a setup function", function()
    local script_runner = require("script-runner")
    assert.is_function(script_runner.setup)
  end)

  it("should have a run_script function", function()
    local script_runner = require("script-runner")
    assert.is_function(script_runner.run_script)
  end)

  it("should have a run_last_script function", function()
    local script_runner = require("script-runner")
    assert.is_function(script_runner.run_last_script)
  end)

  it("should have a run_category function", function()
    local script_runner = require("script-runner")
    assert.is_function(script_runner.run_category)
  end)
end)
