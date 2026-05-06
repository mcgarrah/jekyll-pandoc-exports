require 'minitest/autorun'
require 'tmpdir'
require 'yaml'
require 'date'
require 'fileutils'

# Isolated test for the ExportRunner class.
# We define minimal Jekyll stubs ONLY if Jekyll isn't already loaded
# (i.e., when running this file standalone). When run via `bundle exec rake test`,
# the real Jekyll is available and command.rb loads normally.

unless defined?(Jekyll::Command)
  module Jekyll
    class Logger
      def info(topic, msg = nil); end
      def warn(topic, msg = nil); end
      def error(topic, msg = nil); end
    end

    def self.logger
      @logger ||= Logger.new
    end

    class Command
      class << self
        def init_with_program(prog); end
      end
    end

    def self.configuration(opts = {})
      {
        'source' => opts['source'] || '.',
        'destination' => opts['destination'] || '_site',
        'baseurl' => '',
        'quiet' => true
      }
    end
  end
end

# Define PandocExports stubs only if not already loaded
unless defined?(Jekyll::PandocExports::ExportRunner)
  module Jekyll
    module PandocExports
      # Only define these if the real module hasn't loaded them
      unless method_defined?(:setup_configuration)
        def self.setup_configuration(site)
          config = (site.respond_to?(:config) ? site.config : {})['pandoc_exports'] || {}
          {
            'enabled' => true,
            'output_dir' => '',
            'collections' => ['pages', 'posts'],
            'pdf_options' => { 'variable' => 'geometry:margin=1in' },
            'unicode_cleanup' => true,
            'inject_downloads' => true,
            'title_cleanup' => [],
            'image_path_fixes' => [],
            'template' => { 'header' => '', 'footer' => '', 'css' => '' },
            'pandoc_options' => {},
            'performance_monitoring' => false
          }.merge(config)
        end
      end

      unless method_defined?(:validate_dependencies)
        def self.validate_dependencies
          true
        end
      end
    end
  end

  # Load the command file
  require_relative '../lib/jekyll-pandoc-exports/command'
end

