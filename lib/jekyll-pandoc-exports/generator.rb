require 'pandoc-ruby'

module Jekyll
  module PandocExports
    
    Jekyll::Hooks.register :site, :post_write do |site|
      config = setup_configuration(site)
      return unless config['enabled']
      
      site.pages.each do |page|
        next unless page.data['docx'] || page.data['pdf']
        process_page(site, page, config)
      end
    end
    
    def self.setup_configuration(site)
      config = site.config['pandoc_exports'] || {}
      {
        'enabled' => true,
        'pdf_options' => { 'variable' => 'geometry:margin=1in' },
        'unicode_cleanup' => true,
        'inject_downloads' => true,
        'download_class' => 'pandoc-downloads no-print',
        'download_style' => 'margin: 20px 0; padding: 15px; background-color: #f8f9fa; border: 1px solid #dee2e6; border-radius: 5px;',
        'title_cleanup' => [],
        'image_path_fixes' => []
      }.merge(config)
    end
    
    def self.process_page(site, page, config)
      html_file = get_html_file_path(site, page)
      return unless File.exist?(html_file)
      
      html_content = File.read(html_file)
      processed_html = process_html_content(html_content, site, config)
      filename = File.basename(page.path, '.md')
      generated_files = []
      
      generate_docx(processed_html, filename, site, generated_files) if page.data['docx']
      generate_pdf(processed_html, filename, site, generated_files, page, config) if page.data['pdf']
      
      if config['inject_downloads'] && generated_files.any?
        inject_download_links(html_content, generated_files, html_file, config)
      end
    end
    
    def self.get_html_file_path(site, page)
      # Handle different Jekyll URL structures
      if page.url.end_with?('/')
        File.join(site.dest, page.url, 'index.html')
      else
        File.join(site.dest, "#{page.url.gsub('/', '')}.html")
      end
    end
    
    def self.process_html_content(html_content, site, config)
      processed = html_content.dup
      
      # Apply image path fixes from config
      config['image_path_fixes'].each do |fix|
        processed.gsub!(Regexp.new(fix['pattern']), fix['replacement'].gsub('{{site.dest}}', site.dest))
      end
      
      processed
    end
    
    def self.generate_docx(html_content, filename, site, generated_files)
      begin
        docx_content = PandocRuby.convert(html_content, from: :html, to: :docx)
        docx_file = File.join(site.dest, "#{filename}.docx")
        
        File.open(docx_file, 'wb') { |file| file.write(docx_content) }
        
        generated_files << { 
          type: 'Word Document (.docx)', 
          url: "#{site.baseurl}/#{filename}.docx" 
        }
        Jekyll.logger.info "Pandoc Exports:", "Generated #{filename}.docx"
      rescue => e
        Jekyll.logger.error "Pandoc Exports:", "Failed to generate #{filename}.docx: #{e.message}"
      end
    end
    
    def self.generate_pdf(html_content, filename, site, generated_files, page, config)
      begin
        pdf_html = html_content.dup
        
        # Apply Unicode cleanup if enabled
        if config['unicode_cleanup']
          pdf_html = clean_unicode_characters(pdf_html)
        end
        
        # Apply title cleanup patterns from config
        config['title_cleanup'].each do |pattern|
          pdf_html.gsub!(Regexp.new(pattern), '')
        end
        
        # Get PDF options from config or page front matter
        pdf_options = page.data['pdf_options'] || config['pdf_options']
        
        pdf_content = PandocRuby.new(pdf_html, from: :html, to: :pdf).convert(pdf_options)
        pdf_file = File.join(site.dest, "#{filename}.pdf")
        
        File.open(pdf_file, 'wb') { |file| file.write(pdf_content) }
        
        generated_files << { 
          type: 'PDF Document (.pdf)', 
          url: "#{site.baseurl}/#{filename}.pdf" 
        }
        Jekyll.logger.info "Pandoc Exports:", "Generated #{filename}.pdf"
      rescue => e
        Jekyll.logger.error "Pandoc Exports:", "Failed to generate #{filename}.pdf: #{e.message}"
      end
    end
    
    def self.clean_unicode_characters(html)
      # Remove emoji and symbol ranges that cause LaTeX issues
      html.gsub(/[\u{1F000}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]/, '')
    end
    
    def self.inject_download_links(html_content, generated_files, html_file, config)
      download_html = build_download_html(generated_files, config)
      
      # Insert after first heading or at beginning of body
      if html_content.match(/<h[1-6][^>]*>/)
        html_content.sub!(/<\/h[1-6]>/, "\\&\n#{download_html}")
      else
        html_content.sub!(/<body[^>]*>/, "\\&\n#{download_html}")
      end
      
      File.write(html_file, html_content)
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
  end
end