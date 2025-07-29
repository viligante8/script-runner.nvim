#!/bin/bash

# Script to set up test projects for local testing of script-runner.nvim
# Usage: ./tests/setup_test_project.sh

set -e

TEST_DIR="/tmp/script-runner-test-projects"

echo "Setting up test projects for script-runner.nvim..."

# Clean up existing test projects
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

# Create npm project
echo "Creating npm test project..."
NPM_DIR="$TEST_DIR/npm-project"
mkdir -p "$NPM_DIR"
cat > "$NPM_DIR/package.json" << 'EOF'
{
  "name": "test-npm-project",
  "version": "1.0.0",
  "scripts": {
    "start": "echo 'Starting application'",
    "dev": "echo 'Starting dev server'",
    "build": "echo 'Building project'",
    "test": "echo 'Running tests'",
    "test:unit": "echo 'Running unit tests'",
    "test:integration": "echo 'Running integration tests'",
    "lint": "echo 'Linting code'",
    "lint:fix": "echo 'Fixing lint issues'",
    "format": "echo 'Formatting code'",
    "clean": "echo 'Cleaning build files'",
    "watch": "echo 'Watching for changes'",
    "deploy": "echo 'Deploying application'",
    "docs": "echo 'Generating documentation'",
    "typecheck": "echo 'Type checking'"
  }
}
EOF
touch "$NPM_DIR/package-lock.json"

# Create yarn project
echo "Creating yarn test project..."
YARN_DIR="$TEST_DIR/yarn-project"
mkdir -p "$YARN_DIR"
cat > "$YARN_DIR/package.json" << 'EOF'
{
  "name": "test-yarn-project",
  "version": "1.0.0",
  "scripts": {
    "start": "echo 'Starting with yarn'",
    "dev": "echo 'Dev server with yarn'",
    "build": "echo 'Building with yarn'",
    "test": "echo 'Testing with yarn'"
  }
}
EOF
touch "$YARN_DIR/yarn.lock"

# Create pnpm project
echo "Creating pnpm test project..."
PNPM_DIR="$TEST_DIR/pnpm-project"
mkdir -p "$PNPM_DIR"
cat > "$PNPM_DIR/package.json" << 'EOF'
{
  "name": "test-pnpm-project",
  "version": "1.0.0",
  "scripts": {
    "start": "echo 'Starting with pnpm'",
    "dev": "echo 'Dev server with pnpm'",
    "build": "echo 'Building with pnpm'",
    "test": "echo 'Testing with pnpm'"
  }
}
EOF
touch "$PNPM_DIR/pnpm-lock.yaml"

# Create bun project
echo "Creating bun test project..."
BUN_DIR="$TEST_DIR/bun-project"
mkdir -p "$BUN_DIR"
cat > "$BUN_DIR/package.json" << 'EOF'
{
  "name": "test-bun-project",
  "version": "1.0.0",
  "scripts": {
    "start": "echo 'Starting with bun'",
    "dev": "echo 'Dev server with bun'",
    "build": "echo 'Building with bun'",
    "test": "echo 'Testing with bun'"
  }
}
EOF
touch "$BUN_DIR/bun.lockb"

# Create empty scripts project
echo "Creating empty scripts test project..."
EMPTY_DIR="$TEST_DIR/empty-scripts-project"
mkdir -p "$EMPTY_DIR"
cat > "$EMPTY_DIR/package.json" << 'EOF'
{
  "name": "test-empty-project",
  "version": "1.0.0",
  "scripts": {}
}
EOF

# Create no package.json project
echo "Creating no package.json test project..."
NO_PKG_DIR="$TEST_DIR/no-package-json-project"
mkdir -p "$NO_PKG_DIR"
echo "console.log('Hello world');" > "$NO_PKG_DIR/index.js"

echo ""
echo "✅ Test projects created successfully!"
echo ""
echo "Test project directories:"
echo "  📦 npm-project: $NPM_DIR"
echo "  🧶 yarn-project: $YARN_DIR"
echo "  📦 pnpm-project: $PNPM_DIR" 
echo "  🥟 bun-project: $BUN_DIR"
echo "  📂 empty-scripts-project: $EMPTY_DIR"
echo "  ❌ no-package-json-project: $NO_PKG_DIR"
echo ""
echo "To test the plugin:"
echo "1. cd into any of the test directories"
echo "2. Start neovim: nvim"
echo "3. Run :ScriptRunner to test the picker"
echo "4. Run :checkhealth script-runner to test health checks"
echo "5. Test various commands and keymaps"
