require 'minitest/autorun'

# Load only the template functionality for testing
module Jekyll
  module PandocExports
    def self.apply_template(html_content, config)
      template = config['template']
      return html_content if template['header'].empty? && template['footer'].empty? && template['css'].empty?
      
      # Add custom CSS
      if !template['css'].empty?
        css_tag = "<style>#{template['css']}</style>"
        html_content = html_content.sub(/<\/head>/, "#{css_tag}\n</head>")
      end
      
      # Add header after body tag
      if !template['header'].empty?
        html_content = html_content.sub(/<body[^>]*>/, "\\&\n#{template['header']}")
      end
      
      # Add footer before closing body tag
      if !template['footer'].empty?
        html_content = html_content.sub(/<\/body>/, "#{template['footer']}\n</body>")
      end
      
      html_content
    end
  end
end

class TestTemplate < Minitest::Test
  def test_apply_template_empty_config
    html = '<html><head></head><body>Content</body></html>'
    config = { 'template' => { 'header' => '', 'footer' => '', 'css' => '' } }
    
    result = Jekyll::PandocExports.apply_template(html, config)
    assert_equal html, result
  end
  
  def test_apply_template_css_injection
    html = '<html><head></head><body>Content</body></html>'
    config = { 'template' => { 'header' => '', 'footer' => '', 'css' => '.test { color: red; }' } }
    
    result = Jekyll::PandocExports.apply_template(html, config)
    assert_includes result, '<style>.test { color: red; }</style>'
    assert_includes result, '</head>'
  end
  
  def test_apply_template_header_injection
    html = '<html><head></head><body>Content</body></html>'
    config = { 'template' => { 'header' => '<div class="header">Header</div>', 'footer' => '', 'css' => '' } }
    
    result = Jekyll::PandocExports.apply_template(html, config)
    assert_includes result, '<div class="header">Header</div>'
  end
  
  def test_apply_template_footer_injection
    html = '<html><head></head><body>Content</body></html>'
    config = { 'template' => { 'header' => '', 'footer' => '<div class="footer">Footer</div>', 'css' => '' } }
    
    result = Jekyll::PandocExports.apply_template(html, config)
    assert_includes result, '<div class="footer">Footer</div>'
  end
  
  def test_apply_template_all_elements
    html = '<html><head></head><body>Content</body></html>'
    config = { 
      'template' => { 
        'header' => '<header>Top</header>', 
        'footer' => '<footer>Bottom</footer>', 
        'css' => 'body { margin: 0; }' 
      } 
    }
    
    result = Jekyll::PandocExports.apply_template(html, config)
    assert_includes result, '<style>body { margin: 0; }</style>'
    assert_includes result, '<header>Top</header>'
    assert_includes result, '<footer>Bottom</footer>'
  end
end