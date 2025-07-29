# script-runner.nvim

A Neovim plugin designed to simplify running scripts defined in `package.json` for JavaScript projects. It supports executing scripts through package managers like npm, yarn, and bun. Features include automatic script categorization, advanced filtering, and integration with Neovim's terminal.

## Features
- Automatic detection of JavaScript package managers.
- Script categorization and filtering.
- Customizable keymaps.
- Interactive picker to select and run scripts.

## Installation

### Using lazy.nvim
```lua
require('lazy').setup({
  'vito.pistelli/script-runner.nvim',
  config = function()
    require('script-runner').setup({})
  end
})
```

### Using packer.nvim
```lua
use {
  'vito.pistelli/script-runner.nvim',
  config = function()
    require('script-runner').setup({})
  end
}
```

### Using vim-plug
```vim
Plug 'vito.pistelli/script-runner.nvim'

lua << EOF
require('script-runner').setup({})
EOF
```

## Configuration
```lua
require('script-runner').setup({
  split_direction = "vertical", -- auto/horizontal
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

## Usage
To run a script, use the command `:ScriptRunner` or the default keymap `<leader>sr`. Below are some screenshots showing the usage:

```
+------------------------------------+
| Scripts Available                  |
|------------------------------------|
| 🎆  start - node server.js         |
| 🧪  test - jest                    |
+------------------------------------+
```

## Default Keymaps
- Run Script: `<leader>sr`
- Run Last Script: `<leader>sR`
- Run Test: `<leader>st`
- Run Build: `<leader>sb`
- Run Dev: `<leader>sd`

## Troubleshooting
- Ensure you are inside a JavaScript project with a valid `package.json`.
- Verify that your package manager is supported and correctly detected.

## Contributing
Please submit issues or pull requests via GitHub. All contributions are welcome.

## License
MIT License

