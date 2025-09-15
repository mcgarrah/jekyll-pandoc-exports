# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.11] - 2025-09-15

### Added
- 

### Changed
- 

### Fixed
- 
## [0.1.10] - 2025-09-15

### Added
- 

### Changed
- 

### Fixed
- 
## Fixed
- CI workflow bundler-cache conflicts resolved
- Gemfile.lock properly updated and included in releases
- Release script now handles dependency updates correctly
- Eliminated frozen lockfile errors in GitHub Actions

### Changed
- CI workflow optimized with manual dependency installation
- Release process now includes proper Gemfile.lock management
- Enhanced reliability of automated release workflows

## [0.1.9] - 2025-09-15

### Added
- Automated release workflow testing

### Fixed
- Initial Gemfile.lock handling improvements

## [0.1.8] - 2025-09-15

### Added
- Complete release automation with GitHub CLI integration
- Enhanced bin/release script with full workflow automation
- New bin/reset-dev script for post-release dev branch preparation
- Comprehensive RELEASE_WORKFLOW.md documentation
- Automated PR creation, merge, and tag push functionality
- Intelligent changelog parsing for PR descriptions
- Next version suggestions and dev branch reset automation
- Verification URLs in script output and documentation

### Fixed
- CI workflow Ruby version compatibility issues
- CI workflow frozen Gemfile.lock issue resolved
- Restored bundler-cache for efficient CI builds
- Missing bin/reset-dev script recreated with full functionality

### Changed
- Release process reduced from 10+ manual steps to 1 command
- GitHub Actions workflows optimized with Ruby 3.0, 3.1, 3.2, 3.3 support
- Updated Ruby requirement to 3.0+ for better dependency compatibility
- Enhanced error handling and fallback procedures
- Improved developer experience with automated workflows

## [0.1.7] - 2025-09-15

### Added
- Initial release automation framework

### Changed
- Version management improvements

### Fixed
- Basic CI workflow issues

## [0.1.6] - 2025-09-15

## Fixed
- Read the Docs build configuration (docs_dir setting in mkdocs.yml)
- Complete test infrastructure overhaul - 100% test suite passing
- Method redefinition warnings eliminated
- Mock expectation errors resolved
- Jekyll logger interface conflicts fixed
- Template configuration nil errors resolved
- Incremental build logic corrected
- Utility method return types fixed
- PandocRuby conflicts eliminated

### Added
- Comprehensive test coverage (87 runs, 176 assertions)
- Bulletproof test infrastructure with 0 failures, 0 errors
- Enhanced GitHub Actions workflows for seamless releases

## [0.1.5] - 2025-09-15

### Added
- Complete Read the Docs documentation site with MkDocs
- Comprehensive installation guide with platform-specific instructions
- Quick start tutorial for immediate productivity
- Complete configuration reference with examples and tables
- Hooks system documentation with extensibility examples
- CLI usage guide with command reference and examples
- Testing documentation with coverage analysis and Phase 4 implementation plan
- Release process documentation with visual flow diagram
- Development guide for contributors
- Automated release workflow with GitHub Actions
- Trusted Publishers integration for secure RubyGems publishing
- Release management script (bin/release) for version automation
- Mermaid flow diagram visualizing complete release process
- Professional documentation structure in /docs directory

### Changed
- Migrated all documentation to /docs directory for Read the Docs integration
- Renamed documentation files to consistent kebab-case naming
- Updated README to reference comprehensive documentation site
- Enhanced gemspec to use centralized version management
- Improved cross-references between all documentation sections

### Technical Infrastructure
- Added .readthedocs.yaml for automated documentation builds
- Created mkdocs.yml with Material theme and Mermaid support
- Set up GitHub Actions workflows for CI/CD and releases
- Implemented version management with lib/jekyll-pandoc-exports/version.rb
- Added Python requirements.txt for documentation build dependencies

### Documentation
- Professional-grade documentation site ready for jekyll-pandoc-exports.readthedocs.io
- Complete API reference for hooks system and CLI tools
- Visual release process flow with decision points and error handling
- Comprehensive testing strategy with coverage gaps identified
- Development workflow documentation for contributors

## [0.1.4] - 2025-09-11

### Added
- Core functionality for generating DOCX and PDF exports from Jekyll pages
- Collection support for pages, posts, and custom collections
- Configurable output directories with auto-creation
- Dependency validation for Pandoc and LaTeX with helpful warnings
- Incremental builds with file modification time checking
- Template customization system (header/footer/CSS injection)
- Advanced error handling with configurable size limits
- Performance monitoring and debug mode
- Custom Pandoc command-line options support
- CLI tools for standalone conversion operations
- Plugin extensibility with pre/post conversion hooks system
- Statistics tracking with success rates and timing metrics
- Comprehensive unit test suite (48 tests, 121 assertions)
- Auto-injection of download links into generated pages
- Unicode cleanup for LaTeX compatibility
- Configurable HTML cleanup patterns
- Print-friendly CSS class support

### Technical Features
- Automatic dependency validation (Pandoc/LaTeX)
- File conflict handling and validation
- Image path fixing for different Jekyll configurations
- Flexible configuration merging and overrides
- Performance metrics and detailed logging
- Hook system for custom processing workflows
- Statistics collection and reporting