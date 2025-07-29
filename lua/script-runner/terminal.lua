local M = {}

-- Configuration
local config = {
  terminal_min_height = 10,
  terminal_min_width = 80,
  vertical_split_threshold = 120, -- columns
  horizontal_split_threshold = 30, -- lines
  default_terminal_size = 0.3, -- 30% of available space
}

-- Terminal state tracking
local terminals = {}
local current_terminal = nil

-- Package manager command mappings
local package_managers = {
  npm = {
    install = "npm install",
    run = "npm run",
    test = "npm test",
    build = "npm run build",
    dev = "npm run dev",
    start = "npm start"
  },
  yarn = {
    install = "yarn install",
    run = "yarn",
    test = "yarn test",
    build = "yarn build",
    dev = "yarn dev",
    start = "yarn start"
  },
  pnpm = {
    install = "pnpm install",
    run = "pnpm run",
    test = "pnpm test",
    build = "pnpm run build",
    dev = "pnpm dev",
    start = "pnpm start"
  },
  bun = {
    install = "bun install",
    run = "bun run",
    test = "bun test",
    build = "bun run build",
    dev = "bun dev",
    start = "bun start"
  },
  pip = {
    install = "pip install -r requirements.txt",
    run = "python",
    test = "pytest",
    build = "python setup.py build",
    dev = "python -m",
    start = "python main.py"
  },
  cargo = {
    install = "cargo build",
    run = "cargo run",
    test = "cargo test",
    build = "cargo build --release",
    dev = "cargo run",
    start = "cargo run --release"
  },
  go = {
    install = "go mod download",
    run = "go run",
    test = "go test",
    build = "go build",
    dev = "go run",
    start = "go run main.go"
  }
}

-- Get optimal split direction based on window dimensions
function M.get_optimal_split_direction()
  local win_width = vim.api.nvim_win_get_width(0)
  local win_height = vim.api.nvim_win_get_height(0)
  
  -- If window is very wide, prefer vertical split
  if win_width >= config.vertical_split_threshold then
    return "vertical"
  end
  
  -- If window is very tall, prefer horizontal split
  if win_height >= config.horizontal_split_threshold then
    return "horizontal"
  end
  
  -- Default to horizontal for smaller windows
  return "horizontal"
end

-- Calculate optimal terminal size based on direction and available space
local function calculate_terminal_size(direction, size)
  if not size then
    size = config.default_terminal_size
  end
  
  if direction == "vertical" then
    local win_width = vim.api.nvim_win_get_width(0)
    local calculated_size = math.floor(win_width * size)
    return math.max(calculated_size, config.terminal_min_width)
  else
    local win_height = vim.api.nvim_win_get_height(0)
    local calculated_size = math.floor(win_height * size)
    return math.max(calculated_size, config.terminal_min_height)
  end
end

-- Create a new terminal split
function M.create_terminal_split(direction, size)
  direction = direction or M.get_optimal_split_direction()
  local terminal_size = calculate_terminal_size(direction, size)
  
  -- Create the split
  local split_cmd
  if direction == "vertical" then
    split_cmd = "vertical split"
  else
    split_cmd = "split"
  end
  
  vim.cmd(split_cmd)
  
  -- Resize the split
  if direction == "vertical" then
    vim.cmd("vertical resize " .. terminal_size)
  else
    vim.cmd("resize " .. terminal_size)
  end
  
  -- Create terminal buffer
  local terminal_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, terminal_buf)
  
  -- Start terminal
  local job_id = vim.fn.termopen(vim.o.shell, {
    on_exit = function(_, exit_code)
      M.cleanup_terminal(terminal_buf)
    end
  })
  
  -- Store terminal information
  local terminal_info = {
    buf = terminal_buf,
    win = vim.api.nvim_get_current_win(),
    job_id = job_id,
    direction = direction,
    size = terminal_size,
    created_at = os.time()
  }
  
  terminals[terminal_buf] = terminal_info
  current_terminal = terminal_buf
  
  -- Set terminal buffer options
  vim.api.nvim_buf_set_option(terminal_buf, "filetype", "terminal")
  vim.api.nvim_buf_set_option(terminal_buf, "buflisted", false)
  vim.api.nvim_buf_set_option(terminal_buf, "bufhidden", "wipe")
  
  -- Enter insert mode in terminal
  vim.cmd("startinsert")
  
  return terminal_info
end

-- Find existing terminal that can be reused
function M.find_existing_terminal()
  -- First, check if current_terminal is still valid
  if current_terminal and terminals[current_terminal] then
    local terminal_info = terminals[current_terminal]
    
    -- Check if buffer and window are still valid
    if vim.api.nvim_buf_is_valid(terminal_info.buf) and 
       vim.api.nvim_win_is_valid(terminal_info.win) then
      return terminal_info
    else
      -- Clean up invalid terminal
      terminals[current_terminal] = nil
      current_terminal = nil
    end
  end
  
  -- Look for any valid terminal
  for buf_id, terminal_info in pairs(terminals) do
    if vim.api.nvim_buf_is_valid(terminal_info.buf) and 
       vim.api.nvim_win_is_valid(terminal_info.win) then
      current_terminal = buf_id
      return terminal_info
    else
      -- Clean up invalid terminal
      terminals[buf_id] = nil
    end
  end
  
  return nil
