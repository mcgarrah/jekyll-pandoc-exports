# Jekyll Pandoc Exports - Enhancement Roadmap

## Core Features

### Collection Support
- [x] Add support for `site.posts` processing
- [x] Add support for custom collections (e.g., `_portfolio`, `_projects`)
- [~] Allow per-collection configuration settings
- [ ] Add collection filtering options (tags, categories, custom fields)

### Output Management
- [x] Configurable output directories (e.g., `/downloads/`, `/exports/`)
- [~] Custom filename patterns (date, title, slug options)
- [ ] File conflict handling strategies (overwrite, skip, version)
- [ ] Output file organization (by date, category, collection)

### Template System
- [x] Pre-conversion HTML template customization
- [x] Header/footer injection for exports
- [x] Custom CSS for print/export styling
- [ ] Metadata injection (author, date, version)

## Robustness & Performance

### Dependency Management
- [x] Pandoc installation validation
- [x] LaTeX dependency checking
- [x] Graceful degradation when dependencies missing
- [ ] Version compatibility warnings

### Build Optimization
- [x] Incremental builds (only regenerate changed files)
- [x] File modification time checking
- [ ] Memory management for large files
- [ ] Parallel processing for multiple exports

### Error Handling
- [x] Content validation before conversion
- [x] Size limits and warnings
- [x] Detailed error reporting with suggestions
- [ ] Recovery strategies for partial failures

## Configuration Enhancements

### Advanced Options
- [ ] Support for all Pandoc output formats
- [x] Custom Pandoc command-line options
- [ ] Environment-specific configurations
- [ ] Conditional exports based on build environment

### Per-Content Settings
- [ ] Front matter override system
- [ ] Tag/category-based export rules
- [ ] Content-type specific templates
- [ ] Dynamic configuration via liquid tags

## Developer Experience

### Debugging & Monitoring
- [x] Debug mode with verbose logging
- [x] Performance metrics and timing
- [x] Success/failure statistics
- [ ] Export validation and verification

### Extensibility
- [x] Pre/post conversion hooks
- [x] Plugin system for custom processors
- [x] Event callbacks for integration
- [ ] API for programmatic access

### CLI Integration
- [x] Standalone conversion commands
- [x] Batch processing utilities
- [ ] Preview generation tools
- [ ] Export validation commands

## Documentation & Testing

### Documentation
- [ ] Advanced configuration examples
- [ ] Troubleshooting guide
- [ ] Performance optimization tips
- [ ] Integration examples with popular themes

### Testing
- [x] Unit tests for core functionality
- [ ] Integration tests with sample Jekyll sites
- [ ] Performance benchmarks
- [ ] Cross-platform compatibility tests

## Priority Implementation Order

### Phase 1 (Critical)
- [x] Collection support (posts, custom collections)
- [x] Configurable output directories
- [x] Dependency validation
- [x] Incremental builds

### Phase 2 (Important)
- [x] Template customization system
- [x] Advanced error handling
- [x] Performance optimization
- [x] Debug mode

### Phase 3 (Enhancement)
- [x] CLI tools
- [x] Plugin extensibility
- [ ] Advanced configuration options
- [ ] Comprehensive testing suite

---

**Legend:**
- [ ] Not started
- [x] Completed
- [~] In progress
- [!] Blocked/needs discussion