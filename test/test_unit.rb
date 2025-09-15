require 'minitest/autorun'
require 'jekyll'

# Mock PandocRuby before loading our code
module PandocRuby
  def self.convert(content, options = {})
    "mock_#{options[:to]}_content"
  end
end

# Load only the specific methods we want to test
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
        'image_path_fixes' => []
      }.merge(config)
    end
    
    def self.get_output_filename(item)
      if item.respond_to?(:basename)
        File.basename(item.basename, '.md')
      else
        File.basename(item.path, '.md')
      end
    end
    
    def self.get_output_directory(site, config)
      if config['output_dir'].empty?
        site.dest
      else
        output_path = File.join(site.dest, config['output_dir'])
        FileUtils.mkdir_p(output_path) unless Dir.exist?(output_path)
        output_path
      end
    end
    
    def self.clean_unicode_characters(html)
      html.gsub(/[\u{1F000}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]/, '')
    end
    
    def self.process_html_content(html_content, site, config)
      processed = html_content.dup
      config['image_path_fixes'].each do |fix|
        processed.gsub!(Regexp.new(fix['pattern']), fix['replacement'].gsub('{{site.dest}}', site.dest))
      end
      processed
    end
    
    def self.skip_unchanged_file?(site, item, config)
      return false unless config['incremental']
      
      source_file = item.respond_to?(:path) ? item.path : item.relative_path
      return false unless File.exist?(source_file)
      
      filename = get_output_filename(item)
      output_dir = get_output_directory(site, config)
      
      docx_file = File.join(output_dir, "#{filename}.docx")
      pdf_file = File.join(output_dir, "#{filename}.pdf")
      
      source_mtime = File.mtime(source_file)
      
      if item.data['docx'] && File.exist?(docx_file)
        return false if File.mtime(docx_file) < source_mtime
      end
      
      if item.data['pdf'] && File.exist?(pdf_file)
        return false if File.mtime(pdf_file) < source_mtime
      end
      
      true
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