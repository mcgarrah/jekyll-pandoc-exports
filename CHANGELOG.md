# Changelog

All notable changes to this project will be documented in this file.

## [0.1.4] - 2025-01-27

### Fixed
- Fixed gemspec to use version from version.rb file
- Disabled attestations in GitHub Actions workflow to prevent publishing errors

### Added
- CSS include file for print media queries (`_includes/pandoc-exports-css.html`)

## [0.1.3] - 2025-01-27

### Added
- GitHub Actions workflow for automated RubyGems publishing
- Rakefile with release and test tasks
- Trusted publisher configuration for RubyGems.org

## [0.1.2] - 2025-01-27

### Added
- Version management system
- Gem structure improvements

## [0.1.1] - 2025-01-27

### Added
- Initial gem structure and packaging
- Basic plugin functionality

## [0.1.0] - 2025-01-27

### Added
- Initial release of jekyll-pandoc-exports plugin
- DOCX generation using pandoc-ruby
- PDF generation with LaTeX support
- Configurable PDF options (margins, paper size, etc.)
- Unicode cleanup for LaTeX compatibility
- Automatic download link injection with styling
- Configurable HTML cleanup patterns
- Image path fixing for pandoc conversion
- Print-friendly CSS class support (`no-print`)
- Per-page PDF option overrides
- Collection support (pages, posts, custom collections)
- Incremental builds (only regenerate changed files)
- Dependency validation (Pandoc/LaTeX checking)
- Configurable output directories
- Error handling and logging
- Front matter configuration per page