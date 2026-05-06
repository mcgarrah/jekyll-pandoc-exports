# CLI & Command Usage

Jekyll Pandoc Exports provides two ways to run exports from the command line:

1. **`jekyll export`** — A Jekyll command that runs within your site's context (reads `_config.yml`, knows your collections). This is the recommended approach for Jekyll sites.
2. **`jekyll-pandoc-exports`** — A standalone CLI tool for converting individual HTML files outside of Jekyll.

## Jekyll Export Command

*Added in v0.2.0*

The `jekyll export` command generates PDF and DOCX files from your built site without triggering a full `jekyll build`. It reads your `_config.yml` for `pandoc_exports` settings and processes pages that have `pdf: true` or `docx: true` in their front matter.

### Prerequisites

The site must be built first (`_site/` must exist):

```bash
bundle exec jekyll build
bundle exec jekyll export
```

### Basic Usage

```bash
# Export all configured pages (both PDF and DOCX)
bundle exec jekyll export

# Export PDF only
bundle exec jekyll export --format pdf

# Export DOCX only
bundle exec jekyll export --format docx
```

### Targeting Specific Pages

```bash
# Export only the print page
bundle exec jekyll export --target print

# Export only the about page
bundle exec jekyll export --target about
```

### Dry Run Mode

Print the exact Pandoc command that would be executed without actually running it. Invaluable for debugging LaTeX template issues:

```bash
bundle exec jekyll export --dry-run
```

Output shows:

- The Pandoc command with all flags
- Input size (bytes of processed HTML)
- Output file path
- Whether Unicode cleanup is enabled
- How many `title_cleanup` patterns are applied

### Schema Validation

Validate your `_data/data.yml` structure before attempting export. Catches missing fields and malformed data early:

```bash
bundle exec jekyll export --validate
```

Validation checks:

- Required top-level sections exist (`sidebar`, `career-profile`, `education`, `experiences`)
- Required sidebar fields are present (`name`, `tagline`, `email`)
- Experience entries have `role`, `company`, and `time`
- Education entries have `degree` and `university`
- YAML syntax is valid

Combine with export:

```bash
bundle exec jekyll export --validate --format pdf
```

### Custom Output Directory

```bash
# Override the configured output directory
bundle exec jekyll export --output ~/Downloads

# Export to a specific path
bundle exec jekyll export --output ./dist/exports
```

### All Options

| Option | Description | Default |
|--------|-------------|---------|
| `--format FORMAT` | Output format: `pdf`, `docx`, `both` | `both` |
| `--target TARGET` | Export specific page by filename | All configured pages |
| `--dry-run` | Print Pandoc command without executing | `false` |
| `--validate` | Validate `_data/data.yml` schema first | `false` |
| `--output DIR` | Override output directory | From `_config.yml` |
| `--source DIR` | Source directory | `.` |
| `--config FILE` | Configuration file | `_config.yml` |

### How It Works

1. Reads `_config.yml` for `pandoc_exports` settings
2. Scans source directory for `.html` files with `pdf: true` or `docx: true` front matter
3. Locates the corresponding built HTML in `_site/`
4. Applies `title_cleanup` patterns and `image_path_fixes` from config
5. Applies template CSS injection
6. Runs Pandoc conversion (PDF via LaTeX, DOCX directly)
7. Writes output to the configured directory

### Workflow Examples

#### Fast iteration on PDF styling

```bash
# Build once
bundle exec jekyll build

# Iterate on export without rebuilding
bundle exec jekyll export --format pdf --target print

# Check what Pandoc sees
bundle exec jekyll export --dry-run --target print
```

#### CI/CD integration

```yaml
# GitHub Actions
- name: Build site
  run: bundle exec jekyll build

- name: Validate and export
  run: bundle exec jekyll export --validate

- name: Upload artifacts
  uses: actions/upload-artifact@v4
  with:
    name: resume-exports
    path: _site/downloads/
```

#### Pre-commit validation

```bash
# Validate data before committing
bundle exec jekyll export --validate
```

---

## Standalone CLI Tool

The standalone CLI converts individual HTML files without requiring a Jekyll site context. Useful for one-off conversions or integration with external build systems.

### Installation

```bash
gem install jekyll-pandoc-exports
```

Or with Bundler:

```bash
bundle exec jekyll-pandoc-exports --help
```

### Convert Single File

```bash
# Convert HTML file to both DOCX and PDF
jekyll-pandoc-exports --file page.html

# Convert to PDF only
jekyll-pandoc-exports --file page.html --format pdf

# Convert to DOCX only
jekyll-pandoc-exports --file page.html --format docx
```

### Custom Output Directory

```bash
# Specify output directory
jekyll-pandoc-exports --file page.html --output /tmp/exports

# Output to current directory
jekyll-pandoc-exports --file page.html --output .
```

### Process Entire Jekyll Site

```bash
# Process entire site (from Jekyll root)
jekyll-pandoc-exports --source . --destination _site
```

### Standalone CLI Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--file FILE` | `-f` | Convert single HTML file | - |
| `--format FORMAT` | - | Output format: `docx`, `pdf`, `both` | `both` |
| `--output DIR` | `-o` | Custom output directory | Same as input file |
| `--source DIR` | `-s` | Jekyll source directory | `.` |
| `--destination DIR` | `-d` | Jekyll destination directory | `_site` |
| `--debug` | - | Enable verbose debug output | `false` |
| `--help` | `-h` | Show help message | - |

### Batch Processing

```bash
# Convert all HTML files in directory
for file in *.html; do
  jekyll-pandoc-exports -f "$file" -o exports/
done
```

---

## When to Use Which

| Scenario | Use |
|----------|-----|
| Normal Jekyll site workflow | `jekyll export` |
| Fast PDF/DOCX iteration without rebuild | `jekyll export` |
| Validate data.yml before export | `jekyll export --validate` |
| Debug Pandoc/LaTeX issues | `jekyll export --dry-run` |
| Convert standalone HTML files | `jekyll-pandoc-exports` CLI |
| External build system integration | `jekyll-pandoc-exports` CLI |
| One-off file conversion | `jekyll-pandoc-exports` CLI |

## Troubleshooting

### "No export targets found"

The `jekyll export` command requires:

1. A built site (`bundle exec jekyll build` first)
2. Pages with `pdf: true` or `docx: true` in front matter

### "Site destination not found"

Run `bundle exec jekyll build` before `bundle exec jekyll export`.

### Pandoc errors

Use `--dry-run` to see the exact command, then run it manually for detailed error output:

```bash
bundle exec jekyll export --dry-run
# Copy the printed command and run it directly
```

### Schema validation failures

Fix the reported issues in `_data/data.yml`. Common problems:

- Missing required fields (name, email, tagline)
- Experience entries without role/company/time
- YAML syntax errors (bad indentation, unclosed quotes)
