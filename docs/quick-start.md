# Quick Start Guide

This guide will get you up and running with Jekyll Pandoc Exports in 5 minutes.

## Prerequisites

- Jekyll site already set up
- Pandoc and LaTeX installed ([Installation Guide](installation.md))

## Step 1: Add the Plugin

Add to your `Gemfile`:

```ruby
gem "jekyll-pandoc-exports"
```

Enable in `_config.yml`:

```yaml
plugins:
  - jekyll-pandoc-exports
```

Install:

```bash
bundle install
```

## Step 2: Configure Basic Settings

Add to your `_config.yml`:

```yaml
pandoc_exports:
  enabled: true
  output_dir: 'downloads'
  collections: ['pages', 'posts']
  inject_downloads: true
```

## Step 3: Mark Pages for Export

Add front matter to any page:

```yaml
---
title: My Important Document
docx: true    # Generate Word document
pdf: true     # Generate PDF
---

# My Important Document

This content will be exported to both DOCX and PDF formats.

## Features

- Professional formatting
- Automatic download links
- Consistent styling
```

## Step 4: Build Your Site

```bash
bundle exec jekyll build
```

## Step 5: Check Results

Your site now has:

- **Generated files**: `_site/downloads/my-important-document.docx` and `.pdf`
- **Download links**: Automatically injected into the page
- **Accessible URLs**: `/downloads/my-important-document.docx`

## Example Output

The plugin automatically adds download links to your pages:

```html
<div class="pandoc-downloads no-print">
  <p><strong>Download Options:</strong></p>
  <ul>
    <li><a href="/downloads/my-document.docx">Word Document (.docx)</a></li>
    <li><a href="/downloads/my-document.pdf">PDF Document (.pdf)</a></li>
  </ul>
</div>
```

## Advanced Configuration

### Custom Output Directory

```yaml
pandoc_exports:
  output_dir: 'exports/documents'
```

### Per-Page PDF Options

```yaml
---
title: Custom Margins Document
pdf: true
pdf_options:
  variable: 'geometry:margin=0.5in'
---
```

### Template Customization

```yaml
pandoc_exports:
  template:
    header: '<div class="export-header">Company Name</div>'
    footer: '<div class="export-footer">Confidential</div>'
    css: '.export-header { font-weight: bold; text-align: center; }'
```

## CLI Usage

Convert individual files:

```bash
# Convert single file
jekyll-pandoc-exports --file page.html

# PDF only
jekyll-pandoc-exports --file page.html --format pdf

# Custom output directory
jekyll-pandoc-exports --file page.html --output /tmp/exports
```

## Troubleshooting

### No Files Generated

1. Check that pages have `docx: true` or `pdf: true` in front matter
2. Verify Pandoc is installed: `pandoc --version`
3. Check Jekyll build output for errors

### Download Links Not Appearing

1. Ensure `inject_downloads: true` in configuration
2. Check that files were actually generated
3. Verify CSS isn't hiding `.pandoc-downloads` class

### PDF Generation Fails

1. Install LaTeX: `sudo apt-get install texlive-latex-base`
2. Enable Unicode cleanup: `unicode_cleanup: true`
3. Check for special characters in content

## Next Steps

- [Complete Configuration Guide](configuration.md)
- [Template Customization](hooks.md)
- [CLI Reference](cli.md)
- [Testing Documentation](testing.md)
- [Release Process](release-process.md)
- [Development Guide](development.md)