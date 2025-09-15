require 'minitest/autorun'
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
  
  def test_skip_unchanged_file_no_incremental
    config = { 'incremental' => false }
    item = Struct.new(:path).new('/test.md')
    site = mock_site
    
    refute Jekyll::PandocExports.skip_unchanged_file?(site, item, config)
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