require_relative 'test_helper'

class TestGenerator < Minitest::Test
  def test_setup_configuration_defaults
    config = Jekyll::PandocExports.setup_configuration(mock_site)
    
    assert_equal true, config['enabled']
    assert_equal '', config['output_dir']
    assert_equal ['pages', 'posts'], config['collections']
    assert_equal true, config['unicode_cleanup']
    assert_equal true, config['inject_downloads']
  end
  
  def test_setup_configuration_merge
    site_config = { 'pandoc_exports' => { 'enabled' => false, 'output_dir' => 'exports' } }
    site = mock_site(site_config)
    config = Jekyll::PandocExports.setup_configuration(site)
    
    assert_equal false, config['enabled']
    assert_equal 'exports', config['output_dir']
    assert_equal ['pages', 'posts'], config['collections'] # default preserved
  end
  
  def test_validate_dependencies_pandoc_missing
    Jekyll::PandocExports.stub :system, false do
      refute Jekyll::PandocExports.validate_dependencies
    end
  end
  
  def test_get_output_filename_page
    page = mock_page('/test-page.md')
    filename = Jekyll::PandocExports.get_output_filename(page)
    assert_equal 'test-page', filename
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
    
    Dir.mktmpdir do |tmpdir|
      site.config['destination'] = tmpdir
      dir = Jekyll::PandocExports.get_output_directory(site, config)
      expected = File.join(tmpdir, 'downloads')
      assert_equal expected, dir
      assert Dir.exist?(expected)
    end
  end
  
  def test_skip_unchanged_file_no_incremental
    config = { 'incremental' => false }
    item = mock_page('/test.md')
    
    refute Jekyll::PandocExports.skip_unchanged_file?(mock_site, item, config)
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
  
  def test_clean_unicode_characters
    html = 'Test 🚀 content with 📝 emojis'
    result = Jekyll::PandocExports.clean_unicode_characters(html)
    assert_equal 'Test  content with  emojis', result
  end
  
  private
  
  def mock_site(config = {})
    site = Minitest::Mock.new
    site.expect :config, config
    site.expect :dest, '/tmp/site'
    site
  end
  
  def mock_page(path)
    page = Minitest::Mock.new
    page.expect :path, path
    page.expect :respond_to?, true, [:path]
    page
  end
end