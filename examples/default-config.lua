-- Default configuration for script-runner.nvim
-- This file shows all available configuration options with their default values

require("script-runner").setup({
  -- Terminal split direction
  -- Options: "auto", "horizontal", "vertical"
  split_direction = "vertical",

  -- Whether to reuse the same terminal for multiple script executions
  terminal_reuse = true,

  -- Terminal window size as a percentage of the editor window (0.0 to 1.0)
  window_size = 0.4,

  -- Keymap configuration
  keymaps = {
    -- Whether to enable default keymaps
    enabled = true,

    -- Individual keymap settings
    run_script = "<leader>sr", -- Show script picker
    run_last = "<leader>sR", -- Re-run last script
    run_test = "<leader>st", -- Run test scripts
    run_build = "<leader>sb", -- Run build scripts
    run_dev = "<leader>sd", -- Run dev/start scripts
  },

  -- Script filtering options
  exclude_lifecycle = true, -- Exclude npm lifecycle scripts like pretest, posttest
  include_debug = false, -- Include debug scripts in the picker

  -- Package manager preferences (auto-detected if not specified)
  -- preferred_manager = "npm",  -- Options: "npm", "yarn", "bun", "pnpm"

  -- Terminal configuration
  terminal = {
    -- Terminal position
    position = "bottom", -- Options: "bottom", "top", "left", "right", "float"

    -- For floating terminal
    float_opts = {
      border = "rounded",
      width = 0.8,
      height = 0.6,
    },
  },
})
