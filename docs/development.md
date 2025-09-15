# Development Guide

Guide for contributing to Jekyll Pandoc Exports development.

## Development Setup

### 1. Clone Repository

```bash
git clone https://github.com/mcgarrah/jekyll-pandoc-exports.git
cd jekyll-pandoc-exports
```

### 2. Install Dependencies

```bash
# Install Ruby dependencies
bundle install

# Install system dependencies (Ubuntu/Debian)
sudo apt-get install pandoc texlive-latex-base

# Install system dependencies (macOS)
brew install pandoc
brew install --cask mactex
```

### 3. Run Tests

```bash
# Run all tests
bundle exec rake test

# Run specific test file
ruby test/test_hooks.rb

# Run with verbose output
ruby test/test_unit.rb -v
```

## Development Workflow

### Branch Strategy

- **`main`**: Production-ready code
- **`dev`**: Development branch for new features
- **`feature/*`**: Individual feature branches

### Making Changes

```bash
# Start from dev branch
git checkout dev
git pull origin dev

# Create feature branch
git checkout -b feature/my-new-feature

# Make changes and test
bundle exec rake test

# Commit changes
git commit -m "Add new feature"
git push origin feature/my-new-feature

# Create PR to dev branch
```

## Code Structure

```
lib/jekyll-pandoc-exports/
├── generator.rb      # Main plugin logic
├── hooks.rb          # Extensibility system
├── statistics.rb     # Performance tracking
└── version.rb        # Version management

test/
├── test_*.rb         # Unit tests
└── test_helper.rb    # Test utilities

bin/
└── release           # Release management script
```

## Testing Guidelines

### Writing Tests

- **Unit tests**: Test individual methods in isolation
- **Integration tests**: Test component interactions
- **Mock external dependencies**: Use mocks for Pandoc, file system
- **Test edge cases**: Error conditions, invalid input

### Test Structure

```ruby
require 'minitest/autorun'

class TestMyFeature < Minitest::Test
  def setup
    # Test setup
  end
  
  def test_feature_works
    # Arrange
    input = "test input"
    
    # Act
    result = MyClass.process(input)
    
    # Assert
    assert_equal "expected", result
  end
end
```

### Running Tests

```bash
# All tests
rake test

# Specific test file
ruby test/test_hooks.rb

# With coverage (if configured)
COVERAGE=true rake test
```

## Code Style

### Ruby Style Guide

Follow standard Ruby conventions:

- 2-space indentation
- Snake_case for methods and variables
- CamelCase for classes and modules
- Descriptive method names
- Comments for complex logic

### Example

```ruby
module Jekyll
  module PandocExports
    def self.process_html_content(html_content, site, config)
      processed = html_content.dup
      
      # Apply template customizations
      processed = apply_template(processed, config)
      
      # Apply image path fixes
      config['image_path_fixes'].each do |fix|
        processed.gsub!(Regexp.new(fix['pattern']), 
                       fix['replacement'].gsub('{{site.dest}}', site.dest))
      end
      
      processed
    end
  end
end
```

## Adding New Features

### 1. Plan the Feature

- Review [ROADMAP.md](../ROADMAP.md) for planned features
- Create GitHub issue for discussion
- Consider backward compatibility

### 2. Implement

- Add configuration options if needed
- Implement core functionality
- Add error handling
- Update documentation

### 3. Test

- Write unit tests for new methods
- Add integration tests if needed
- Test with real Jekyll sites
- Verify error conditions

### 4. Document

- Update configuration reference
- Add usage examples
- Update README if needed
- Add changelog entry

## Release Process

See [Release Process](release-process.md) for complete details.

### Quick Release

```bash
# Ensure on main branch
git checkout main
git pull origin main

# Run release script
bin/release 1.1.0

# This automatically:
# - Updates version.rb
# - Updates CHANGELOG.md
# - Runs tests
# - Creates git tag
# - Triggers automated publishing
```

## Debugging

### Debug Mode

Enable debug logging in tests:

```ruby
config = { 'debug' => true }
Jekyll::PandocExports.log_message(config, "Debug info")
```

### Common Issues

**Tests failing with Pandoc errors:**
```bash
# Mock Pandoc in tests
PandocRuby.stub :convert, "mock_content" do
  # Test code here
end
```

**File system issues:**
```bash
# Use temporary directories
Dir.mktmpdir do |tmpdir|
  # Test with tmpdir
end
```

## Documentation

### Local Documentation

Build documentation locally:

```bash
cd docs
pip install -r requirements.txt
mkdocs serve
```

View at: http://localhost:8000

### Documentation Structure

- **User guides**: Installation, quick start, configuration
- **API reference**: Hooks, CLI, configuration options
- **Developer docs**: Testing, release process, development setup

## Performance Considerations

### Optimization Guidelines

- **Minimize file I/O**: Cache file reads when possible
- **Efficient regex**: Use specific patterns, avoid backtracking
- **Memory usage**: Process large files in chunks
- **Pandoc calls**: Batch conversions when possible

### Profiling

```ruby
# Add timing to methods
start_time = Time.now
# ... method logic ...
duration = Time.now - start_time
puts "Method took #{duration}s"
```

## Security Considerations

- **Input validation**: Sanitize user input
- **File paths**: Validate and restrict file access
- **Command injection**: Use safe command execution
- **Dependency updates**: Keep dependencies current

## Getting Help

- **GitHub Issues**: Bug reports and feature requests
- **Discussions**: General questions and ideas
- **Documentation**: Check docs first
- **Tests**: Look at existing tests for examples