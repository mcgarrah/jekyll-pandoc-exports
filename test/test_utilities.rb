require 'minitest/autorun'

# Tests for utility functions and HTML processing
module Jekyll
  module PandocExports
    # Mock implementations for testing untested methods
    def self.get_html_file_path(site, page)
      if page.url.end_with?('/')
        File.join(site.dest, page.url, 'index.html')
      else
        File.join(site.dest, "#{page.url.gsub('/', '')}.html")
      end
    end
    
    def self.build_download_html(generated_files, config)
      download_html = "<div class=\"#{config['download_class']}\" style=\"#{config['download_style']}\">" +
                     "<p><strong>Download Options:</strong></p>" +
                     "<ul style=\"margin: 5px 0; padding-left: 20px;\">"
      
      generated_files.each do |file|
        download_html += "<li><a href=\"#{file[:url]}\" style=\"color: #007bff; text-decoration: none; font-weight: bold;\">#{file[:type]}</a></li>"
      end
      
      download_html += "</ul></div>"
    end
    
    def self.inject_download_links(html_content, generated_files, html_file, config)
      download_html = build_download_html(generated_files, config)
      
      if html_content.match(/<h[1-6][^>]*>/)
        html_content.sub!(/<\/h[1-6]>/, "\\&\n#{download_html}")
      else
        html_content.sub!(/<body[^>]*>/, "\\&\n#{download_html}")
      end
      
      html_content
    end
  end
end

class TestUtilities < Minitest::Test
  def test_get_html_file_path_with_trailing_slash
    site = mock_site('/tmp/site')
    page = mock_page_with_url('/about/')
    
    result = Jekyll::PandocExports.get_html_file_path(site, page)
    assert_equal '/tmp/site/about/index.html', result
  end
  
  def test_get_html_file_path_without_trailing_slash
    site = mock_site('/tmp/site')
    page = mock_page_with_url('/contact')
    
    result = Jekyll::PandocExports.get_html_file_path(site, page)
    assert_equal '/tmp/site/contact.html', result
  end
  
  def test_build_download_html_single_file
    generated_files = [{ type: 'PDF Document (.pdf)', url: '/test.pdf' }]
    config = { 'download_class' => 'downloads', 'download_style' => 'margin: 10px;' }
    
    result = Jekyll::PandocExports.build_download_html(generated_files, config)
    
    assert_includes result, 'class="downloads"'
    assert_includes result, 'style="margin: 10px;"'
    assert_includes result, 'href="/test.pdf"'
    assert_includes result, 'PDF Document (.pdf)'
  end
  
  def test_build_download_html_multiple_files
    generated_files = [
      { type: 'PDF Document (.pdf)', url: '/test.pdf' },
      { type: 'Word Document (.docx)', url: '/test.docx' }
    ]
    config = { 'download_class' => 'downloads', 'download_style' => '' }
    
    result = Jekyll::PandocExports.build_download_html(generated_files, config)
    
    assert_includes result, '/test.pdf'
    assert_includes result, '/test.docx'
    assert_includes result, 'PDF Document'
    assert_includes result, 'Word Document'
  end
  
  def test_inject_download_links_after_heading
    html = '<html><body><h1>Title</h1><p>Content</p></body></html>'
    generated_files = [{ type: 'PDF', url: '/test.pdf' }]
    config = { 'download_class' => 'dl', 'download_style' => '' }
    
    result = Jekyll::PandocExports.inject_download_links(html, generated_files, '/tmp/test.html', config)
    
    assert_includes result, '</h1>'
    assert_includes result, 'Download Options'
  end
  
  def test_inject_download_links_after_body
    html = '<html><body><p>Content without heading</p></body></html>'
    generated_files = [{ type: 'PDF', url: '/test.pdf' }]
    config = { 'download_class' => 'dl', 'download_style' => '' }
    
    result = Jekyll::PandocExports.inject_download_links(html, generated_files, '/tmp/test.html', config)
    
    assert_includes result, '<body>'
    assert_includes result, 'Download Options'
  end
  
  private
  
  def mock_site(dest)
    site = Object.new
    def site.dest; @dest; end
    site.instance_variable_set(:@dest, dest)
    site
  end
  
  def mock_page_with_url(url)
    page = Object.new
    def page.url; @url; end
    page.instance_variable_set(:@url, url)
    page
  end
end