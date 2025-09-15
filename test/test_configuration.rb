require 'minitest/autorun'

# Load configuration functionality for testing
module Jekyll
  module PandocExports
    def self.setup_configuration(site)
      config = site.config['pandoc_exports'] || {}
      {
        'enabled' => true,
        'output_dir' => '',
        'collections' => ['pages', 'posts'],
        'pdf_options' => { 'variable' => 'geometry:margin=1in' },
        'unicode_cleanup' => true,
        'inject_downloads' => true,
        'download_class' => 'pandoc-downloads no-print',
        'download_style' => 'margin: 20px 0; padding: 15px; background-color: #f8f9fa; border: 1px solid #dee2e6; border-radius: 5px;',
        'title_cleanup' => [],
        'image_path_fixes' => [],
        'debug' => false,
        'max_file_size' => 10_000_000,
        'strict_size_limit' => false,
        'performance_monitoring' => false,
        'template' => {
          'header' => '',
          'footer' => '',
          'css' => ''
        },
        'pandoc_options' => {}
      }.merge(config) do |key, old_val, new_val|
        if key == 'template' && old_val.is_a?(Hash) && new_val.is_a?(Hash)
          old_val.merge(new_val)
        else
          new_val
        end
      end
    end
  end
end

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
    assert_equal '', template['footer']  # Should preserve default for unspecified
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
    assert_equal '', template['footer']
    assert_equal '', template['css']
  end
  
  private
  
  def mock_site(config = {})
    site = Object.new
    def site.config; @config ||= {}; end
    site.config.merge!(config)
    site
  end
end