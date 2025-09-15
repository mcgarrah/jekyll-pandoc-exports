# Hooks System

The Jekyll Pandoc Exports plugin provides a powerful hooks system for extending functionality with custom processing workflows.

## Overview

Hooks allow you to:

- **Modify content** before conversion (pre-conversion hooks)
- **Process output** after conversion (post-conversion hooks)
- **Add custom logic** for specific formats or files
- **Integrate** with other Jekyll plugins or external services

## Hook Types

### Pre-Conversion Hooks

Execute before Pandoc conversion, allowing you to modify HTML content:

```ruby
Jekyll::PandocExports::Hooks.register_pre_conversion do |html_content, config, context|
  # Modify HTML before conversion
  html_content.gsub('old-class', 'new-class')
end
```

### Post-Conversion Hooks

Execute after Pandoc conversion, allowing you to process the generated output:

```ruby
Jekyll::PandocExports::Hooks.register_post_conversion do |content, format, config, context|
  # Process converted content
  if format == :pdf
    # Custom PDF post-processing
  end
  content
end
```

## Hook Context

Hooks receive context information about the current conversion:

```ruby
context = {
  format: :pdf,           # Output format (:docx or :pdf)
  filename: 'my-page',    # Base filename being processed
  # Additional context may be added in future versions
}
```

## Examples

### Content Modification

Replace custom shortcodes before conversion:

```ruby
Jekyll::PandocExports::Hooks.register_pre_conversion do |html_content, config, context|
  # Replace custom shortcodes
  html_content.gsub(/\{\{note\}\}(.*?)\{\{\/note\}\}/m) do |match|
    content = $1
    "<div class=\"note\">#{content}</div>"
  end
end
```

### Format-Specific Processing

Apply different processing based on output format:

```ruby
Jekyll::PandocExports::Hooks.register_pre_conversion do |html_content, config, context|
  case context[:format]
  when :pdf
    # PDF-specific modifications
    html_content.gsub('<div class="web-only">', '<div style="display:none;">')
  when :docx
    # DOCX-specific modifications
    html_content.gsub('<code>', '<span style="font-family:monospace;">')
  else
    html_content
  end
end
```

### External Service Integration

Send notifications or update external systems:

```ruby
Jekyll::PandocExports::Hooks.register_post_conversion do |content, format, config, context|
  # Log conversion to external service
  if config['notify_webhook']
    require 'net/http'
    uri = URI(config['notify_webhook'])
    Net::HTTP.post_form(uri, {
      'filename' => context[:filename],
      'format' => format.to_s,
      'size' => content.bytesize
    })
  end
  
  content
end
```

### Content Analytics

Track conversion statistics:

```ruby
Jekyll::PandocExports::Hooks.register_post_conversion do |content, format, config, context|
  # Track conversion metrics
  File.open('conversion_log.txt', 'a') do |f|
    f.puts "#{Time.now}: #{context[:filename]}.#{format} (#{content.bytesize} bytes)"
  end
  
  content
end
```

## Hook Chaining

Multiple hooks can be registered and will execute in registration order:

```ruby
# First hook
Jekyll::PandocExports::Hooks.register_pre_conversion do |html, config, context|
  html.gsub('step1', 'modified1')
end

# Second hook (receives output from first)
Jekyll::PandocExports::Hooks.register_pre_conversion do |html, config, context|
  html.gsub('modified1', 'final')
end
```

## Plugin Integration

### Jekyll SEO Tag Integration

```ruby
Jekyll::PandocExports::Hooks.register_pre_conversion do |html_content, config, context|
  # Remove SEO meta tags that don't belong in exports
  html_content.gsub(/<meta[^>]*property="og:[^"]*"[^>]*>/, '')
              .gsub(/<meta[^>]*name="twitter:[^"]*"[^>]*>/, '')
end
```

### Jekyll Feed Integration

```ruby
Jekyll::PandocExports::Hooks.register_pre_conversion do |html_content, config, context|
  # Add feed information to exports
  if context[:filename].start_with?('post-')
    feed_info = '<div class="feed-info">Also available in our <a href="/feed.xml">RSS feed</a></div>'
    html_content.sub(/<\/h1>/, "\\&\n#{feed_info}")
  else
    html_content
  end
end
```

## Configuration Integration

Access plugin configuration in hooks:

```ruby
Jekyll::PandocExports::Hooks.register_pre_conversion do |html_content, config, context|
  # Use custom configuration
  if config['custom_watermark']
    watermark = "<div class=\"watermark\">#{config['custom_watermark']}</div>"
    html_content.sub(/<body[^>]*>/, "\\&\n#{watermark}")
  else
    html_content
  end
end
```

Add custom configuration:

```yaml
# _config.yml
pandoc_exports:
  custom_watermark: "CONFIDENTIAL"
  notify_webhook: "https://api.example.com/notify"
```

## Error Handling

Handle errors gracefully in hooks:

```ruby
Jekyll::PandocExports::Hooks.register_pre_conversion do |html_content, config, context|
  begin
    # Risky operation
    html_content.gsub(/complex_regex/) { |match| process_match(match) }
  rescue => e
    Jekyll.logger.warn "Hook error: #{e.message}"
    html_content  # Return original content on error
  end
end
```

## Performance Considerations

- **Keep hooks fast**: Avoid expensive operations
- **Cache results**: Store computed values when possible
- **Conditional execution**: Use context to skip unnecessary work

```ruby
Jekyll::PandocExports::Hooks.register_pre_conversion do |html_content, config, context|
  # Skip processing for small files
  return html_content if html_content.length < 1000
  
  # Only process PDF exports
  return html_content unless context[:format] == :pdf
  
  # Expensive processing here
  process_large_pdf_content(html_content)
end
```

## Testing Hooks

Test hooks in isolation:

```ruby
# test/test_my_hooks.rb
require 'minitest/autorun'

class TestMyHooks < Minitest::Test
  def setup
    Jekyll::PandocExports::Hooks.clear_hooks
  end
  
  def test_custom_hook
    Jekyll::PandocExports::Hooks.register_pre_conversion do |html, config, context|
      html.gsub('test', 'modified')
    end
    
    result = Jekyll::PandocExports::Hooks.run_pre_conversion_hooks(
      'test content', 
      {}, 
      { format: :pdf }
    )
    
    assert_equal 'modified content', result
  end
end
```

## Best Practices

1. **Return modified content**: Always return the processed content
2. **Handle nil gracefully**: Check for nil inputs
3. **Use context wisely**: Leverage format and filename information
4. **Document your hooks**: Comment complex processing logic
5. **Test thoroughly**: Verify hooks work with different content types