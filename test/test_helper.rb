require 'minitest/autorun'
require 'jekyll'
require 'tmpdir'
require 'fileutils'

# Load the plugin
require_relative '../lib/jekyll-pandoc-exports'

class TestHelper
  def self.create_test_site(config = {})
    Dir.mktmpdir do |tmpdir|
      site_config = {
        'source' => tmpdir,
        'destination' => File.join(tmpdir, '_site'),
        'pandoc_exports' => config
      }
      
      site = Jekyll::Site.new(Jekyll.configuration(site_config))
      
      # Create basic site structure
      FileUtils.mkdir_p(File.join(tmpdir, '_posts'))
      FileUtils.mkdir_p(File.join(tmpdir, '_portfolio'))
      
      yield site, tmpdir
    end
  end
  
  def self.create_test_page(site, path, front_matter = {}, content = 'Test content')
    page_path = File.join(site.source, path)
    FileUtils.mkdir_p(File.dirname(page_path))
    
    File.write(page_path, "---\n#{front_matter.to_yaml}---\n#{content}")
    
    page = Jekyll::Page.new(site, site.source, File.dirname(path), File.basename(path))
    page.read_yaml(File.dirname(page_path), File.basename(page_path))
    site.pages << page
    page
  end
end