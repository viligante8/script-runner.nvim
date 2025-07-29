# script-runner.nvim

A Neovim plugin designed to simplify the execution of scripts defined within `package.json` for JavaScript projects. It supports various package managers and provides a streamlined interface with customizable options.

## Features

- Automatic detection of JavaScript package managers (npm, yarn, bun, pnpm)
- Script categorization and filtering
- Customizable keymaps
- Interactive picker to select and run scripts
- Terminal integration
- Configuration flexibility

## Installation

### Using lazy.nvim

```lua
require('lazy').setup({
  'vito.pistelli/script-runner.nvim',
  config = function()
    require('script-runner').setup({
      -- Configuration options here
    })
  end
})
```

## Configuration

```lua
require('script-runner').setup({
  split_direction = "vertical", -- Choose: auto/horizontal/vertical
  terminal_reuse = true,
  keymaps = {
    enabled = true,
    run_script = "<leader>sr",
    run_last = "<leader>sR",
    run_test = "<leader>st",
  },
  window_size = 0.4
})
```

## Default Keymaps

- Run Script: `<leader>sr`
- Run Last Script: `<leader>sR`
- Run Test: `<leader>st`
- Run Build: `<leader>sb`
- Run Dev: `<leader>sd`

## Usage

To run a script, use the command `:ScriptRunner` or the default keymap `<leader>sr`.

Example output:

```
+------------------------------------+
| Scripts Available                  |
|------------------------------------|
| 🎆  start - node server.js         |
| 🧪  test - jest                    |
+------------------------------------+
```

## Requirements and Dependencies

- Neovim
- Compatible package manager in the project directory (`npm`, `yarn`, `bun`, or `pnpm`)

## Troubleshooting

- Ensure you are inside a JavaScript project with a valid `package.json`.
- Verify that your package manager is supported and correctly detected.

## Contributing

Please submit issues or pull requests via GitHub. All contributions are welcome.

## License

MIT License
