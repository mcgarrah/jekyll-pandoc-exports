require 'minitest/autorun'
require 'jekyll'
require_relative '../lib/jekyll-pandoc-exports/generator'

class TestConfiguration < Minitest::Test
  def test_setup_configuration_advanced_defaults
    site = mock_site
    config = Jekyll::PandocExports.setup_configuration(site)
    
    assert_equal false, config['debug']
    assert_equal 10_000_000, config['max_file_size']
    assert_equal false, config['strict_size_limit']
    assert_equal false, config['performance_monitoring']
    assert_equal({}, config['pandoc_options'])
    
    template = config['template']
    assert_equal '', template['header']
    assert_equal '', template['footer']
    assert_equal '', template['css']
  end
  
  def test_setup_configuration_advanced_overrides
    site_config = {
      'pandoc_exports' => {
        'debug' => true,
        'max_file_size' => 5_000_000,
        'performance_monitoring' => true,
        'template' => {
          'header' => '<div>Custom Header</div>',
          'css' => 'body { margin: 0; }'
        },
        'pandoc_options' => { 'toc' => true }
      }
    }
    site = mock_site(site_config)
    config = Jekyll::PandocExports.setup_configuration(site)
    
    assert_equal true, config['debug']
    assert_equal 5_000_000, config['max_file_size']
    assert_equal true, config['performance_monitoring']
    assert_equal({ 'toc' => true }, config['pandoc_options'])
    
    template = config['template']
    assert_equal '<div>Custom Header</div>', template['header']
    assert_equal 'body { margin: 0; }', template['css']
    # Footer should be empty string (default) when not specified
    assert template['footer'].nil? || template['footer'] == '', "Expected footer to be nil or empty, got: #{template['footer'].inspect}"
  end
  
  def test_template_configuration_partial_override
    site_config = {
      'pandoc_exports' => {
        'template' => {
          'header' => '<header>Only Header</header>'
        }
      }
    }
    site = mock_site(site_config)
    config = Jekyll::PandocExports.setup_configuration(site)
    
    template = config['template']
    assert_equal '<header>Only Header</header>', template['header']
    # Footer and CSS should be empty string or nil (defaults)
    assert template['footer'].nil? || template['footer'] == '', "Expected footer to be nil or empty, got: #{template['footer'].inspect}"
    assert template['css'].nil? || template['css'] == '', "Expected css to be nil or empty, got: #{template['css'].inspect}"
  end
  
  private
  
  def mock_site(config = {})
    site = Object.new
    def site.config; @config ||= {}; end
    site.config.merge!(config)
    site
  end
end