require 'minitest/autorun'
require 'jekyll'
require_relative '../lib/jekyll-pandoc-exports/generator'

# Mock PandocRuby if not already defined
unless defined?(PandocRuby)
  module PandocRuby
    def self.convert(content, options = {})
      "mock_#{options[:to]}_content"
    end
  end
end

class TestUnit < Minitest::Test
  def test_setup_configuration_defaults
    site = mock_site
    config = Jekyll::PandocExports.setup_configuration(site)
    
    assert_equal true, config['enabled']
    assert_equal '', config['output_dir']
    assert_equal ['pages', 'posts'], config['collections']
    assert_equal true, config['unicode_cleanup']
  end
  
  def test_setup_configuration_merge
    site_config = { 'pandoc_exports' => { 'enabled' => false, 'output_dir' => 'exports' } }
    site = mock_site(site_config)
    config = Jekyll::PandocExports.setup_configuration(site)
    
    assert_equal false, config['enabled']
    assert_equal 'exports', config['output_dir']
  end
  
  def test_setup_configuration_advanced_options
    site = mock_site
    config = Jekyll::PandocExports.setup_configuration(site)
    
    # Test advanced configuration defaults
    assert_equal false, config['debug']
    assert_equal 10_000_000, config['max_file_size']
    assert_equal false, config['strict_size_limit']
    assert_equal false, config['performance_monitoring']
    assert_equal({}, config['pandoc_options'])
    
    # Test template defaults
    template = config['template']
    assert_equal '', template['header']
    assert_equal '', template['footer']
    assert_equal '', template['css']
  end
  
  def test_setup_configuration_template_merge
    site_config = {
      'pandoc_exports' => {
        'debug' => true,
        'template' => {
          'header' => '<div>Custom Header</div>',
          'css' => 'body { margin: 0; }'
        }
      }
    }
    site = mock_site(site_config)
    config = Jekyll::PandocExports.setup_configuration(site)
    
    assert_equal true, config['debug']
    
    template = config['template']
    assert_equal '<div>Custom Header</div>', template['header']
    assert_equal 'body { margin: 0; }', template['css']
    # Footer should be empty string (default) when not specified
    assert template['footer'].nil? || template['footer'] == '', "Expected footer to be nil or empty, got: #{template['footer'].inspect}"
  end
  
  def test_get_output_filename
    item = Struct.new(:path).new('/test-page.md')
    filename = Jekyll::PandocExports.get_output_filename(item)
    assert_equal 'test-page', filename
  end
  
  def test_clean_unicode_characters
    html = 'Test 🚀 content with 📝 emojis'
    result = Jekyll::PandocExports.clean_unicode_characters(html)
    assert_equal 'Test  content with  emojis', result
  end
  
  def test_process_html_content_image_fixes
    html = '<img src="/assets/images/test.jpg">'
    site = mock_site
    config = {
      'template' => { 'header' => '', 'footer' => '', 'css' => '' },
      'image_path_fixes' => [
        { 'pattern' => 'src="/assets/images/', 'replacement' => 'src="{{site.dest}}/assets/images/' }
      ]
    }
    
    result = Jekyll::PandocExports.process_html_content(html, site, config)
    assert_includes result, 'src="/tmp/site/assets/images/'
  end
  
  def test_get_output_directory_default
    site = mock_site
    config = { 'output_dir' => '' }
    
    dir = Jekyll::PandocExports.get_output_directory(site, config)
    assert_equal '/tmp/site', dir
  end
  
  def test_get_output_directory_custom
    site = mock_site
    config = { 'output_dir' => 'downloads' }
    
    dir = Jekyll::PandocExports.get_output_directory(site, config)
    assert_equal '/tmp/site/downloads', dir
  end
  
  def test_skip_unchanged_file_no_incremental
    config = { 'incremental' => false }
    item = Struct.new(:path).new('/test.md')
    site = mock_site
    
    refute Jekyll::PandocExports.skip_unchanged_file?(site, item, config)
  end
  
  def test_skip_unchanged_file_incremental_no_source
    config = { 'incremental' => true }
    item = Struct.new(:path).new('/nonexistent.md')
    site = mock_site
    
    refute Jekyll::PandocExports.skip_unchanged_file?(site, item, config)
  end
  
  def test_validate_content_size_within_limit
    html_content = 'Small content'
    config = { 'max_file_size' => 10_000_000 }
    
    assert Jekyll::PandocExports.validate_content_size(html_content, config)
  end
  
  def test_validate_content_size_exceeds_limit_non_strict
    html_content = 'x' * 100  # 100 bytes
    config = { 'max_file_size' => 50, 'strict_size_limit' => false }
    
    # Should return true but log warning (non-strict mode)
    assert Jekyll::PandocExports.validate_content_size(html_content, config)
  end
  
  def test_validate_content_size_exceeds_limit_strict
    html_content = 'x' * 100  # 100 bytes
    config = { 'max_file_size' => 50, 'strict_size_limit' => true }
    
    # Should return false in strict mode
    refute Jekyll::PandocExports.validate_content_size(html_content, config)
  end
  
  private
  
  def mock_site(config = {})
    site = Object.new
    def site.config; @config ||= {}; end
    def site.dest; '/tmp/site'; end
    site.config.merge!(config)
    site
  end
end