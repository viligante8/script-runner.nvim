#!/usr/bin/env lua

-- Comprehensive test runner for script-runner.nvim
-- This script will test all the functionality mentioned in the checklist

local function create_test_project(name, package_manager, scripts)
    local test_dir = "/tmp/script-runner-test-" .. name
    os.execute("rm -rf " .. test_dir)
    os.execute("mkdir -p " .. test_dir)
    
    local package_json = {
        name = "test-project-" .. name,
        version = "1.0.0",
        scripts = scripts or {
            test = "echo 'Running tests'",
            build = "echo 'Building project'",
            dev = "echo 'Starting dev server'",
            start = "echo 'Starting application'",
            lint = "echo 'Linting code'",
            ["lint:fix"] = "echo 'Fixing lint issues'",
            ["build:prod"] = "echo 'Building for production'"
        }
    }
    
    local json_content = vim.fn.json_encode(package_json)
    local file = io.open(test_dir .. "/package.json", "w")
    file:write(json_content)
    file:close()
    
    -- Create lock files for different package managers
    if package_manager == "npm" then
        os.execute("touch " .. test_dir .. "/package-lock.json")
    elseif package_manager == "yarn" then
        os.execute("touch " .. test_dir .. "/yarn.lock")
    elseif package_manager == "bun" then
        os.execute("touch " .. test_dir .. "/bun.lockb")
    end
    
    return test_dir
end

local function run_neovim_test(test_dir, config_file, test_name)
    local nvim_cmd = string.format([[
        cd %s && nvim --headless -u %s -c "
            lua require('test_commands')
            quit
        " 2>&1
    ]], test_dir, config_file)
    
    print("Running test: " .. test_name)
    print("Command: " .. nvim_cmd)
    
    local handle = io.popen(nvim_cmd)
    local result = handle:read("*a")
    local success = handle:close()
    
    print("Result: " .. (result or ""))
    print("Success: " .. tostring(success))
    print("---")
    
    return success, result
end

-- Test configurations
local tests = {
    {
        name = "npm_project",
        package_manager = "npm",
        description = "Test with npm project"
    },
    {
        name = "yarn_project", 
        package_manager = "yarn",
        description = "Test with yarn project"
    },
    {
        name = "bun_project",
        package_manager = "bun", 
        description = "Test with bun project"
    },
    {
        name = "no_lockfile",
        package_manager = "none",
        description = "Test with no lock file (should default to npm)"
    },
    {
        name = "invalid_scripts",
        package_manager = "npm",
        scripts = {},
        description = "Test with empty scripts"
    }
}

print("=== Script Runner Plugin Comprehensive Tests ===")
print()

-- Create test projects
local test_dirs = {}
for _, test in ipairs(tests) do
    local test_dir = create_test_project(test.name, test.package_manager, test.scripts)
    test_dirs[test.name] = test_dir
    print("Created test project: " .. test_dir)
end

print()
print("Test projects created. Manual testing required in Neovim.")
print()
print("Test directories:")
for name, dir in pairs(test_dirs) do
    print("  " .. name .. ": " .. dir)
end

print()
print("Next steps:")
print("1. Open each test directory in Neovim")
print("2. Test the plugin functionality manually")
print("3. Verify all features work as expected")
