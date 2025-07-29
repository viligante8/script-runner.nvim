# Changelog

All notable changes to the script-runner.nvim project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Enhanced script categorization with command pattern matching
- New script categories: `dev`, `typecheck` with dedicated icons
- More comprehensive pattern matching for better icon assignment
- Support for modern tools: Vite, Next.js, Nuxt, TypeScript, ESBuild, etc.

### Changed
- **BREAKING**: Telescope picker now uses smaller, centered layout instead of full-screen
- Improved script categorization logic to check both script names and commands
- Enhanced icon matching with more specific patterns for development tools
- Script categorization now prioritizes name patterns over command patterns

### Fixed
- Picker window size issue where Telescope showed full-screen instead of compact view
- Poor icon matching causing most scripts to show generic paper icon
- Missing categorization for common development scripts (dev servers, type checking)

## [1.0.1] - 2024-07-29

### Added
- Initial implementation of script-runner.nvim
- Support for npm, yarn, bun, and pnpm package managers
- Interactive script picker with categorization
- Configurable keymaps and terminal settings
- Script filtering options
- Terminal window management
- Last script re-run functionality

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

## [1.0.0] - 2024-01-XX

### Added
- Core plugin functionality
- Package manager auto-detection
- Script categorization (test, build, start, etc.)
- Customizable configuration options
- Interactive picker interface
- Terminal integration
- Default keymaps
- User commands
- Documentation and examples

---

## Version Tags

To create a new release:

1. Update the VERSION file
2. Update this CHANGELOG.md with the new version
3. Commit the changes
4. Create a git tag:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

## Release Notes Template

```markdown
## What's Changed
- Feature description
- Bug fix description
- Breaking change description (if any)

## Installation
See README.md for installation instructions.

## Configuration
See examples/ directory for configuration examples.
```
