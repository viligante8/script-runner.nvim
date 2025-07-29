# Script-Runner.nvim Examples

This directory contains example configurations and sample files for the script-runner.nvim plugin.

## Configuration Examples

### `minimal-config.lua`

The simplest possible setup using all default settings. Perfect for getting started quickly.

### `default-config.lua`

Shows all available configuration options with their default values. Use this as a reference for customizing the plugin.

### `custom-keymaps.lua`

Demonstrates how to customize keybindings for the plugin, including both built-in customization and manual keymap definition.

### `advanced-config.lua`

Advanced configuration example showing:

- Floating terminal windows
- Custom terminal settings
- Additional user commands
- Auto-run examples (commented out)

## Sample Files

### `sample-package.json`

A realistic `package.json` file with various script types for testing the plugin functionality. This includes:

- Start/dev scripts
- Build scripts
- Test scripts
- Linting and formatting scripts
- Lifecycle scripts (pre/post)
- Debug scripts

## Usage

To use any of these configurations, copy the relevant example to your Neovim configuration and modify as needed:

```lua
-- In your init.lua or plugin configuration
require('path/to/example-config')
```

Or integrate the setup call directly into your existing configuration:

```lua
-- In your lazy.nvim, packer, or similar plugin manager
{
  'viligante8/script-runner.nvim',
  config = function()
    -- Copy configuration from examples here
    require('script-runner').setup({
      -- Your configuration options
    })
  end
}
```

## Testing

You can test the plugin with the sample `package.json` by copying it to a test directory:

```bash
mkdir test-project
cd test-project
cp /path/to/script-runner.nvim/examples/sample-package.json package.json
nvim .
```

Then use the plugin commands to see how it works with different script types.
