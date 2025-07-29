# Changelog

All notable changes to the script-runner.nvim project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
