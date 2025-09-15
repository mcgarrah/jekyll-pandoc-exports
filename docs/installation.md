# Installation

## System Requirements

- **Ruby**: 2.6.0 or higher
- **Jekyll**: 3.0 or higher
- **Pandoc**: Required for document conversion
- **LaTeX**: Required for PDF generation

## Step 1: Install System Dependencies

### Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install pandoc texlive-latex-base texlive-fonts-recommended texlive-latex-extra
```

### macOS

```bash
# Install Pandoc
brew install pandoc

# Install LaTeX (MacTeX)
brew install --cask mactex
```

### Windows

1. **Pandoc**: Download from [pandoc.org](https://pandoc.org/installing.html)
2. **LaTeX**: Install [MiKTeX](https://miktex.org/) or [TeX Live](https://www.tug.org/texlive/)

## Step 2: Add Gem to Your Jekyll Site

Add to your `Gemfile`:

```ruby
gem "jekyll-pandoc-exports"
```

Then run:

```bash
bundle install
```

## Step 3: Enable the Plugin

Add to your `_config.yml`:

```yaml
plugins:
  - jekyll-pandoc-exports
```

## Step 4: Verify Installation

Create a test page with export options:

```yaml
---
title: Test Export
docx: true
pdf: true
---

# Test Document

This is a test document for export functionality.
```

Build your site:

```bash
bundle exec jekyll build
```

Check for generated files in your `_site` directory:

- `test-export.docx`
- `test-export.pdf`

## Troubleshooting

### Pandoc Not Found

If you see "Pandoc not found" errors:

```bash
# Verify Pandoc installation
pandoc --version

# Check PATH (add to ~/.bashrc or ~/.zshrc if needed)
export PATH="/usr/local/bin:$PATH"
```

### LaTeX Errors

For PDF generation issues:

```bash
# Verify LaTeX installation
pdflatex --version

# Install additional packages if needed (Ubuntu)
sudo apt-get install texlive-latex-extra texlive-fonts-extra
```

### Permission Issues

If files aren't generated:

```bash
# Check Jekyll destination directory permissions
ls -la _site/

# Ensure Jekyll can write to destination
chmod 755 _site/
```

## Development Installation

For plugin development:

```bash
# Clone repository
git clone https://github.com/mcgarrah/jekyll-pandoc-exports.git
cd jekyll-pandoc-exports

# Install dependencies
bundle install

# Run tests
bundle exec rake test
```

## Next Steps

- [Quick Start Guide](quick-start.md)
- [Configuration Options](configuration.md)
- [CLI Usage](cli.md)
- [Testing Guide](testing.md)
- [Development Setup](development.md)