class TestExportRunner < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @source = @tmpdir
    @dest = File.join(@tmpdir, '_site')
    FileUtils.mkdir_p(@dest)
    FileUtils.mkdir_p(File.join(@source, '_data'))
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_validate_format_accepts_valid_formats
    %w[pdf docx both].each do |format|
      runner = build_runner('format' => format)
      runner.send(:validate_format!)
    end
  end

  def test_validate_schema_passes_valid_data
    write_valid_data_yml
    assert validate_data_yml_valid?
  end

  def test_validate_schema_catches_missing_sections
    File.write(File.join(@source, '_data', 'data.yml'), YAML.dump({
      'sidebar' => { 'name' => 'Test', 'tagline' => 'Test', 'email' => 'test@test.com' }
    }))
    refute validate_data_yml_has_all_sections?
  end

  def test_validate_schema_catches_missing_sidebar_fields
    File.write(File.join(@source, '_data', 'data.yml'), YAML.dump({
      'sidebar' => { 'name' => 'Test' },
      'career-profile' => {},
      'education' => { 'info' => [] },
      'experiences' => { 'info' => [] }
    }))
    refute validate_data_yml_sidebar_complete?
  end

  def test_find_export_targets_finds_pdf_pages
    File.write(File.join(@source, 'print.html'), "---\nlayout: print\npdf: true\ndocx: true\n---\n<h1>Test</h1>")
    File.write(File.join(@dest, 'print.html'), "<html><body><h1>Test</h1></body></html>")

    runner = build_runner('source' => @source)
    config = { 'source' => @source, 'destination' => @dest, 'baseurl' => '' }
    export_config = { 'output_dir' => '' }

    targets = runner.send(:find_export_targets, config, export_config)
    assert_equal 1, targets.length
    assert_equal 'print', targets[0][:filename]
  end

  def test_find_export_targets_filters_by_target
    File.write(File.join(@source, 'print.html'), "---\npdf: true\n---\n<h1>Print</h1>")
    File.write(File.join(@source, 'about.html'), "---\npdf: true\n---\n<h1>About</h1>")
    File.write(File.join(@dest, 'print.html'), "<html><body><h1>Print</h1></body></html>")
    File.write(File.join(@dest, 'about.html'), "<html><body><h1>About</h1></body></html>")

    runner = build_runner('source' => @source, 'target' => 'print')
    config = { 'source' => @source, 'destination' => @dest, 'baseurl' => '' }
    export_config = { 'output_dir' => '' }

    targets = runner.send(:find_export_targets, config, export_config)
    assert_equal 1, targets.length
    assert_equal 'print', targets[0][:filename]
  end

  def test_should_generate_pdf_respects_format
    runner_both = build_runner('format' => 'both')
    runner_pdf = build_runner('format' => 'pdf')
    runner_docx = build_runner('format' => 'docx')

    assert runner_both.send(:should_generate_pdf?, { 'pdf' => true })
    assert runner_pdf.send(:should_generate_pdf?, { 'pdf' => true })
    refute runner_docx.send(:should_generate_pdf?, { 'pdf' => true })
  end

  def test_should_generate_docx_respects_format
    runner_both = build_runner('format' => 'both')
    runner_pdf = build_runner('format' => 'pdf')
    runner_docx = build_runner('format' => 'docx')

    assert runner_both.send(:should_generate_docx?, { 'docx' => true })
    refute runner_pdf.send(:should_generate_docx?, { 'docx' => true })
    assert runner_docx.send(:should_generate_docx?, { 'docx' => true })
  end

  def test_determine_output_dir_uses_override
    runner = build_runner('output' => '/tmp/exports')
    config = { 'destination' => @dest }
    export_config = { 'output_dir' => 'downloads' }

    result = runner.send(:determine_output_dir, config, export_config)
    assert_equal '/tmp/exports', result
  end

  def test_determine_output_dir_uses_config
    runner = build_runner({})
    config = { 'destination' => @dest }
    export_config = { 'output_dir' => 'downloads' }

    result = runner.send(:determine_output_dir, config, export_config)
    assert_equal File.join(@dest, 'downloads'), result
  end

  private

  def build_runner(options = {})
    Jekyll::PandocExports::ExportRunner.new([], options)
  end

  def write_valid_data_yml
    data = {
      'sidebar' => { 'name' => 'Test User', 'tagline' => 'Engineer', 'email' => 'test@test.com' },
      'career-profile' => { 'title' => 'Profile', 'summary' => 'A summary.' },
      'education' => { 'title' => 'Education', 'info' => [
        { 'degree' => 'BS CS', 'university' => 'MIT', 'time' => '2010-2014' }
      ]},
      'experiences' => { 'title' => 'Experience', 'info' => [
        { 'role' => 'Engineer', 'company' => 'Acme', 'time' => '2014-Present' }
      ]}
    }
    File.write(File.join(@source, '_data', 'data.yml'), YAML.dump(data))
  end

  def validate_data_yml_valid?
    data = YAML.load_file(File.join(@source, '_data', 'data.yml'), permitted_classes: [Date])
    %w[sidebar career-profile education experiences].all? { |k| data.key?(k) } &&
      %w[name tagline email].all? { |f| data['sidebar'][f] }
  end

  def validate_data_yml_has_all_sections?
    data = YAML.load_file(File.join(@source, '_data', 'data.yml'), permitted_classes: [Date])
    %w[sidebar career-profile education experiences].all? { |k| data.key?(k) }
  end

  def validate_data_yml_sidebar_complete?
    data = YAML.load_file(File.join(@source, '_data', 'data.yml'), permitted_classes: [Date])
    return false unless data['sidebar']
    %w[name tagline email].all? { |f| data['sidebar'][f] }
  end
end
