require 'minitest/autorun'
require 'jekyll'
require_relative '../lib/jekyll-pandoc-exports/generator'

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