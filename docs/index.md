# Jekyll Pandoc Exports

A Jekyll plugin that automatically generates DOCX and PDF exports of your pages using Pandoc.

## Features

- **Multi-format exports**: Generate Word documents (.docx) and PDFs from Jekyll pages, posts, and collections
- **Smart organization**: Configurable output directories for organized file management
- **Performance optimized**: Incremental builds (only regenerate changed files)
- **Dependency validation**: Automatic Pandoc/LaTeX detection with helpful setup guidance
- **Template system**: Custom header/footer/CSS injection for branded exports
- **Extensible**: Plugin hooks for custom processing workflows
- **CLI tools**: Standalone conversion commands for batch processing
- **Statistics**: Performance monitoring and success tracking

## Quick Start

### 1. Install Dependencies

```bash
# Ubuntu/Debian
sudo apt-get install pandoc texlive-latex-base texlive-fonts-recommended texlive-latex-extra

# macOS
brew install pandoc
brew install --cask mactex
```

### 2. Add to Gemfile

```ruby
gem "jekyll-pandoc-exports"
```

### 3. Enable Plugin

Add to your `_config.yml`:

```yaml
plugins:
  - jekyll-pandoc-exports
```

### 4. Configure Pages

Add front matter to any page you want to export:

```yaml
---
title: My Document
docx: true    # Generate Word document
pdf: true     # Generate PDF
---
```

## Basic Configuration

```yaml
pandoc_exports:
  enabled: true
  output_dir: 'downloads'
  collections: ['pages', 'posts']
  incremental: true
  debug: true
```

## What's Generated

The plugin generates files with the same name as your markdown file:

- `my-page.md` → `my-page.docx` and `my-page.pdf`
- Accessible at `/downloads/my-page.docx` and `/downloads/my-page.pdf`

## Next Steps

- [Installation Guide](installation.md) - Detailed setup instructions
- [Configuration](configuration.md) - Complete configuration options
- [Quick Start](quick-start.md) - Step-by-step tutorial

## Production Ready

✅ **Comprehensive test suite** (48 tests, 121 assertions)  
✅ **Automated CI/CD** with GitHub Actions  
✅ **Semantic versioning** and automated releases  
✅ **Complete documentation** with examples