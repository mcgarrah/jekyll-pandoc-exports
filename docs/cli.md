# CLI Usage

The Jekyll Pandoc Exports plugin includes a command-line tool for standalone conversions and batch processing.

## Installation

The CLI tool is automatically available after gem installation:

```bash
gem install jekyll-pandoc-exports
```

Or with Bundler:

```bash
bundle exec jekyll-pandoc-exports --help
```

## Basic Usage

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

# Custom source and destination
jekyll-pandoc-exports --source /path/to/jekyll --destination /path/to/output
```

## Command Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--file FILE` | `-f` | Convert single HTML file | - |
| `--format FORMAT` | - | Output format: `docx`, `pdf`, `both` | `both` |
| `--output DIR` | `-o` | Custom output directory | Same as input file |
| `--source DIR` | `-s` | Jekyll source directory | `.` |
| `--destination DIR` | `-d` | Jekyll destination directory | `_site` |
| `--debug` | - | Enable verbose debug output | `false` |
| `--help` | `-h` | Show help message | - |

## Examples

### Single File Conversion

```bash
# Basic conversion
jekyll-pandoc-exports -f about.html

# PDF with custom output
jekyll-pandoc-exports -f about.html --format pdf -o ~/Downloads

# Debug mode
jekyll-pandoc-exports -f about.html --debug
```

### Batch Processing

```bash
# Convert all HTML files in directory
for file in *.html; do
  jekyll-pandoc-exports -f "$file" -o exports/
done

# Process specific files
jekyll-pandoc-exports -f index.html -o dist/
jekyll-pandoc-exports -f about.html -o dist/
jekyll-pandoc-exports -f contact.html -o dist/
```

### Jekyll Site Processing

```bash
# Standard Jekyll site
cd my-jekyll-site
bundle exec jekyll build
jekyll-pandoc-exports --source . --destination _site

# Custom configuration
jekyll-pandoc-exports \
  --source /var/www/jekyll \
  --destination /var/www/html \
  --debug
```

## Configuration

The CLI tool uses a subset of plugin configuration options:

```bash
# These options are automatically configured:
# - enabled: true
# - debug: (from --debug flag)
# - pdf_options: { variable: 'geometry:margin=1in' }
# - unicode_cleanup: true
```

For advanced configuration, use the Jekyll plugin instead of the CLI tool.

## Output

### Success Output

```bash
$ jekyll-pandoc-exports -f page.html
Conversion complete. Generated 2 file(s).
```

### Debug Output

```bash
$ jekyll-pandoc-exports -f page.html --debug
Pandoc Exports [DEBUG]: Generated page.docx
Pandoc Exports [DEBUG]: Generated page.pdf
Conversion complete. Generated 2 file(s).
```

### Error Output

```bash
$ jekyll-pandoc-exports -f missing.html
Error: File missing.html not found

$ jekyll-pandoc-exports -f page.html --format invalid
Error: Invalid format 'invalid'. Use: docx, pdf, both
```

## Integration Examples

### Build Scripts

```bash
#!/bin/bash
# build-with-exports.sh

# Build Jekyll site
bundle exec jekyll build

# Generate exports for key pages
jekyll-pandoc-exports -f _site/index.html -o _site/downloads/
jekyll-pandoc-exports -f _site/about.html -o _site/downloads/
jekyll-pandoc-exports -f _site/services.html -o _site/downloads/

echo "Build complete with exports"
```

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Generate exports
  run: |
    bundle exec jekyll build
    jekyll-pandoc-exports --source . --destination _site --debug
```

### Makefile Integration

```makefile
# Makefile
.PHONY: build exports

build:
	bundle exec jekyll build

exports: build
	jekyll-pandoc-exports -f _site/documentation.html -o _site/downloads/
	jekyll-pandoc-exports -f _site/api-reference.html -o _site/downloads/

all: build exports
```

## Limitations

The CLI tool has some limitations compared to the full Jekyll plugin:

### Not Available in CLI
- Collection processing
- Front matter configuration
- Template customization
- Download link injection
- Incremental builds
- Jekyll-specific features

### CLI-Specific Behavior
- Uses default configuration values
- Processes individual files only
- No Jekyll context available
- Limited error recovery

## When to Use CLI vs Plugin

### Use CLI Tool When:
- Converting individual HTML files
- Batch processing outside Jekyll
- Integrating with external build systems
- Quick one-off conversions
- Testing Pandoc integration

### Use Jekyll Plugin When:
- Processing Jekyll collections
- Need template customization
- Want download link injection
- Using Jekyll-specific features
- Building complete Jekyll sites

## Troubleshooting

### Command Not Found

```bash
# Verify installation
gem list jekyll-pandoc-exports

# Use bundle exec if needed
bundle exec jekyll-pandoc-exports --help

# Check PATH
echo $PATH
```

### Pandoc Errors

```bash
# Verify Pandoc installation
pandoc --version

# Install Pandoc if missing
brew install pandoc  # macOS
sudo apt-get install pandoc  # Ubuntu
```

### Permission Errors

```bash
# Check file permissions
ls -la input.html

# Check output directory permissions
ls -ld output/

# Create output directory if needed
mkdir -p output/
```

### Large File Issues

```bash
# Use debug mode to see processing details
jekyll-pandoc-exports -f large-file.html --debug

# Check available memory
free -h  # Linux
vm_stat  # macOS
```

## Advanced Usage

### Custom Pandoc Options

The CLI tool uses standard Pandoc options. For custom options, create a wrapper script:

```bash
#!/bin/bash
# custom-convert.sh

# Set custom Pandoc options via environment
export PANDOC_OPTIONS="--toc --number-sections"

jekyll-pandoc-exports "$@"
```

### Parallel Processing

```bash
# Process multiple files in parallel
find . -name "*.html" | xargs -P 4 -I {} jekyll-pandoc-exports -f {}
```

### Monitoring Progress

```bash
# Process with progress indication
total=$(find . -name "*.html" | wc -l)
count=0

for file in *.html; do
  count=$((count + 1))
  echo "Processing $count/$total: $file"
  jekyll-pandoc-exports -f "$file" -o exports/
done
```