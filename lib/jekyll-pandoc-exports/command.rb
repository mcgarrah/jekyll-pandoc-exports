require 'jekyll'

module Jekyll
  module PandocExports
    class Command < Jekyll::Command
      class << self
        def init_with_program(prog)
          prog.command(:export) do |c|
            c.syntax "export [options]"
            c.description "Generate PDF/DOCX exports without a full site build"

            c.option 'format', '--format FORMAT', 'Output format: pdf, docx, both (default: both)'
            c.option 'target', '--target TARGET', 'Target page to export by filename (default: all configured pages)'
            c.option 'dry_run', '--dry-run', 'Print the Pandoc command without executing'
            c.option 'validate', '--validate', 'Validate _data/data.yml schema before export'
            c.option 'output', '-o', '--output DIR', 'Override output directory'
            c.option 'source', '-s', '--source DIR', 'Source directory (default: .)'
            c.option 'config', '--config FILE', 'Configuration file (default: _config.yml)'

            c.action do |args, options|
              ExportRunner.new(args, options).run
            end
          end
        end
      end
    end

    class ExportRunner
      def initialize(args, options)
        @args = args
        @options = options
        @format = (options['format'] || 'both').downcase
        @target = options['target']
        @dry_run = options['dry_run'] || false
        @validate = options['validate'] || false
        @output_dir = options['output']
        @source = options['source'] || '.'
        @config_file = options['config'] || '_config.yml'
      end

      def run
        validate_format!
        validate_schema! if @validate

        config = load_site_config
        export_config = PandocExports.setup_configuration(mock_site(config))

        unless PandocExports.validate_dependencies
          Jekyll.logger.error "Export:", "Missing required dependencies."
          return
        end

        html_files = find_export_targets(config, export_config)

        if html_files.empty?
          Jekyll.logger.warn "Export:", "No export targets found. Run 'jekyll build' first, or check that pages have pdf/docx front matter."
          return
        end

        html_files.each do |target|
          export_file(target, config, export_config)
        end

        Jekyll.logger.info "Export:", "Complete."
      end

      private

      def validate_format!
        unless %w[pdf docx both].include?(@format)
          Jekyll.logger.error "Export:", "Invalid format '#{@format}'. Use: pdf, docx, both"
          exit 1
        end
      end

      def validate_schema!
        Jekyll.logger.info "Export:", "Validating _data/data.yml..."

        data_file = File.join(@source, '_data', 'data.yml')
        unless File.exist?(data_file)
          Jekyll.logger.warn "Export:", "No _data/data.yml found — skipping validation."
          return
        end

        begin
          require 'yaml'
          require 'date'
          data = YAML.load_file(data_file, permitted_classes: [Date])

          errors = []

          # Check required top-level keys
          %w[sidebar career-profile education experiences].each do |key|
            errors << "Missing required section: '#{key}'" unless data.key?(key)
          end

          # Check sidebar required fields
          if data['sidebar']
            %w[name tagline email].each do |field|
              errors << "Missing sidebar.#{field}" unless data['sidebar'][field]
            end
          end

          # Check experiences structure
          if data['experiences'] && data['experiences']['info']
            data['experiences']['info'].each_with_index do |exp, i|
              errors << "Experience ##{i + 1} missing 'role'" unless exp['role']
              errors << "Experience ##{i + 1} missing 'company'" unless exp['company']
              errors << "Experience ##{i + 1} missing 'time'" unless exp['time']
            end
          end

          # Check education structure
          if data['education'] && data['education']['info']
            data['education']['info'].each_with_index do |edu, i|
              errors << "Education ##{i + 1} missing 'degree'" unless edu['degree']
              errors << "Education ##{i + 1} missing 'university'" unless edu['university']
            end
          end

          if errors.any?
            Jekyll.logger.error "Export:", "Schema validation failed:"
            errors.each { |e| Jekyll.logger.error "  ", e }
            exit 1
          else
            Jekyll.logger.info "Export:", "Schema validation passed ✓"
          end
        rescue Psych::SyntaxError => e
          Jekyll.logger.error "Export:", "YAML syntax error: #{e.message}"
          exit 1
        end
      end

      def load_site_config
        config_path = File.join(@source, @config_file)
        unless File.exist?(config_path)
          Jekyll.logger.error "Export:", "Config file not found: #{config_path}"
          exit 1
        end

        Jekyll.configuration({
          'source' => @source,
          'quiet' => true
        })
      end

      def mock_site(config)
        site = Object.new
        site.define_singleton_method(:config) { config }
        site.define_singleton_method(:dest) { config['destination'] }
        site.define_singleton_method(:baseurl) { config['baseurl'] || '' }
        site
      end

      def find_export_targets(config, export_config)
        dest = config['destination']
        unless Dir.exist?(dest)
          Jekyll.logger.error "Export:", "Site destination '#{dest}' not found. Run 'jekyll build' first."
          exit 1
        end

        targets = []

        # Scan for HTML files with pdf/docx front matter markers
        # The simplest approach: look for files that the generator would process
        # by checking the source pages for front matter
        source = config['source']

        Dir.glob(File.join(source, '**', '*.html')).each do |source_file|
          content = File.read(source_file)
          next unless content.start_with?('---')

          # Parse front matter
          if content =~ /\A---\s*\n(.*?)\n---/m
            begin
              front_matter = YAML.safe_load($1) || {}
            rescue
              next
            end

            next unless front_matter['pdf'] || front_matter['docx']

            # Determine the output HTML path
            filename = File.basename(source_file, '.html')

            # Filter by target if specified
            if @target
              next unless filename == @target || source_file.include?(@target)
            end

            # Find the built HTML file
            permalink = front_matter['permalink']
            if permalink
              html_path = File.join(dest, permalink, 'index.html')
              html_path = File.join(dest, "#{permalink.sub(/^\//, '')}.html") unless File.exist?(html_path)
              # Try without trailing slash
              html_path = File.join(dest, permalink, 'index.html') unless File.exist?(html_path)
              # Direct path
              html_path = File.join(dest, "#{permalink.sub(/^\//, '')}index.html") unless File.exist?(html_path)
            else
              html_path = File.join(dest, "#{filename}.html")
              html_path = File.join(dest, filename, 'index.html') unless File.exist?(html_path)
            end

            if File.exist?(html_path)
              targets << {
                filename: filename,
                html_path: html_path,
                front_matter: front_matter
              }
            else
              Jekyll.logger.warn "Export:", "Built HTML not found for #{source_file} (expected: #{html_path})"
            end
          end
        end

        targets
      end

      def export_file(target, config, export_config)
        filename = target[:filename]
        html_path = target[:html_path]
        front_matter = target[:front_matter]

        html_content = File.read(html_path)
        site = mock_site(config)
        processed_html = PandocExports.process_html_content(html_content, site, export_config)

        output_dir = determine_output_dir(config, export_config)
        FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)

        generated_files = []

        if should_generate_docx?(front_matter)
          if @dry_run
            print_dry_run(:docx, processed_html, filename, output_dir, export_config)
          else
            PandocExports.generate_docx(processed_html, filename, output_dir, site, generated_files, export_config)
          end
        end

        if should_generate_pdf?(front_matter)
          if @dry_run
            print_dry_run(:pdf, processed_html, filename, output_dir, export_config)
          else
            mock_page = Object.new
            mock_page.define_singleton_method(:data) { front_matter }
            PandocExports.generate_pdf(processed_html, filename, output_dir, site, generated_files, mock_page, export_config)
          end
        end
      end

      def determine_output_dir(config, export_config)
        if @output_dir
          File.expand_path(@output_dir)
        elsif export_config['output_dir'] && !export_config['output_dir'].empty?
          File.join(config['destination'], export_config['output_dir'])
        else
          config['destination']
        end
      end

      def should_generate_docx?(front_matter)
        return false unless front_matter['docx']
        %w[docx both].include?(@format)
      end

      def should_generate_pdf?(front_matter)
        return false unless front_matter['pdf']
        %w[pdf both].include?(@format)
      end

      def print_dry_run(format, html_content, filename, output_dir, config)
        output_file = File.join(output_dir, "#{filename}.#{format}")

        # Build the equivalent pandoc command
        pandoc_args = ["pandoc"]
        pandoc_args << "--from=html"
        pandoc_args << "--to=#{format == :pdf ? 'pdf' : 'docx'}"
        pandoc_args << "--output=#{output_file}"

        if format == :pdf
          pdf_options = config['pdf_options'] || {}
          pdf_options.each do |key, value|
            pandoc_args << "--#{key}=#{value}"
          end

          pandoc_options = config['pandoc_options'] || {}
          pandoc_options.each do |key, value|
            pandoc_args << "--#{key}=#{value}"
          end
        end

        pandoc_args << "< [stdin: #{html_content.bytesize} bytes HTML]"

        Jekyll.logger.info "Export [DRY RUN]:", pandoc_args.join(" ")
        Jekyll.logger.info "  Input:", "#{html_content.bytesize} bytes of processed HTML"
        Jekyll.logger.info "  Output:", output_file

        if config['unicode_cleanup'] && format == :pdf
          Jekyll.logger.info "  Unicode:", "cleanup enabled (emoji/symbols stripped)"
        end

        cleanup_count = (config['title_cleanup'] || []).length
        if cleanup_count > 0
          Jekyll.logger.info "  Cleanup:", "#{cleanup_count} title_cleanup patterns applied"
        else
          Jekyll.logger.info "  Cleanup:", "none (clean HTML input)"
        end
      end
    end
  end
end