end

-- Get or create terminal for script execution
local function get_or_create_terminal()
  local existing_terminal = M.find_existing_terminal()
  
  if existing_terminal then
    -- Focus existing terminal
    vim.api.nvim_set_current_win(existing_terminal.win)
    return existing_terminal
  else
    -- Create new terminal
    return M.create_terminal_split()
  end
end

-- Build command string for package manager
local function build_package_command(script, package_manager)
  if not package_manager or not package_managers[package_manager] then
    -- If no package manager specified or unknown, return script as-is
    return script
  end
  
  local pm_config = package_managers[package_manager]
  
  -- Handle common script patterns
  if script == "install" and pm_config.install then
    return pm_config.install
  elseif script == "test" and pm_config.test then
    return pm_config.test
  elseif script == "build" and pm_config.build then
    return pm_config.build
  elseif script == "dev" and pm_config.dev then
    return pm_config.dev
  elseif script == "start" and pm_config.start then
    return pm_config.start
  elseif pm_config.run then
    -- For custom scripts, use the run command
    return pm_config.run .. " " .. script
  else
    -- Fallback to script as-is
    return script
  end
end

-- Execute script in terminal
function M.execute_script(script, package_manager)
  if not script or script == "" then
    vim.notify("No script provided", vim.log.levels.ERROR)
    return false
  end
  
  local terminal_info = get_or_create_terminal()
  if not terminal_info then
    vim.notify("Failed to create or find terminal", vim.log.levels.ERROR)
    return false
  end
  
  -- Build the command
  local command = build_package_command(script, package_manager)
  
  -- Clear terminal and execute command
  vim.api.nvim_chan_send(terminal_info.job_id, "\r")
  vim.api.nvim_chan_send(terminal_info.job_id, "clear\r")
  vim.api.nvim_chan_send(terminal_info.job_id, command .. "\r")
  
  -- Focus terminal window
  vim.api.nvim_set_current_win(terminal_info.win)
  
  -- Scroll to bottom
  vim.cmd("normal! G")
  
  vim.notify("Executing: " .. command, vim.log.levels.INFO)
  return true
end

-- Clean up terminal resources
function M.cleanup_terminal(buf_id)
  if buf_id and terminals[buf_id] then
    local terminal_info = terminals[buf_id]
    
    -- Stop job if still running
    if terminal_info.job_id and vim.fn.jobstop then
      pcall(vim.fn.jobstop, terminal_info.job_id)
    end
    
    -- Remove from tracking
    terminals[buf_id] = nil
    
    if current_terminal == buf_id then
      current_terminal = nil
    end
  end
end

-- Clean up all terminals
function M.cleanup_all_terminals()
  for buf_id, terminal_info in pairs(terminals) do
    M.cleanup_terminal(buf_id)
  end
  terminals = {}
  current_terminal = nil
end

-- Kill current terminal process
function M.kill_current_terminal()
  if current_terminal and terminals[current_terminal] then
    local terminal_info = terminals[current_terminal]
    if terminal_info.job_id then
      vim.fn.jobstop(terminal_info.job_id)
      vim.notify("Terminal process killed", vim.log.levels.INFO)
    end
  else
    vim.notify("No active terminal found", vim.log.levels.WARN)
  end
end

-- Toggle terminal visibility
function M.toggle_terminal()
  local existing_terminal = M.find_existing_terminal()
  
  if existing_terminal then
    local win_id = existing_terminal.win
    if vim.api.nvim_win_is_valid(win_id) then
      -- If terminal window is currently focused, close it
      if vim.api.nvim_get_current_win() == win_id then
        vim.api.nvim_win_close(win_id, false)
      else
        -- Focus the terminal window
        vim.api.nvim_set_current_win(win_id)
      end
    else
      -- Window is closed but buffer exists, create new split
      M.create_terminal_split()
    end
  else
    -- No existing terminal, create new one
    M.create_terminal_split()
  end
end

-- Get terminal status information
function M.get_terminal_status()
  local active_count = 0
  local terminal_list = {}
  
  for buf_id, terminal_info in pairs(terminals) do
    if vim.api.nvim_buf_is_valid(terminal_info.buf) then
      active_count = active_count + 1
      table.insert(terminal_list, {
        buf_id = buf_id,
        win_id = terminal_info.win,
        job_id = terminal_info.job_id,
        direction = terminal_info.direction,
        created_at = terminal_info.created_at,
        is_current = buf_id == current_terminal
      })
    end
  end
  
  return {
    active_count = active_count,
    current_terminal = current_terminal,
    terminals = terminal_list
  }
end

-- Configuration update function
function M.setup(user_config)
  if user_config then
    config = vim.tbl_deep_extend("force", config, user_config)
  end
end

-- Auto-cleanup on VimLeavePre
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    M.cleanup_all_terminals()
  end,
})

-- Clean up invalid terminals periodically
vim.api.nvim_create_autocmd("BufWipeout", {
  callback = function(args)
    local buf_id = args.buf
    if terminals[buf_id] then
      M.cleanup_terminal(buf_id)
    end
  end,
})

return M
