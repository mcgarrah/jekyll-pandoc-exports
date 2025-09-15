require 'pandoc-ruby'
require_relative 'hooks'
require_relative 'statistics'

module Jekyll
  module PandocExports
    
    Jekyll::Hooks.register :site, :post_write do |site|
      config = setup_configuration(site)
      return unless config['enabled']
      
      unless validate_dependencies
        Jekyll.logger.error "Pandoc Exports:", "Missing required dependencies. Please install Pandoc and LaTeX."
        return
      end
      
      @stats = Statistics.new
      process_collections(site, config)
      @stats.print_summary(config)
    end
    
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
      }.merge(config)
    end
    
    def self.validate_dependencies
      pandoc_available = system('pandoc --version > /dev/null 2>&1')
      latex_available = system('pdflatex --version > /dev/null 2>&1')
      
      unless pandoc_available
        Jekyll.logger.warn "Pandoc Exports:", "Pandoc not found. Install with: brew install pandoc (macOS) or apt-get install pandoc (Ubuntu)"
      end
      
      unless latex_available
        Jekyll.logger.warn "Pandoc Exports:", "LaTeX not found. Install with: brew install --cask mactex (macOS) or apt-get install texlive-latex-base (Ubuntu)"
      end
      
      pandoc_available
    end
    
    def self.process_collections(site, config)
      config['collections'].each do |collection_name|
        case collection_name
        when 'pages'
          site.pages.each { |item| process_item(site, item, config) }
        when 'posts'
          site.posts.docs.each { |item| process_item(site, item, config) }
        else
          collection = site.collections[collection_name]
          collection&.docs&.each { |item| process_item(site, item, config) }
        end
      end
    end
    
    def self.process_item(site, item, config)
      return unless item.data['docx'] || item.data['pdf']
      
      # Check if file was modified (incremental build)
      return if skip_unchanged_file?(site, item, config)
      
      process_page(site, item, config)
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
    
    def self.process_page(site, page, config)
      @stats&.record_processing_start
      @stats&.record_file_processed
      
      html_file = get_html_file_path(site, page)
      return unless File.exist?(html_file)
      
      html_content = File.read(html_file)
      processed_html = process_html_content(html_content, site, config)
      filename = get_output_filename(page)
      output_dir = get_output_directory(site, config)
      generated_files = []
      
      generate_docx(processed_html, filename, output_dir, site, generated_files, config) if page.data['docx']
      generate_pdf(processed_html, filename, output_dir, site, generated_files, page, config) if page.data['pdf']
      
      if config['inject_downloads'] && generated_files.any?
        inject_download_links(html_content, generated_files, html_file, config)
      end
      
      @stats&.record_processing_end
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
      
      # Apply template customizations
      processed = apply_template(processed, config)
      
      # Apply image path fixes from config
      config['image_path_fixes'].each do |fix|
        processed.gsub!(Regexp.new(fix['pattern']), fix['replacement'].gsub('{{site.dest}}', site.dest))
      end
      
      processed
    end
    
    def self.apply_template(html_content, config)
      template = config['template']
      return html_content if template['header'].empty? && template['footer'].empty? && template['css'].empty?
      
      # Add custom CSS
      if !template['css'].empty?
        css_tag = "<style>#{template['css']}</style>"
        html_content = html_content.sub(/<\/head>/, "#{css_tag}\n</head>")
      end
      
      # Add header after body tag
      if !template['header'].empty?
        html_content = html_content.sub(/<body[^>]*>/, "\&\n#{template['header']}")
      end
      
      # Add footer before closing body tag
      if !template['footer'].empty?
        html_content = html_content.sub(/<\/body>/, "#{template['footer']}\n</body>")
      end
      
      html_content
    end
    
    def self.generate_docx(html_content, filename, output_dir, site, generated_files, config = {})
      return unless validate_content_size(html_content, config)
      
      begin
        # Run pre-conversion hooks
        processed_html = Hooks.run_pre_conversion_hooks(html_content, config, { format: :docx, filename: filename })
        
        docx_content = PandocRuby.convert(processed_html, from: :html, to: :docx)
        
        # Run post-conversion hooks
        docx_content = Hooks.run_post_conversion_hooks(docx_content, :docx, config, { filename: filename })
        docx_file = File.join(output_dir, "#{filename}.docx")
        
        File.open(docx_file, 'wb') { |file| file.write(docx_content) }
        
        generated_files << { 
          type: 'Word Document (.docx)', 
          url: "#{site.baseurl}/#{filename}.docx" 
        }
        @stats&.record_conversion_success(:docx)
        log_message(config, "Generated #{filename}.docx")
      rescue => e
        @stats&.record_conversion_failure(:docx, e)
        log_error(config, "Failed to generate #{filename}.docx: #{e.message}")
      end
    end
    
    def self.generate_pdf(html_content, filename, output_dir, site, generated_files, page, config)
      return unless validate_content_size(html_content, config)
      
      begin
        # Run pre-conversion hooks
        processed_html = Hooks.run_pre_conversion_hooks(html_content, config, { format: :pdf, filename: filename })
        
        pdf_html = processed_html.dup
        
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
        
        # Merge custom pandoc options
        all_options = pdf_options.merge(config['pandoc_options'])
        pdf_content = PandocRuby.new(pdf_html, from: :html, to: :pdf).convert(all_options)
        
        # Run post-conversion hooks
        pdf_content = Hooks.run_post_conversion_hooks(pdf_content, :pdf, config, { filename: filename })
        pdf_file = File.join(output_dir, "#{filename}.pdf")
        
        File.open(pdf_file, 'wb') { |file| file.write(pdf_content) }
        
        generated_files << { 
          type: 'PDF Document (.pdf)', 
          url: "#{site.baseurl}/#{filename}.pdf" 
        }
        @stats&.record_conversion_success(:pdf)
        log_message(config, "Generated #{filename}.pdf")
      rescue => e
        @stats&.record_conversion_failure(:pdf, e)
        log_error(config, "Failed to generate #{filename}.pdf: #{e.message}")
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
    
    def self.log_message(config, message)
      if config['debug']
        Jekyll.logger.info "Pandoc Exports [DEBUG]:", message
      else
        Jekyll.logger.info "Pandoc Exports:", message
      end
    end
    
    def self.log_error(config, message)
      Jekyll.logger.error "Pandoc Exports:", message
    end
    
    def self.validate_content_size(html_content, config)
      max_size = config['max_file_size'] || 10_000_000 # 10MB default
      
      if html_content.bytesize > max_size
        Jekyll.logger.warn "Pandoc Exports:", "Content size (#{html_content.bytesize} bytes) exceeds recommended limit (#{max_size} bytes)"
        return false if config['strict_size_limit']
      end
      
      true
    end
  end
end